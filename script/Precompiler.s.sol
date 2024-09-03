// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Precompiler} from "../src/Precompiler.sol";

contract PrecompilerScript is Script {
    Precompiler public precompiler;

    function setUp() public {}

    function run(uint256 index, uint256 gas_target) public {
        vm.startBroadcast();

        precompiler = new Precompiler(index, gas_target);

        vm.stopBroadcast();
    }
}
