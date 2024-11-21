// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {ProxyAdmin} from "../proxy/ProxyAdmin.sol";

import {MutableERC20Proxy} from "../proxy/MutableERC20Proxy.sol";
import {MutableERC20V2} from "./MutableERC20V2.sol";

contract MutableERC20V2Upgrader is Ownable {
    MutableERC20Proxy public immutable proxy;
    ProxyAdmin public immutable proxyAdmin;

    MutableERC20V2 public immutable newImplementation;

    address public immutable proxyAdminOwner;
    uint256 public immutable totalSupply;

    string private _newName;
    string private _newSymbol;
    constructor(
        MutableERC20Proxy proxy_,
        ProxyAdmin proxyAdmin_,
        string memory newName_,
        string memory newSymbol_,
        uint256 totalSupply_
    ) Ownable(_msgSender()) {
        proxy = proxy_;
        proxyAdmin = proxyAdmin_;
        newImplementation = new MutableERC20V2();
        proxyAdminOwner = proxyAdmin.owner();
        _newName = newName_;
        _newSymbol = newSymbol_;
        totalSupply = totalSupply_;
    }

    function upgrade() external onlyOwner {
        // Ensure this contract is the owner of the ProxyAdmin
        require(proxyAdmin.owner() == address(this), "Invalid admin address");
        require(
            proxy.admin() == address(proxyAdmin),
            "Invalid proxy admin address"
        );

        // Upgrade and initialize
        proxyAdmin.upgradeAndCall(
            address(proxy),
            address(newImplementation),
            abi.encodeWithSelector(
                MutableERC20V2.initializeV2.selector,
                _newName,
                _newSymbol,
                totalSupply
            )
        );

        // Verify name and symbol
        require(
            keccak256(abi.encode(IERC20Metadata(address(proxy)).name())) ==
                keccak256(abi.encode(_newName)),
            "Invalid name after upgrade"
        );

        require(
            keccak256(abi.encode(IERC20Metadata(address(proxy)).symbol())) ==
                keccak256(abi.encode(_newSymbol)),
            "Invalid symbol after upgrade"
        );

        // Check total supply balance
        uint256 balance = IERC20(address(proxy)).balanceOf(address(proxyAdmin));
        require(balance == totalSupply, "Wrong total supply after upgrade");

        // Check allowance before approval
        uint256 initialAllowance = IERC20(address(proxy)).allowance(
            address(proxyAdmin),
            address(this)
        );
        require(initialAllowance == 0, "Initial allowance is not zero");

        // Approve full balance to this contract
        bool approvalSuccess = proxyAdmin.approve(
            address(proxy),
            address(this),
            balance
        );
        require(approvalSuccess, "Approval failed");

        // Check allowance after approval
        uint256 updatedAllowance = IERC20(address(proxy)).allowance(
            address(proxyAdmin),
            address(this)
        );
        require(
            updatedAllowance == balance,
            "Allowance after approval is incorrect"
        );

        // Transfer balance to proxyAdminOwner
        bool transferSuccess = IERC20(address(proxy)).transferFrom(
            address(proxyAdmin),
            proxyAdminOwner,
            balance
        );
        require(transferSuccess, "Transfer to proxyAdminOwner failed");

        // Ensure allowance is consumed
        uint256 finalAllowance = IERC20(address(proxy)).allowance(
            address(proxyAdmin),
            address(this)
        );
        require(finalAllowance == 0, "Allowance was not fully consumed");
        _tearDown();
    }

    function tearDown() public onlyOwner {
        _tearDown();
    }

    function _tearDown() internal {
        if (proxyAdmin.owner() == address(this)) {
            proxyAdmin.transferOwnership(proxyAdminOwner);
        }
        uint256 balance = IERC20(address(proxy)).balanceOf(address(this));
        if (balance > 0) {
            IERC20(address(proxy)).transfer(proxyAdminOwner, balance);
        }
        selfdestruct(payable(_msgSender()));
    }

    function newName() external view returns (string memory) {
        return _newName;
    }

    function newSymbol() external view returns (string memory) {
        return _newSymbol;
    }
}
