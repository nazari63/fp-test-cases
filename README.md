## Fault Proof Test Cases

### Setup

Clone the [ethereum-optimism/optimism](github.com:ethereum-optimism/optimism) repository and build op-program and cannon:
```shell
$ cd /path/to/your/workspace
$ git clone git@github.com:ethereum-optimism/optimism.git
$ cd optimism
$ make op-program cannon
```

Configure the environment variables in the `.env` file:
```shell
OPTIMISM_DIR=/path/to/ethereum-optimsm/optimism
```

Create a foundry test wallet (based on the default anvil mnemonic):
```shell
cast wallet import TEST --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

Install [kurtosis](https://docs.kurtosis.com/install/) (required for creating a local devnet).

## Usage

### Build the `opfp` binary

```shell
$ just build
```

### Start a local devnet
```shell
$ just create-devnet
```

### Cleanup a local devnet
```shell
$ just cleanup-devnet
```

### Generate Fixtures (requires a local devnet)

```shell
$ just name=<script name> script-args="<script args>" generate-fixture
# Example
$ just name=Reader script-args="2000000" generate-fixture
```

### Test Fixtures in op-program

```shell
$ just name=<script name> script-args="<script args>" run-fixture
# Example
$ just name=Reader script-args="2000000" run-fixture
```

### Test Fixtures in Cannon

```shell
$ just name=<script name> script-args="<script args>" cannon-fixture
# Example
$ just name=Reader script-args="2000000" cannon-fixture
```
