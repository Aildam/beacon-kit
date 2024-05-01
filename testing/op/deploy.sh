#!/bin/bash

# Step 3: Fill out environment variables in .env file
L1_RPC_URL="http://localhost:64064"  # Replace with your L1 node URL
L1_CHAINID=80087
L2_CHAINID=69421

# Step 0: Copy the examples to the contracts-bedrock
cp example.deployer ~/op-stack-deployment/optimism/packages/contracts-bedrock/deploy-config/getting-started.json
cd ~/op-stack-deployment/optimism/packages/contracts-bedrock

# Step 1: Generate some Keys
output=$(cast wallet new)
# Parse the output using awk and store the values in variables
admin_address=$(echo "$output" | awk '/Address:/ { print $2 }')
admin_private_key=$(echo "$output" | awk '/Private key:/ { getline; print $3 }')

output=$(cast wallet new)
proposer_address=$(echo "$output" | awk '/Address:/ { print $2 }')
proposer_private_key=$(echo "$output" | awk '/Private key:/ { getline; print $3 }')

output=$(cast wallet new)
batcher_address=$(echo "$output" | awk '/Address:/ { print $2 }')
batcher_private_key=$(echo "$output" | awk '/Private key:/ { getline; print $3 }')

output=$(cast wallet new)
sequencer_address=$(echo "$output" | awk '/Address:/ { print $2 }')
sequencer_private_key=$(echo "$output" | awk '/Private key:/ { getline; print $3 }')

# Print the variables
echo "Admin Address: $admin_address"
echo "Admin Private Key: $admin_private_key"
echo "Proposer Address: $proposer_address"
echo "Proposer Private Key: $proposer_private_key"
echo "Batcher Address: $batcher_address"
echo "Batcher Private Key: $batcher_private_key"
echo "Sequencer Address: $sequencer_address"
echo "Sequencer Private Key: $sequencer_private_key"

echo "Sending 100 ether to all addresses..."
cast send --private-key fffdbb37105441e14b0ee6330d855d8504ff39e705c3afa8f859ac9865f99306 $admin_address --value 100ether --rpc-url $L1_RPC_URL
cast send --private-key fffdbb37105441e14b0ee6330d855d8504ff39e705c3afa8f859ac9865f99306 $proposer_address --value 100ether --rpc-url $L1_RPC_URL
cast send --private-key fffdbb37105441e14b0ee6330d855d8504ff39e705c3afa8f859ac9865f99306 $batcher_address --value 100ether --rpc-url $L1_RPC_URL
cast send --private-key fffdbb37105441e14b0ee6330d855d8504ff39e705c3afa8f859ac9865f99306 $sequencer_address --value 100ether --rpc-url $L1_RPC_URL

# Update deploy-config/getting-started.json with addresses from reky
awk -v admin_address="$admin_address" '/"finalSystemOwner": "ADMIN"/{$0="    \"finalSystemOwner\": \"" admin_address "\", "}1' deploy-config/getting-started.json > temp && mv temp deploy-config/getting-started.json
awk -v admin_address="$admin_address" '/"portalGuardian": "ADMIN"/{$0="    \"portalGuardian\": \"" admin_address "\", "}1' deploy-config/getting-started.json > temp && mv temp deploy-config/getting-started.json
awk -v admin_address="$admin_address" '/"controller": "ADMIN"/{$0="    \"controller\": \"" admin_address "\", "}1' deploy-config/getting-started.json > temp && mv temp deploy-config/getting-started.json
awk -v sequencer_address="$sequencer_address" '/"p2pSequencerAddress": "SEQUENCER"/{$0="    \"p2pSequencerAddress\": \"" sequencer_address "\", "}1' deploy-config/getting-started.json > temp && mv temp deploy-config/getting-started.json
awk -v batcher_address="$batcher_address" '/"batchInboxAddress": "0xff00000000000000000000000000000000042069"/{$0="    \"batchInboxAddress\": \"" batcher_address "\", "}1' deploy-config/getting-started.json > temp && mv temp deploy-config/getting-started.json
awk -v batcher_address="$batcher_address" '/"batchSenderAddress": "BATCHER"/{$0="    \"batchSenderAddress\": \"" batcher_address "\", "}1' deploy-config/getting-started.json > temp && mv temp deploy-config/getting-started.json
awk -v proposer_address="$proposer_address" '/"l2OutputOracleProposer": "PROPOSER"/{$0="    \"l2OutputOracleProposer\": \"" proposer_address "\", "}1' deploy-config/getting-started.json > temp && mv temp deploy-config/getting-started.json
awk -v admin_address="$admin_address" '/"l2OutputOracleChallenger": "ADMIN"/{$0="    \"l2OutputOracleChallenger\": \"" admin_address "\", "}1' deploy-config/getting-started.json > temp && mv temp deploy-config/getting-started.json
awk -v admin_address="$admin_address" '/"proxyAdminOwner": "ADMIN"/{$0="    \"proxyAdminOwner\": \"" admin_address "\", "}1' deploy-config/getting-started.json > temp && mv temp deploy-config/getting-started.json
awk -v admin_address="$admin_address" '/"baseFeeVaultRecipient": "ADMIN"/{$0="    \"baseFeeVaultRecipient\": \"" admin_address "\", "}1' deploy-config/getting-started.json > temp && mv temp deploy-config/getting-started.json
awk -v admin_address="$admin_address" '/"l1FeeVaultRecipient": "ADMIN"/{$0="    \"l1FeeVaultRecipient\": \"" admin_address "\", "}1' deploy-config/getting-started.json > temp && mv temp deploy-config/getting-started.json
awk -v admin_address="$admin_address" '/"sequencerFeeVaultRecipient": "ADMIN"/{$0="    \"sequencerFeeVaultRecipient\": \"" admin_address "\", "}1' deploy-config/getting-started.json > temp && mv temp deploy-config/getting-started.json
awk -v admin_address="$admin_address" '/"governanceTokenOwner": "ADMIN"/{$0="    \"governanceTokenOwner\": \"" admin_address "\", "}1' deploy-config/getting-started.json > temp && mv temp deploy-config/getting-started.json

