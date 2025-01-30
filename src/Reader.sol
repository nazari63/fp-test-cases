// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Reader {
    constructor(uint256 gas_target) {
        uint256 start_gas = gasleft();
        uint256 gas_used = 0;

        while (gas_used < gas_target) {
            assembly {
                let junk := sload(gas_used)
            }
            gas_used = start_gas - gasleft();
        }
    }
}
