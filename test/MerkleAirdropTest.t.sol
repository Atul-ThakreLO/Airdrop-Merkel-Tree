// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {MakeMerkle} from "../script/MakeMerkle.s.sol";

contract MerkleAirdropTest is Test {
    BagelToken bagelToken;
    MerkleAirdrop merkleAirdrop;

    address owner = makeAddr("owner");
    address user;
    uint256 userPrivateKey;

    uint256 AMOUNT_TO_CLAIM = 2500 * 1e18;
    uint256 AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;

    bytes32 ROOT = 0xb1e815a99ee56f7043ed94e7e2316238187a59d85c211d06f9be7c5f94424aec;
    bytes32 proofOne = 0x9e10faf86d92c4c65f81ac54ef2a27cc0fdf6bfea6ba4b1df5955e47f187115b;
    bytes32 proofTwo = 0x8c1fd7b608678f6dfced176fa3e3086954e8aa495613efcd312768d41338ceab;
    bytes32[] PROOF = [proofOne, proofTwo]; 

    function setUp() public {
        (user, userPrivateKey) = makeAddrAndKey("user"); 
        bagelToken = new BagelToken();
        merkleAirdrop = new MerkleAirdrop(ROOT, IERC20(bagelToken));
        bagelToken.mint(bagelToken.owner(), AMOUNT_TO_SEND);
        bagelToken.transfer(address(merkleAirdrop), AMOUNT_TO_SEND);
    }

    // modifier mintTokens {
    //     vm.prank(owner);
    //     IERC20(bagelToken).approve(user, 1e18);
    //     vm.prank(owner);
    //     bagelToken.mint(user, 1e5);
    //     _;
    // }

    function testIsAbleToClaim() public {
        uint256 startingBalance = bagelToken.balanceOf(user);

        merkleAirdrop.claim(user, AMOUNT_TO_CLAIM, PROOF);

        uint256 endingBalance = bagelToken.balanceOf(user);
        console.log(endingBalance);

        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }


}
