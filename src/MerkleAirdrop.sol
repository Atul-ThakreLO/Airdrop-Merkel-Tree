// SPDX-License-Identifier: MIT

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions

pragma solidity ^0.8.19;

import {MerkleProof} from "@openzeppelin/utils/cryptography/MerkleProof.sol";
// import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {IERC20, SafeERC20} from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {EIP712} from "@openzeppelin/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/utils/cryptography/ECDSA.sol";

/**
 * @title Aridrop Smart Contract
 * @author Atul Thakre
 * @notice This airdrop smart contract will use merkle proofs to verify the address.
 */
contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;

    ////////////////////////////////////////////////////////////
    ////////////////////////// Errors //////////////////////////
    ////////////////////////////////////////////////////////////
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    ////////////////////////////////////////////////////////////
    ///////////////////// Type decleration /////////////////////
    ////////////////////////////////////////////////////////////
    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    ////////////////////////////////////////////////////////////
    ////////////////////////// Events //////////////////////////
    ////////////////////////////////////////////////////////////
    event Claim(address indexed account, uint256 amount);

    ////////////////////////////////////////////////////////////
    //////////////////// Storage Variables /////////////////////
    ////////////////////////////////////////////////////////////
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airDropToken;
    mapping(address claimer => bool claimed) private s_hasClaimed;
    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account, uint256 amount)");

    ////////////////////////////////////////////////////////////
    //////////////////////// Functions /////////////////////////
    ////////////////////////////////////////////////////////////
    constructor(bytes32 merkleRoot, IERC20 airDropToken) EIP712("MerkleAirdrop", "1")  {
        i_merkleRoot = merkleRoot;
        i_airDropToken = airDropToken;
    }

    /**
     *
     * @param account Address of claimant, who's goint to claim the tokens.
     * @param amount Quantity of tokens account going to claim.
     * @param merkleProof Array of hashesh of combination of account and amount which will be use to verify proof aginst i_merkleRoot.
     */
    function claim(address account, uint256 amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s) external {
        // Check is user has already claimed or not
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }

        if (!_isValidSignature(account, getMessageHash(account, amount), v, r, s)) {
            revert MerkleAirdrop__InvalidSignature();
        }

        // Hash it twice for better security.
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }

        // Set claimed ture first to prevent rentrancy attack. To follow CEI
        s_hasClaimed[account] = true;
        emit Claim(account, amount);

        i_airDropToken.safeTransfer(account, amount);
    }

    function _isValidSignature(address account, bytes32 digest, uint8 _v, bytes32 _r, bytes32 _s) internal pure returns (bool) {
        (address actualSigner, , ) = ECDSA.tryRecover(digest, _v, _r, _s);
        return actualSigner == account;
    }

    ////////////////////////////////////////////////////////////
    ///////////////////////// Getters //////////////////////////
    ////////////////////////////////////////////////////////////

    function getMessageHash(address _account, uint256 _amount) public view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: _account, amount: _amount}))));
    }

    function getMerkleRoot() public view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirDropToken() public view returns (IERC20) {
        return i_airDropToken;
    }
}
