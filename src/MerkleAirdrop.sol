// SPDX-License-Identifier: MIT

// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
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

/**
 * @title Aridrop Smart Contract
 * @author Atul Thakre
 * @notice This airdrop smart contract will use merkel proofs to verify the address.
 */
contract MerkleAirdrop {
using SafeERC20 for IERC20;

    ////////////////////////////////////////////////////////////
    ////////////////////////// Errors //////////////////////////
    ////////////////////////////////////////////////////////////
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();

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

    ////////////////////////////////////////////////////////////
    //////////////////////// Functions /////////////////////////
    ////////////////////////////////////////////////////////////
    constructor(bytes32 merkleRoot, IERC20 airDropToken) {
        i_merkleRoot = merkleRoot;
        i_airDropToken = airDropToken;
    }

    /**
     *
     * @param account Address of claimant, who's goint to claim the tokens.
     * @param amount Quantity of tokens account going to claim.
     * @param merkleProof Array of hashesh of combination of account and amount which will be use to verify proof aginst i_merkleRoot.
     */
    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external {
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }
        s_hasClaimed[account] = true;
        emit Claim(account, amount);

        i_airDropToken.safeTransfer(account, amount);
    }

    function getMerkleRoot() public view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirDropToken() public view returns (IERC20) {
        return i_airDropToken;
    }
}
