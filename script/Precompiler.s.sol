// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Precompiler} from "../src/Precompiler.sol";

contract PrecompilerScript is Script {
    Precompiler public precompiler;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        precompiler = new Precompiler(0x100, 5000);

        vm.stopBroadcast();
    }
}
