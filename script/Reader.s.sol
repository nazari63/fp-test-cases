// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Reader} from "../src/Reader.sol";

contract ReaderScript is Script {
    Reader public reader;

    function setUp() public {}

    function run(uint256 gas_target) public {
        vm.startBroadcast();

        reader = new Reader(gas_target);

        vm.stopBroadcast();
    }
}
