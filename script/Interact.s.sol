// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract Claim is Script {

    error __Claim_InvalidSignature();

    uint256 AMOUNT_TO_CLAIM = 25 * 1e18;
    function claimAirdrop(address user, address airdrop,  bytes32[] memory merkleProof, bytes memory signature) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);
        MerkleAirdrop(airdrop).claim(user, AMOUNT_TO_CLAIM, merkleProof, v, r, s);
        vm.stopBroadcast();
    }

    /**
     * @notice Here we have also option to use vm.sign(digest, privateKey).
     * But due to security reasons we can't hardcode or keep privateKey in env.
     * Hence we use 'cast wallet sign --no-hash $DIGEST --private-key $PRIVATE_KEY'
     * This returns signature i.e @param sig
     * and function splitSignature function use to split into
     * @param v, @param r, @param s.
     */
    function splitSignature(bytes memory sig) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        if(sig.length != 65) {
            revert __Claim_InvalidSignature();
        }
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

    function run() external {
        address user = vm.envAddress("USER");
        bytes memory signature = vm.envBytes("SIGNATURE");
        bytes32 proof1 = vm.envBytes32("PROOF1");
        bytes32 proof2 = vm.envBytes32("PROOF2");

        bytes32[] memory proof = new bytes32[](2);
        proof[0] = proof1;
        proof[1] = proof2;

        address airdrop = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(user, airdrop, proof, signature);
    }
}