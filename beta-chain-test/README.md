# Prysm Quickstart Guide
/// Make node folder // mkdir consensus & execution

/// Install geth

/// Get prysm.sh in consensus file  
curl https://raw.githubusercontent.com/prysmaticlabs/prysm/master/prysm.sh --output prysm.sh && chmod +x prysm.sh

/// Get jwt.hex on node folder // jwt.hex is key for link beaconchain used http ports  
./prysm.sh beacon-chain generate-auth-secret

/// Run an execution client on execution folder  
geth --mainnet --http --http.api eth,net,engine,admin --authrpc.jwtsecret=<PATH_TO_JWT_FILE>

/// Run a Beaconnode  
./prysm.sh beacon-chain --execution-endpoint=http://localhost:8551 --mainnet --jwt-secret=<PATH_TO_JWT_FILE> --checkpoint-sync-url=https://beaconstate.info --genesis-beacon-api-url=https://beaconstate.info

/// Run a Validator   
Install deposit cli in https://github.com/ethereum/staking-deposit-cli/releases  
./deposit new-mnemonic --num_validators=1 --mnemonic_language=english --chain=mainnet  
// validator key folder  
Contain "deposit_data-.json" - contains deposit data that you’ll later upload to the Ethereum launchpad & "keystore-m_.json" - contains your public key and encrypted private key.  
To set different folder for Validator keys  
./prysm.sh validator accounts import --keys-dir=<YOUR_FOLDER_PATH> --mainnet


/// Configure beacon-chain  
./prysm.sh beacon-chain --checkpoint-sync-url=http://localhost:3500 --genesis-beacon-api-url=http://localhost:3500


# Gits  
### go-ethereum
https://github.com/ethereum/go-ethereum.git
#### docs  
### prysm
https://github.com/prysmaticlabs/prysm.git
#### docs
https://docs.prylabs.network/docs/install/install-with-script