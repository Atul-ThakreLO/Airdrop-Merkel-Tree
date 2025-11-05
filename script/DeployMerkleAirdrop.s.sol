// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 s_merkleRoot = 0x74ddccb6e201771dc8ddcc9759f73a3bb6851b67f57500b2f7fc2323c03344ba;
    uint256 s_amountToTransfer = 5 * 25 * 1e18;

    function deployMerkleAirdrop() public returns (MerkleAirdrop, BagelToken) {
        vm.startBroadcast();
        BagelToken token = new BagelToken();
        MerkleAirdrop airDrop = new MerkleAirdrop(s_merkleRoot, token);
        token.mint(token.owner(), s_amountToTransfer);
        token.transfer(address(airDrop), s_amountToTransfer);
        vm.stopBroadcast();
        console.log("Token", address(token));
        console.log("Airdrop", address(airDrop));
        return (airDrop, token);
    }

    function run() public returns (MerkleAirdrop, BagelToken) {
        return deployMerkleAirdrop();
    }
}
