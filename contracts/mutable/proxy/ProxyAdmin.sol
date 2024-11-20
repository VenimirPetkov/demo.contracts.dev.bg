// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (proxy/transparent/ProxyAdmin.sol)

pragma solidity ^0.8.22;

import {ITransparentUpgradeableProxy} from "./interfaces/ITransparentUpgradeableProxy.sol";
import {Ownable} from "../Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @dev This is an auxiliary contract meant to be assigned as the admin of a {TransparentUpgradeableProxy}. For an
 * explanation of why you would want to use this see the documentation for {TransparentUpgradeableProxy}.
 */
contract ProxyAdmin is Ownable {
    /**
     * @dev The version of the upgrade interface of the contract. If this getter is missing, both `upgrade(address,address)`
     * and `upgradeAndCall(address,address,bytes)` are present, and `upgrade` must be used if no function should be called,
     * while `upgradeAndCall` will invoke the `receive` function if the third argument is the empty byte string.
     * If the getter returns `"5.0.0"`, only `upgradeAndCall(address,address,bytes)` is present, and the third argument must
     * be the empty byte string if no function should be called, making it impossible to invoke the `receive` function
     * during an upgrade.
     */
    string public constant UPGRADE_INTERFACE_VERSION = "5.0.0";

    /**
     * @dev Sets the initial owner who can perform upgrades.
     */
    constructor(address initialOwner) Ownable(initialOwner) {}

    function upgradeAndCall(
        address proxyAddr,
        address implementation,
        bytes memory data
    ) public virtual onlyOwner {
        ITransparentUpgradeableProxy(proxyAddr).upgradeToAndCall{value: 0}(
            implementation,
            data
        );
    }

    function approve(
        address token,
        address spender,
        uint256 amount
    ) public virtual onlyOwner {
        require(token != address(0), "Token address cannot be zero");
        require(spender != address(0), "Spender address cannot be zero");

        bool success = IERC20(token).approve(spender, amount);
        require(success, "Token approve failed");
    }
}
