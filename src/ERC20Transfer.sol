// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor() ERC20("Token", "TKN") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}

contract ERC20Transfer {
    constructor(uint256 gas_target, address to) {
        Token token = new Token();
        uint256 start_gas = gasleft();
        uint256 gas_used = 0;

        while (gas_used < gas_target) {
            token.transfer(to, 1 wei);
            gas_used = start_gas - gasleft();
        }
    }
}
