# Getting started with SUI

## SUI CLI

### Installation

Follow the instruction here: <https://docs.sui.io/devnet/build/install>

### Update CLI

```sh
# You might need to update rust
rustup update stable
source "$HOME/.cargo/env"

# Update Sui CLI
cargo install --locked --git <https://github.com/MystenLabs/sui.git> --branch devnet sui
```

## CLI cheatsheet

### Connect to networks

```bash

sui genesis # run local net
sui client  # connect to dev network

sui start  # start the network
```

### Switch network

```sh

sui client active-env # show the current active network
sui client envs # the envs ( networks ) sui client config
sui client switch --env alias_name # switch to another network - alias_name is the name of alias in client.yaml (localnet, devnet, ...)
```

### Client config file

Sui config file is stored in ~/.sui/sui_config/client.yaml

```yaml
---
keystore:
  File: /Users/channaly/.sui/sui_config/sui.keystore
envs:
  - alias: devnet
    rpc: "https://fullnode.devnet.sui.io:443"
    ws: ~
  - alias: localnet
    rpc: "http://0.0.0.0:9000"
    ws: ~
active_env: devnet
active_address: "0xaefa679fc1b07be1570e06c1756ed47435064021"
```

### Get account address

```sh
# Get you account address ( wallet )
sui client active-address # also seen in ~/sui/sui_config/client.yaml
=> 0xaefa679fc1b07be1570e06c1756ed47435064021

# Create a new address
sui client new-address ed25519 # key scheme: ed25519 or secp256k1

# Add an exsiting account:
# edit client.yaml and add your keypair in the keystore file and then restart sui cli
```

### Get account balance

```sh
# Check the gas
sui client gas
```

### Create a SUI project

```sh

sui move new my_first_package
sui move build
sui move test # run test
sui move test test_sword_create # run a specific test

sui client publish --gas-budget 10000 # publish the package to sui network
...
Transaction Kind : Publish
----- Transaction Effects ----
Status : Success
Created Objects:
  - ID: 0x57258f32746fd1443f2a077c0c6ec03282087c19 , Owner: Immutable
Mutated Objects:
  - ID: 0x2bbd6aeabb1d1168566c3d973d62820701847ba9 , Owner: Account Address ( 0xf641397cc701092a193f7a2a6d320af39ca16ed3 )

```

### Interact with on-chain

The 0x57258f32746fd1443f2a077c0c6ec03282087c19 is the package address, for convenience, let's create a env for this

```sh
export MONO_PAD_PACKAGE=0x57258f32746fd1443f2a077c0c6ec03282087c19

# invoke a constract in color module and create_color entry fun in the package 0x57258f32746fd1443f2a077c0c6ec03282087c19
sui client call --gas-budget 1000 --package $MONO_PAD_PACKAGE --module "color_object" --function "create" --args 0 255 0
...
----- Transaction Effects ----
Status : Success
Created Objects:
  - ID: 0x5eb2c3e55693282faa7f5b07ce1c4803e6fdc1bb , Owner: Account Address ( 0xf641397cc701092a193f7a2a6d320af39ca16ed3 )
Mutated Objects:
  - ID: 0x2bbd6aeabb1d1168566c3d973d62820701847ba9 , Owner: Account Address ( 0xf641397cc701092a193f7a2a6d320af39ca16ed3 )

export MONO_PAD_OBJECT=0x5eb2c3e55693282faa7f5b07ce1c4803e6fdc1bb # save it in env for convenience

# We can inspect this object and see what kind of object it is:
sui client object $MONO_PAD_OBJECT

# On-chain data
...
----- Move Object (0x28d511b9689871fd7d3303b5f9657b6287b48279[8]) -----
Owner: Account Address ( 0xf641397cc701092a193f7a2a6d320af39ca16ed3 )
Version: 8
Storage Rebate: 14
Previous Transaction: HRrB6qFxQZt7VEzagEjE4nhF9rbffK2wZRxqn9pPLhMk
----- Data -----
type: 0x57258f32746fd1443f2a077c0c6ec03282087c19::color_object::ColorObject
blue: 0
green: 255
id: 0x28d511b9689871fd7d3303b5f9657b6287b48279
red: 0

```
