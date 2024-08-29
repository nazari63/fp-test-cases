// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Deployer} from "../src/Deployer.sol";

contract DeployerScript is Script {
    Deployer public deployer;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        deployer = new Deployer(100);

        vm.stopBroadcast();
    }
}
