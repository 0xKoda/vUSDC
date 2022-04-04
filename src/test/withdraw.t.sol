// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.10;

// import "ds-test/test.sol";
// import {vUSDC} from "../vUSDC.sol";
// import {vUSDCtest} from "./vUSDC.t.sol";
// import "foundry-playground/ERC20TokenFaker.sol";
// import "solmate/tokens/ERC20.sol";
// contract withdrawtest is DSTest, ERC20TokenFaker{
//     vUSDC vusd;
//     vUSDCtest vusdtest;
//     function setUp() public {
//         vusd = new vUSDC(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, "vault", "vlt", 0x8731d54E9D02c286767d56ac03e8037C07e01e98, 0xB0D502E938ed5f4df2E681fE6E419ff29631d62b, ERC20(0xdf0770dF86a8034b3EFEf0A1Bb3c889B8332FF56));
//         vusd.setFee(10);
//         vusd.setFeeCollector(address((this)));
//         ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48).approve(address(vusd), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
//         ERC20(0xdf0770dF86a8034b3EFEf0A1Bb3c889B8332FF56).approve(address(this), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
//         vusd.setStaker(0xB0D502E938ed5f4df2E681fE6E419ff29631d62b);
//         vusd.setRouter(0x8731d54E9D02c286767d56ac03e8037C07e01e98);
//         vusd.setsPID(0);
//         vusd.setPID(1);
//         FakeERC20 fakeUSDC = fakeOutERC20(address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48));
//         fakeUSDC._setBalance(address(this), 1e18);
//         vusd.deposit(10000, address(this));
// }
// // function dep() public {
// //     vusd.deposit(10000, address(this));
// // }

// function testW() public {
//     vusd.withdraw( 10000, address(this), address(this));
//     assert(vusd.balanceOf(address(this)) == 0);
// }
// }