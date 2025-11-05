// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {MakeMerkle} from "../script/MakeMerkle.s.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test {
    BagelToken token;
    MerkleAirdrop airdrop;

    address owner = makeAddr("owner");
    address user;
    uint256 userPrivateKey;
    address public gasPayer;

    uint256 AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;

    bytes32 ROOT = 0x25b98676491d1df9fde0d9d460c7d54944495652248852eaf982fde5d1fea839;
    bytes32 proofOne = 0x875631ab70d5c9a1430b5a44e60c2c218f68a62a01a73b2e49d03f130b04b5c9;
    bytes32 proofTwo = 0x0fb85f7b6df160de3a55fbbc3757e1166f70d574c0b5520e22040ad2b88d7a5d;
    bytes32[] PROOF = [proofOne, proofTwo];

    function setUp() public {
        DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
        (airdrop, token) = deployer.deployMerkleAirdrop();
        (user, userPrivateKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
        // bagelToken = new BagelToken();
        // merkleAirdrop = new MerkleAirdrop(ROOT, IERC20(token));
        // token.mint(token.owner(), AMOUNT_TO_SEND);
        // token.transfer(address(airdrop), AMOUNT_TO_SEND);
    }

    // modifier mintTokens {
    //     vm.prank(owner);
    //     IERC20(token).approve(user, 1e18);
    //     vm.prank(owner);
    //     token.mint(user, 1e5);
    //     _;
    // }

    function testIsAbleToClaim() public {
        uint256 startingBalance = token.balanceOf(user);
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);

        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);

        uint256 endingBalance = token.balanceOf(user);
        console.log(endingBalance);

        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }
}
