// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";

/**
 * @title Bagel Token
 * @author Atul Thakre
 * @notice This token will use to be distribute in Airdrop.
 */
contract BagelToken is ERC20, Ownable {
    constructor() ERC20("Bagel", "BT") Ownable(msg.sender) {}

    function mint(address _to, uint256 _amount) external onlyOwner {
        _mint(_to, _amount);
    }
}
