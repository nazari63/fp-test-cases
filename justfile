set dotenv-load

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

cannon-bin := join(cannon-dir, "bin/cannon")
cannon-state := join(cannon-dir, "state.json")
cannon-meta := join(cannon-dir, "meta.json")

enclave := "devnet"

account := "TEST"

# Space-separated list of script arguments

## Precompile 
# name := "Precompiler"
# script-file := name + ".s.sol"
# script-args := "2 1000000 true"
# script-signature := "run(" + replace_regex(script-args, "^(\\S+)\\s+(\\S+)\\s+(\\S+)$", "uint256,uint256,bool") + ")"

## Transfer 
name := "ERC20Transfer"
script-file := name + ".s.sol"
script-args := "2000000 0xa83114A443dA1CecEFC50368531cACE9F37fCCcb"
script-signature := "run(" + replace_regex(script-args, "^(\\S+)\\s+(\\S+)$", "uint256,address") + ")"

expanded-name := replace_regex(trim(name + " " + script-args), " ", "-")
fixture-file := join("fixtures", expanded-name + ".json")

op-program-output := join("output", "op-program", expanded-name + ".json")
cannon-output := join("output", "cannon", expanded-name + ".json")

verbosity := "-vv"

genesis-path := "op-genesis-configs/genesis.json"
rollup-path := "op-genesis-configs/rollup.json"

default:
  @just --list

cleanup-devnet:
    kurtosis enclave rm {{enclave}} -f

create-devnet:
    kurtosis run github.com/ethpandaops/optimism-package \
        --args-file network_params.yaml \
        --enclave {{enclave}}

l1-rpc-url := `kurtosis service inspect devnet el-1-geth-lighthouse | grep -- ' rpc: ' | sed 's/.*-> //'`
L2_RPC_URL := `kurtosis service inspect devnet op-el-1-op-geth-op-node | grep -- ' rpc: ' | sed 's/.*-> //'`
beacon-url := `kurtosis service inspect devnet cl-1-lighthouse-geth | grep -- ' http: ' | sed 's/.*-> //'`
ROLLUP_URL := `kurtosis service inspect devnet op-cl-1-op-node-op-geth | grep -- ' http: ' | sed 's/.*-> //'`

generate-fixture:
    #!/bin/bash
    set -e

    forge script \
        --non-interactive \
        --password="" \
        --rpc-url {{ L2_RPC_URL }} \
        --account {{account}} \
        --broadcast \
        --sig "{{script-signature}}" \
        script/{{script-file}} \
        {{script-args}}

    rm -rf op-genesis-configs
    kurtosis files download {{enclave}} op-genesis-configs

    L2_BLOCK_NUM=$(($(jq < broadcast/{{script-file}}/2151908/run-latest.json '.receipts[0].blockNumber' -r)))

    while true; do
        SYNC_STATUS=$(cast rpc optimism_syncStatus --rpc-url {{ ROLLUP_URL }})
        L2_SAFE_BLOCK_NUM=$(echo $SYNC_STATUS | jq '.safe_l2.number')
        L1_BLOCK_NUM=$(echo $SYNC_STATUS | jq '.head_l1.number')
        if [ $L2_SAFE_BLOCK_NUM -ge $(($L2_BLOCK_NUM)) ]; then
            break
        fi
        echo "Waiting for L2 block $L2_BLOCK_NUM to be safe..., currently at $L2_SAFE_BLOCK_NUM"
        sleep 10
    done

    mkdir -p {{parent_directory(fixture-file)}}

    {{opfp}} from-op-program \
        --op-program {{op-program}} \
        --l2-block $L2_BLOCK_NUM \
        --l1-block $L1_BLOCK_NUM \
        --l1-rpc-url http://{{l1-rpc-url}} \
        --l2-rpc-url {{L2_RPC_URL}} \
        --beacon-url {{beacon-url}} \
        --rollup-url {{ROLLUP_URL}} \
        --rollup-path {{rollup-path}} \
        --genesis-path {{genesis-path}} \
        --output {{fixture-file}} \
        {{verbosity}}

run-fixture name index gasUse bool:
    mkdir -p {{parent_directory("./output/op-program/{{name}}-{{index}}-{{gasUse}}-{{bool}}.json")}}

    {{opfp}} run-op-program \
        --op-program {{op-program}} \
        --fixture ./fixtures/{{name}}-{{index}}-{{gasUse}}-{{bool}}.json \
        --output ./output/op-program/{{name}}-{{index}}-{{gasUse}}-{{bool}}.json \
        {{verbosity}}

cannon-fixture name index gasUse bool:
    mkdir -p {{parent_directory("./output/cannon/{{name}}-{{index}}-{{gasUse}}-{{bool}}.json")}}

    {{opfp}} run-op-program \
        --op-program {{op-program}} \
        --fixture ./fixtures/{{name}}-{{index}}-{{gasUse}}-{{bool}}.json \
        --cannon {{cannon-bin}} \
        --cannon-state {{cannon-state}} \
        --cannon-meta {{cannon-meta}} \
        --output ./output/cannon/{{name}}-{{index}}-{{gasUse}}-{{bool}}.json \
        {{verbosity}}

cannon-transfer-fixture gasUse address:
    mkdir -p {{parent_directory("./output/cannon/Transfer-{{gasUse}}-{{address}}.json")}}

    {{opfp}} run-op-program \
        --op-program {{op-program}} \
        --fixture ./fixtures/Transfer-{{gasUse}}-{{address}}.json \
        --cannon {{cannon-bin}} \
        --cannon-state {{cannon-state}} \
        --cannon-meta {{cannon-meta}} \
        --output ./output/cannon/Transfer-{{gasUse}}-{{address}}.json \
        {{verbosity}}