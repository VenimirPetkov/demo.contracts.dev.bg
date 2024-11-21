// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

contract MutableERC20 is ERC20Upgradeable {
    constructor() {
        _disableInitializers();
    }

    function initialize(
        string memory name_,
        string memory symbol_
    ) public initializer {
        __ERC20_init(name_, symbol_);
    }

    function getInitializedVersion() external view returns (uint64) {
        return _getInitializedVersion();
    }
}
