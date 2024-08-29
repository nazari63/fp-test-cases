// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Reader} from "../src/Reader.sol";

contract ReaderScript is Script {
    Reader public reader;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        reader = new Reader(5000);

        vm.stopBroadcast();
    }
}