# Get L1 Info
output=$(cast block finalized | grep -E "(timestamp|hash|number)")
# Parse the output using awk and store the values in variables
hash=$(echo "$output" | awk '/hash/ { print $2 }')
number=$(echo "$output" | awk '/number/ { print $2 }')
timestamp=$(echo "$output" | awk '/timestamp/ { print $2 }')

# Print the variables
echo "Hash: $hash"
echo "Number: $number"
echo "Timestamp: $timestamp"

# Update deploy-config/getting-started.json file with the values
awk -v hash="$hash" '/"l1StartingBlockTag": "BLOCKHASH"/{$0="    \"l1StartingBlockTag\": \"" hash "\", "}1' deploy-config/getting-started.json > temp && mv temp deploy-config/getting-started.json
awk -v timestamp="$timestamp" '/"l2OutputOracleStartingTimestamp": TIMESTAMP/{$0="    \"l2OutputOracleStartingTimestamp\": " timestamp ", "}1' deploy-config/getting-started.json > temp && mv temp deploy-config/getting-started.json
awk -v L1_CHAINID="$L1_CHAINID" '/"l1ChainID": L1_CHAINID/{$0="    \"l1ChainID\": " L1_CHAINID ", "}1' deploy-config/getting-started.json > temp && mv temp deploy-config/getting-started.json
awk -v L2_CHAINID="$L2_CHAINID" '/"l2ChainID": L2_CHAINID/{$0="    \"l2ChainID\": " L2_CHAINID ", "}1' deploy-config/getting-started.json > temp && mv temp deploy-config/getting-started.json

# Print the updated JSON file
echo "deploy-config/getting-started.json"
cat deploy-config/getting-started.json

# Step 4: Deploy L1 smart contracts
forge script scripts/Deploy.s.sol:Deploy --private-key $admin_private_key --broadcast --rpc-url $L1_RPC_URL
forge script scripts/Deploy.s.sol:Deploy --sig 'sync()' --private-key $admin_private_key --broadcast --rpc-url $L1_RPC_URL

# Step 5: Build and run OP Node
cd ~/op-stack-deployment/optimism/op-node

go run cmd/main.go genesis l2 \
    --deploy-config ../packages/contracts-bedrock/deploy-config/getting-started.json \
    --deployment-dir ../packages/contracts-bedrock/deployments/getting-started/ \
    --outfile.l2 genesis.json \
    --outfile.rollup rollup.json \
    --l1-rpc $L1_RPC_URL

openssl rand -hex 32 > jwt.txt

cp genesis.json ~/op-stack-deployment/op-geth
cp jwt.txt ~/op-stack-deployment/op-geth


# Step 6: Build OP Geth
cd ~/op-stack-deployment/op-geth
mkdir datadir
echo "pwd" > datadir/password

echo $sequencer_private_key > datadir/block-signer-key

./build/bin/geth account import --datadir=datadir --password=datadir/password datadir/block-signer-key

build/bin/geth init --datadir=datadir genesis.json
