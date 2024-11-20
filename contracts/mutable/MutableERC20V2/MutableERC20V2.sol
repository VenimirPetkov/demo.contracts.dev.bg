// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {MutableERC20} from "../MutableERC20.sol";

contract MutableERC20V2 is MutableERC20 {
    uint8 private _decimals;

    constructor() {
        _disableInitializers();
    }
    
    function initializeV2(
        string memory newName_,
        string memory newSymbol_,
        uint256 totalSupply_
    ) public reinitializer(2) {
        __ERC20_init_unchained(newName_, newSymbol_);
        _mint(msg.sender, totalSupply_);
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
}
