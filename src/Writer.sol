// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Writer {
  uint256[10000] junk;

  constructor(uint256 n) {
    for (uint256 i = 0; i < n; i++) {
      junk[i] = i;
    }
  }
}