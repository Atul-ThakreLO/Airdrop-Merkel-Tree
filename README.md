# Merkle Airdrop Smart Contract

A secure and gas-efficient airdrop distribution system built with Solidity and Foundry, utilizing Merkle Trees for verification and EIP-712 signatures for gasless claiming.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Smart Contracts](#smart-contracts)
- [How It Works](#how-it-works)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Testing](#testing)
- [Deployment](#deployment)
- [Security](#security)
- [License](#license)

## 🎯 Overview

This project implements a Merkle Tree-based airdrop system that allows eligible users to claim ERC20 tokens (BagelToken) efficiently. The system uses cryptographic proofs to verify eligibility and supports meta-transactions for gasless claims via EIP-712 signatures.

## ✨ Features

- **Merkle Proof Verification**: Efficient on-chain verification using Merkle Trees
- **Gasless Claims**: Users can sign transactions off-chain; a relayer can submit on their behalf
- **EIP-712 Signatures**: Structured data signing for improved security and user experience
- **Reentrancy Protection**: Follows Checks-Effects-Interactions pattern
- **Gas Optimized**: Minimal storage and computational overhead
- **Safe Token Transfers**: Uses OpenZeppelin's SafeERC20 library

## 📝 Smart Contracts

### MerkleAirdrop.sol

The main airdrop contract that:

- Verifies Merkle proofs against a stored root
- Validates EIP-712 signatures
- Tracks claimed addresses
- Distributes tokens to eligible claimants

### BagelToken.sol

An ERC20 token contract with:

- Mintable functionality (owner only)
- Standard ERC20 operations
- OpenZeppelin's Ownable implementation

## 🔧 How It Works

1. **Setup Phase**:

   - Generate a Merkle Tree from eligible addresses and their allocations
   - Deploy contracts with the Merkle root
   - Fund the airdrop contract with tokens

2. **Claim Phase**:

   - User signs a claim message (EIP-712 format) with their private key
   - User (or relayer) submits the claim with:
     - Account address
     - Amount to claim
     - Merkle proof
     - Signature components (v, r, s)

3. **Verification**:
   - Contract verifies the signature matches the account
   - Contract verifies the Merkle proof against the stored root
   - If valid, tokens are transferred to the user

## 📦 Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- Basic understanding of Solidity and smart contracts

## 🚀 Installation

1. Clone the repository:

```bash
git clone https://github.com/Atul-ThakreLO/Airdrop-Merkel-Tree.git
cd Airdrop
```

2. Install dependencies:

```bash
forge install
```

3. Build the project:

```bash
forge build
```

## 💻 Usage

### Build

```bash
forge build
```

### Test

Run all tests:

```bash
forge test
```

Run tests with verbosity:

```bash
forge test -vvvv
```

### Format Code

```bash
forge fmt
```

### Gas Snapshots

```bash
forge snapshot
```

### Local Development

1. Start a local Anvil node:

```bash
anvil
```

2. Deploy contracts (in a new terminal):

```bash
forge script script/DeployMerkleAirdrop.s.sol --rpc-url http://localhost:8545 --broadcast
```

### Interactive Claiming on Anvil

For testing the claim functionality on a local Anvil node, use the provided `claim.sh` script:

1. Make the script executable:

```bash
chmod +x claim.sh
```

2. Run the script:

```bash
./claim.sh
```

The script will interactively prompt you for:

- **Claimer address**: The address eligible for the airdrop
- **Private key**: The private key of the claimer (for signing)
- **Proof 1**: First Merkle proof hash
- **Proof 2**: Second Merkle proof hash

The script will:

1. Fetch the message hash from the deployed airdrop contract
2. Create an EIP-712 signature using the claimer's private key
3. Submit the claim transaction with the signature and Merkle proof
4. Display the transaction result

**Example Usage:**

```bash
$ ./claim.sh
=== Airdrop Claim Script ===

Enter claimer address:
0x1234...

Fetching message hash...
✓ Digest: 0xabcd...

Enter private key:
[hidden]

✓ Signature created

Enter proof 1:
0x875631ab70d5c9a1430b5a44e60c2c218f68a62a01a73b2e49d03f130b04b5c9

Enter proof 2:
0x0fb85f7b6df160de3a55fbbc3757e1166f70d574c0b5520e22040ad2b88d7a5d

Running claim transaction...
✅ Done!
```

**Note**: The script uses a default gas payer private key for Anvil. Update the private key in `claim.sh` if using a different setup.

## 🧪 Testing

The test suite includes:

- Claim functionality verification
- Signature validation tests
- Merkle proof verification
- Reentrancy protection tests

Run specific test:

```bash
forge test --match-test testIsAbleToClaim
```

## 🌐 Deployment

### Deploy to Local Network

```bash
forge script script/DeployMerkleAirdrop.s.sol --rpc-url http://localhost:8545 --broadcast
```

### Deploy to Testnet/Mainnet

```bash
forge script script/DeployMerkleAirdrop.s.sol \
  --rpc-url <YOUR_RPC_URL> \
  --private-key <YOUR_PRIVATE_KEY> \
  --broadcast \
  --verify
```

**Environment Variables** (recommended):
Create a `.env` file:

```
PRIVATE_KEY=your_private_key
RPC_URL=your_rpc_url
ETHERSCAN_API_KEY=your_etherscan_api_key
```

Then deploy:

```bash
source .env
forge script script/DeployMerkleAirdrop.s.sol \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

## 🔒 Security

### Security Features

- **Double Hashing**: Merkle leaves are hashed twice for enhanced security
- **SafeERC20**: Prevents failed transfers from leaving the contract in an inconsistent state
- **Claim Tracking**: Prevents double-claiming
- **EIP-712**: Prevents signature replay attacks across different domains
- **ECDSA Recovery**: Secure signature verification

### Best Practices

- Always audit the Merkle tree generation process
- Verify the Merkle root before deployment
- Use hardware wallets for deployment on mainnet
- Test thoroughly on testnets before mainnet deployment

## 📚 Additional Resources

- [Foundry Book](https://book.getfoundry.sh/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [EIP-712 Specification](https://eips.ethereum.org/EIPS/eip-712)
- [Merkle Trees Explained](https://en.wikipedia.org/wiki/Merkle_tree)

## 🛠️ Foundry Tools

This project is built with Foundry, which includes:

- **Forge**: Ethereum testing framework
- **Cast**: Swiss army knife for interacting with EVM smart contracts
- **Anvil**: Local Ethereum node
- **Chisel**: Solidity REPL

### Helpful Commands

```bash
# Get help
forge --help
anvil --help
cast --help

# Check contract size
forge build --sizes

# Generate gas report
forge test --gas-report

# Coverage
forge coverage
```

## 👨‍💻 Author

**Atul Thakre**

## 📄 License

This project is licensed under the MIT License.
