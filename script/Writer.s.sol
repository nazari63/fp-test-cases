// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Writer} from "../src/Writer.sol";

contract WriterScript is Script {
    Writer public writer;

    function setUp() public {}

    function run(uint256 gas_target) public {
        vm.startBroadcast();

        writer = new Writer(gas_target);

        vm.stopBroadcast();
    }
}
