// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Deployer {
    constructor(uint256 gas_target) {
        uint256 start_gas = gasleft();
        uint256 gas_used = 0;

        while (gas_used < gas_target) {
            new Junk();
            gas_used = start_gas - gasleft();
        }
    }
}

contract Junk {
    constructor() {}
}
