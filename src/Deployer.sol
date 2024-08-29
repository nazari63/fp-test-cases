// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Deployer {
  constructor(uint256 n) {
    for (uint256 i = 0; i < n; i++) {
      new Junk();
    }
  }
}

contract Junk {
  constructor() {}
}