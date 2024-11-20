// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import "./TransparentUpgradeableProxy.sol";

contract MutableERC20Proxy is TransparentUpgradeableProxy {
    constructor(
        address logic_,
        address admin_,
        bytes memory data_
    ) TransparentUpgradeableProxy(logic_, admin_, data_) {}

    function admin() external view returns (address) {
        return _proxyAdmin();
    }

    function implementation() external view returns (address) {
        return _implementation();
    }
}
