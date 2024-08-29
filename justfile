opfp := if `which opfp || true` != "" {
    `which opfp`
} else {
    join(env_var("OP_TESTS_DIR"), "target/debug/opfp")
}
op-program := if `which op-program || true` != "" {
    `which op-program`
} else {
    join(env_var("OPTIMISM_DIR"), "op-program/bin/op-program")
}
cannon-dir := if `which cannon || true` != "" {
    parent_directory(parent_directory(`which cannon`))
} else {
    join(env_var("OPTIMISM_DIR"), "cannon")
}

enclave := "devnet"

account := "TEST"

name := "Writer"
script-file := name + ".s.sol"

default:
  @just --list

cleanup-devnet:
    kurtosis enclave rm {{enclave}} -f

create-devnet:
    #!/bin/bash
    if kurtosis enclave inspect {{enclave}}; then
        exit 0
    fi

    kurtosis run github.com/ethpandaops/optimism-package --args-file network_params.yaml --enclave {{enclave}}

script: create-devnet
    #!/bin/bash
    L1_RPC_URL=http://$(kurtosis service inspect {{enclave}} el-1-geth-lighthouse | grep -- ' rpc: ' | sed 's/.*-> //')
    L2_RPC_URL=$(kurtosis service inspect {{enclave}} op-el-1-op-geth-op-node | grep -- ' rpc: ' | sed 's/.*-> //')
    BEACON_URL=$(kurtosis service inspect {{enclave}} cl-1-lighthouse-geth | grep -- ' http: ' | sed 's/.*-> //')
    ROLLUP_URL=$(kurtosis service inspect {{enclave}} op-cl-1-op-node-op-geth | grep -- ' http: ' | sed 's/.*-> //')

    forge script --non-interactive --password="" --rpc-url $L2_RPC_URL --account {{account}} --broadcast script/{{script-file}} -g 400

    rm -rf op-genesis-configs
    kurtosis files download {{enclave}} op-genesis-configs

    GENESIS_PATH=op-genesis-configs/genesis.json
    ROLLUP_PATH=op-genesis-configs/rollup.json

    L2_BLOCK_NUM=$(($(jq < broadcast/{{script-file}}/2151908/run-latest.json '.receipts[0].blockNumber' -r)))

    while true; do
        SYNC_STATUS=$(cast rpc optimism_syncStatus --rpc-url $ROLLUP_URL)
        L2_SAFE_BLOCK_NUM=$(echo $SYNC_STATUS | jq '.safe_l2.number')
        L1_BLOCK_NUM=$(echo $SYNC_STATUS | jq '.head_l1.number')
        if [ $L2_SAFE_BLOCK_NUM -ge $(($L2_BLOCK_NUM)) ]; then
            break
        fi
        echo "Waiting for L2 block $L2_BLOCK_NUM to be safe..., currently at $L2_SAFE_BLOCK_NUM"
        sleep 10
    done

    {{opfp}} from-op-program --op-program {{op-program}} --l2-block $L2_BLOCK_NUM --l1-block $L1_BLOCK_NUM --l1-rpc-url $L1_RPC_URL --l2-rpc-url $L2_RPC_URL --beacon-url $BEACON_URL --rollup-url $ROLLUP_URL --rollup-path $ROLLUP_PATH --genesis-path $GENESIS_PATH --output {{name}}.out -vv

cannon-fixture:
    {{opfp}} run-op-program --op-program {{op-program}} --fixture {{name}}.out --cannon {{cannon-dir}}/bin/cannon --cannon-state {{cannon-dir}}/state.json --cannon-meta {{cannon-dir}}/meta.json --cannon-debug {{cannon-dir}}/debug.json -vv