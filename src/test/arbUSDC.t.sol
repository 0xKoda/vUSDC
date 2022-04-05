// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "ds-test/test.sol";
import {vUSDC} from "../vUSDC.sol";
import "foundry-playground/ERC20TokenFaker.sol";
import "foundry-playground/FakeERC20.sol";
import "solmate/tokens/ERC20.sol";
import "solmate/mixins/ERC4626.sol";
import {IStargate} from "../interfaces/IStargate.sol";

interface Vm {
    function warp(uint256 x) external;
    function expectRevert(bytes calldata) external;
    function roll(uint256) external;
    function prank(address) external;
}

contract vUSDCtest is DSTest, ERC20TokenFaker {
    uint256 count;
    vUSDC vusd;
    FakeERC20 fakeUSDC;
    ERC20 UNDERLYING;
    FakeERC20 fakeSTG;
     Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    


function setUp() public {
   
    fakeUSDC = fakeOutERC20(address(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8));
    fakeUSDC._setBalance(address(this), 1e18);
    vusd = new vUSDC(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8, "vault", "vlt", 0x53Bf833A5d6c4ddA888F69c22C88C9f356a41614, 0xeA8DfEE1898a7e0a59f7527F076106d7e44c2176, ERC20(0x892785f33CdeE22A30AEF750F285E18c18040c3e));
    vusd.setFee(10);
    vusd.setFeeCollector(address((this)));
   
    vusd.setsPID(0);
    vusd.setPID(1);
    ERC20(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8).approve(address(vusd), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    ERC20(0x892785f33CdeE22A30AEF750F285E18c18040c3e).approve(address(this), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    ERC20(0x892785f33CdeE22A30AEF750F285E18c18040c3e).approve(address(vusd), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    ERC20(0x892785f33CdeE22A30AEF750F285E18c18040c3e).approve(0xeA8DfEE1898a7e0a59f7527F076106d7e44c2176, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    ERC20(0x6694340fc020c5E6B96567843da2df01b2CE1eb6).approve(address(vusd), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    ERC20(0x6694340fc020c5E6B96567843da2df01b2CE1eb6).approve(address(this), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    ERC20(0x6694340fc020c5E6B96567843da2df01b2CE1eb6).approve(0x53Bf833A5d6c4ddA888F69c22C88C9f356a41614, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    vusd.deposit(1000000000, address(this));
}
function testInitialBalance() public {
    assertEq(1000000000, vusd.balanceOf(address(this)));
}
// test whole deposit flow
function testDeposit() public {
    uint256 bal = vusd.balanceOf(address(this));
    vusd.deposit(1000000, address(this));
    //  assert(vusd.balanceOf(address(this)) > 1);
    assert(vusd.balanceOf(address(this))  > bal);
    emit log("deposit");
}


// test just reciept of LP tokens (comment out stake)
// function testLP() public {
//     ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48).approve(address(vusd), 10000000000000);
//     vusd.approve(address(vusd), 10000000000000);
//     ERC20(0xdf0770dF86a8034b3EFEf0A1Bb3c889B8332FF56).approve(address(vusd), 10000000000000);
//     vusd.deposit(100000000, address(this));
//     assert(ERC20(0xdf0770dF86a8034b3EFEf0A1Bb3c889B8332FF56).balanceOf(address(vusd)) >= 1);
// }
// // test reciept of stg tokens on deposit fast forward
function testStg() public {
    vusd.deposit(1000000000000, address(this));
    vusd.stake();
    // assert(vusd.balanceOf(address(this)) > 1);
    // vm.warp(7 days);
    // vusd.deposit(10000, address(this));
    vm.roll(9323393);
    vusd.deposit(1000, address(this));
    vusd.stake();
   assert(ERC20(0x6694340fc020c5E6B96567843da2df01b2CE1eb6).balanceOf(address(vusd)) > 0);
}
//change withdraw logic so assets are representing staked balance
function testWithdraw() public {
    vusd.withdraw(10000000, address(this), address(this));
    emit log("withdraw");
}
function testLPStats() public {
    assert(vusd.lpStats() >0);
}

// function testCompound() public {
//     fakeSTG = fakeOutERC20(address(0x6694340fc020c5E6B96567843da2df01b2CE1eb6));
//     fakeSTG._setBalance(address(vusd), 1000000000000000);
//     uint256 _pb = vusd.lpBal();
//     vusd.compound();
//     uint256 _nb = vusd.lpBal();
//     assert(_nb > _pb);
// }

}
