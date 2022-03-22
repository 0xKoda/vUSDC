    // SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

interface IStargate  {
    function deposit(uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
}