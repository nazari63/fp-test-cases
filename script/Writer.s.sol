// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Writer} from "../src/Writer.sol";

contract WriterScript is Script {
    Writer public writer;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        writer = new Writer(500);

        vm.stopBroadcast();
    }
}
