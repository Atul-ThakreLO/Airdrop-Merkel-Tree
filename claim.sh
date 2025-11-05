#!/bin/bash

# TOKEN_ADDRESS = "0x700b6A60ce7EaaEA56F065753d8dcB9653dbAD35"
# AIRDROP_ADDRESS = "0xA15BB66138824a1c7167f5E85b957d04Dd34E468"
# echo "Enter claimer address"
# read USER
# AMOUNT_TO_CLAIM = 25000000000000000000

# DIGEST=$(cast call $AIRDROP_ADDRESS "getMessageHash(address,uint256)" $USER $AMOUNT_TO_CLAIM --rpc-url http://localhost:8545)

# echo "Digest: $DIGEST"

# echo "Enter Private key: "

# read USER_PRIVATE_KEY

# SIGNATURE=$(cast wallet sign --no-hash $DIGEST --private-key $USER_PRIVATE_KEY)

# echo "Signature: $SIGNATURE"

# echo "Enter proof1: "
# read PROOF1

# echo "Enter proof2: "
# read PROOF2

# PROOF[0] = $PROOF1
# PROOF[1] = $PROOF2

# forge script script/Interact.s.sol/Claim --rpc-url http://localhost:8545 --private-key 0xdbda1821b80551c9d65939329250298aa3472ba22feea921c0cf5d620ea67b97 --broadcast

# Configuration
AIRDROP_ADDRESS="0xA15BB66138824a1c7167f5E85b957d04Dd34E468"
AMOUNT=25000000000000000000

echo "=== Airdrop Claim Script ==="
echo

# Step 1: Get user address
echo "Enter claimer address:"
read USER

# Step 2: Fetch message hash
echo "Fetching message hash..."
DIGEST=$(cast call $AIRDROP_ADDRESS "getMessageHash(address,uint256)" $USER $AMOUNT --rpc-url http://localhost:8545)
echo "✓ Digest: $DIGEST"
echo

# Step 3: Sign the message
echo "Enter private key:"
read -s PRIVATE_KEY
echo

echo "Signing..."
SIGNATURE=$(cast wallet sign --no-hash $DIGEST --private-key $PRIVATE_KEY)
echo "✓ Signature created"
echo

# Step 4: Get merkle proofs
echo "Enter proof 1:"
read PROOF1

echo "Enter proof 2:"
read PROOF2

echo

# Step 5: Run forge script (pass variables to Solidity)
echo "Running claim transaction..."

USER=$USER \
SIGNATURE=$SIGNATURE \
PROOF1=$PROOF1 \
PROOF2=$PROOF2 \
forge script script/Interact.s.sol:Claim \
    --rpc-url http://localhost:8545 \
    --private-key 0xdbda1821b80551c9d65939329250298aa3472ba22feea921c0cf5d620ea67b97 \
    --broadcast

echo
echo "✅ Done!"