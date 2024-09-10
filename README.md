## Fault Proof Test Cases

### Setup

Clone the [ethereum-optimism/optimism](github.com:ethereum-optimism/optimism) repository and build op-program and cannon:
```shell
$ cd /path/to/your/workspace
$ git clone git@github.com:ethereum-optimism/optimism.git
$ cd optimism
$ make op-program cannon
$ cd cannon
$ ./bin/cannon load-elf --path=../op-program/bin/op-program-client.elf
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

#### Create a local devnet with the default config file (devnet/standard.yaml)

```shell
$ just create-devnet
```

#### Create a local devnet with a custom config file

Config files must follow the format described in the [optimism-package](https://github.com/ethpandaops/optimism-package) repository.
```shell
$ just devnet-config-file=devnet/minimal.yaml create-devnet
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

#### Using fixtures defined by the script name and arguments

```shell
$ just name=<script name> script-args="<script args>" run-fixture
# Example
$ just name=Reader script-args="2000000" run-fixture
```

#### Using a fixture file

```shell
$ just fixture-file=<fixture file> run-fixture
# Example
$ just fixture-file=fixtures/Reader-2000000.json run-fixture
```

### Test Fixtures in Cannon

#### Using fixtures defined by the script name and arguments

```shell
$ just name=<script name> script-args="<script args>" cannon-fixture
# Example
$ just name=Reader script-args="2000000" cannon-fixture
```

#### Using a fixture file

```shell
$ just fixture-file=<fixture file> run-fixture
# Example
$ just fixture-file=fixtures/Reader-2000000.json cannon-fixture
```