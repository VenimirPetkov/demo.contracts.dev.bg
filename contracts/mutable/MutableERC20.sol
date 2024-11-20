// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

contract MutableERC20 is ERC20Upgradeable {
    uint8 private _decimals;

    constructor() {
        _disableInitializers();
    }

    function initialize(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) public initializer {
        __ERC20_init(name_, symbol_);
        _decimals = decimals_;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function getInitializedVersion() external view returns (uint64) {
        return _getInitializedVersion();
    }
}
