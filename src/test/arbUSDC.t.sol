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

// Arbitrum Vault testing
contract vUSDCtest is DSTest, ERC20TokenFaker {
    uint256 count;
    vUSDC vusd;
    FakeERC20 fakeUSDC;
    FakeERC20 fakeSTG;
    ERC20 UNDERLYING;
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
// Fake out STG tokens and USDC
function setUp() public {
    fakeUSDC = fakeOutERC20(address(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8));
    fakeUSDC._setBalance(address(this), 1e18);
    vusd = new vUSDC(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8, "vault", "vlt", 0x53Bf833A5d6c4ddA888F69c22C88C9f356a41614, 0xeA8DfEE1898a7e0a59f7527F076106d7e44c2176, ERC20(0x892785f33CdeE22A30AEF750F285E18c18040c3e));
    vusd.setFee(10);
    vusd.setFeeCollector(address((this)));
    vusd.setSTG(ERC20(0x6694340fc020c5E6B96567843da2df01b2CE1eb6));
    vusd.setsPID(0);
    vusd.setPID(1);
    ERC20(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8).approve(address(vusd), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    ERC20(0x892785f33CdeE22A30AEF750F285E18c18040c3e).approve(address(this), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    ERC20(0x892785f33CdeE22A30AEF750F285E18c18040c3e).approve(address(vusd), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    ERC20(0x892785f33CdeE22A30AEF750F285E18c18040c3e).approve(0xeA8DfEE1898a7e0a59f7527F076106d7e44c2176, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    ERC20(0x6694340fc020c5E6B96567843da2df01b2CE1eb6).approve(address(vusd), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    vusd.deposit(1000000000, address(this));
    fakeSTG = fakeOutERC20(address(0x6694340fc020c5E6B96567843da2df01b2CE1eb6));
    fakeSTG._setBalance(address(vusd), 1000000000000000000);
}
function testInitialBalance() public {
    assert(1000000000 == UNDERLYING.balanceOf(address(vusd)));
}

function testDeposit() public {
    vusd.deposit(1000000, address(this));
    assert(vusd.balanceOf(address(this))  > 0);
    emit log("deposit");
}

// test just reciept of LP tokens (comment out stake or will fail)
function testLP() public {
    ERC20(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8).approve(address(vusd), 10000000000000);
    vusd.approve(address(vusd), 10000000000000);
    ERC20(0x892785f33CdeE22A30AEF750F285E18c18040c3e).approve(address(vusd), 10000000000000);
    vusd.deposit(100000000, address(this));
    assert(ERC20(0x892785f33CdeE22A30AEF750F285E18c18040c3e).balanceOf(address(vusd)) >= 1);
}
// test reciept of stg tokens on deposit fast forward, fork previous block
function testStg() public {
    vusd.deposit(1000, address(this));
    vm.roll(9318202);
    vusd.deposit(1000, address(this));
   assert(ERC20(0x6694340fc020c5E6B96567843da2df01b2CE1eb6).balanceOf(address(vusd)) > 0);
}
//change withdraw logic so assets are representing staked balance
function testWithdraw() public {
    vusd.deposit(10000, address(this));
    uint256 bal = UNDERLYING.balanceOf(address(this));
    vusd.withdraw(10000000, address(this), address(this));
    emit log("withdraw");
    // assert(UNDERLYING.balanceOf(address(this)) == bal + 10000000);
}

function testLPStats() public {
    assert(vusd.lpStats() >0);
}

function testCompound() public {
    uint256 _pb = vusd.lpBal();
    vusd.compound();
    uint256 _nb = vusd.lpBal();
    assert(_nb > _pb);
}
}