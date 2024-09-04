// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Transfer {
    constructor(uint256 gas_target, address to) {
        uint256 start_gas = gasleft();
        uint256 gas_used = 0;

        while (gas_used < gas_target) {
            payable(to).transfer(1 wei);
            gas_used = start_gas - gasleft();
        }
    }
}
