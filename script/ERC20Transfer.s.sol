// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ERC20Transfer} from "../src/ERC20Transfer.sol";

contract ERC20TransferScript is Script {
    ERC20Transfer public transfer;

    function setUp() public {}

    function run(uint256 gas_target, address to) public {
        vm.startBroadcast();

        transfer = new ERC20Transfer(gas_target, to);

        vm.stopBroadcast();
    }
}
