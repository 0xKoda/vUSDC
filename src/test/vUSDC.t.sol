// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../vUSDC.sol";
import "foundry-playground/ERC20TokenFaker.sol";
import "foundry-playground/FakeERC20.sol";
import "solmate/tokens/ERC20.sol";
import "solmate/mixins/ERC4626.sol";
// // import "./blacksmith/vUSDC.bs.sol";
// import "./blacksmith/Blacksmith.sol";
// import "./blacksmith/IRouter.bs.sol";
// import "./blacksmith/IStargate.bs.sol";

// import "openzeppelin/token/ERC20/IERC20.sol";
interface Vm {
    function warp(uint256 x) external;
    function expectRevert(bytes calldata) external;
    function roll(uint256) external;
}

// interface CheatCodes {
//     function roll(uint256) external;
//     function warp(uint256) external;
//     function prank(address) external;
//     function expectRevert(bytes calldata) external;
//     function deal(address who, uint256 newBalance) external;
// }

contract vUSDCtest is DSTest, ERC20TokenFaker {
    uint256 count;
    vUSDC vusd;
    FakeERC20 fakeUSDC;
    ERC20 UNDERLYING;
    // CheatCodes constant cheats = CheatCodes(HEVM_ADDRESS);
    Vm vm =Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);


function setUp() public {
    fakeUSDC = fakeOutERC20(address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48));
    fakeUSDC._setBalance(address(this), 1e18);
    vusd = new vUSDC(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, "vault", "vlt", 0x8731d54E9D02c286767d56ac03e8037C07e01e98, 0xB0D502E938ed5f4df2E681fE6E419ff29631d62b, ERC20(0xdf0770dF86a8034b3EFEf0A1Bb3c889B8332FF56));
    vusd.setFee(10);
    vusd.setFeeCollector(address((this)));
    // vusd.setStaker(0xB0D502E938ed5f4df2E681fE6E419ff29631d62b);
    // vusd.setRouter(0x8731d54E9D02c286767d56ac03e8037C07e01e98);
    // vusd.setSTG(ERC20(0xAf5191B0De278C7286d6C7CC6ab6BB8A73bA2Cd6));
    vusd.setsPID(0);
    vusd.setPID(1);
    // ERC20(0xAf5191B0De278C7286d6C7CC6ab6BB8A73bA2Cd6).approve(address(0xdf0770dF86a8034b3EFEf0A1Bb3c889B8332FF56), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    // ERC20(0xAf5191B0De278C7286d6C7CC6ab6BB8A73bA2Cd6).approve(address(0xB0D502E938ed5f4df2E681fE6E419ff29631d62b), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48).approve(address(vusd), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    // vusd.approve(address(v), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    ERC20(0xdf0770dF86a8034b3EFEf0A1Bb3c889B8332FF56).approve(address(this), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    ERC20(0xdf0770dF86a8034b3EFEf0A1Bb3c889B8332FF56).approve(address(vusd), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    ERC20(0xdf0770dF86a8034b3EFEf0A1Bb3c889B8332FF56).approve(0xB0D502E938ed5f4df2E681fE6E419ff29631d62b, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    // ERC20(0xAf5191B0De278C7286d6C7CC6ab6BB8A73bA2Cd6).allowance(address(vusd), address(vusd));
    // ERC20(0xAf5191B0De278C7286d6C7CC6ab6BB8A73bA2Cd6).allowance(0xB0D502E938ed5f4df2E681fE6E419ff29631d62b, 0xB0D502E938ed5f4df2E681fE6E419ff29631d62b);
 
}
function testInitialBalance() public {
    assertEq(0, vusd.balanceOf(address(this)));
}
// test whole deposit flow
function testDeposit() public {
    vusd.deposit(100000000, address(this));
    assert(vusd.balanceOf(address(this)) > 1);
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
    // uint256 _time = block.timestamp + 90480;
    // cheats.deal(address(this), 1e18);
    vusd.deposit(1000000000000000000, address(this));
    // vm.warp(7 days);
    // vusd.deposit(10000, address(this));
    vm.roll(14446759);
    vusd.deposit(0, address(this));
    assert(ERC20(0xAf5191B0De278C7286d6C7CC6ab6BB8A73bA2Cd6).balanceOf(address(vusd)) > 1);
}








    // vusd.setPoolToken(ERC20(0xdf0770dF86a8034b3EFEf0A1Bb3c889B8332FF56));


    // Blacksmith base = new Blacksmith(0xDC539c8F693da965C5AaAFEf36E4eA233BF2E567);
    // IRouterBS = new IRouter();
    // IStargateBS = new IStargate();
    // User alice = createUser(address(0), 111);  // addrss will be 0x052b91ad9732d1bce0ddae15a4545e5c65d02443
    // bob = createUser(address(111), 0);  // address will be 0x000000000000000000000000000000000000006f
    // eve = createUser(address(0), 0);  // address will be 0x0000000000000000000000000000000000000000


    // CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
    // ERC20 token = ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    

    // ERC20 stgToken = ERC20(0xAf5191B0De278C7286d6C7CC6ab6BB8A73bA2Cd6);
    // ERC20 usdcToken;
    // address _feeCollector = address(2);
    // address _router = 0x8731d54E9D02c286767d56ac03e8037C07e01e98;
    // ERC20 underlying = ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    // ERC20 pooltoken = ERC20(0xdf0770dF86a8034b3EFEf0A1Bb3c889B8332FF56);
    // uint8 _pID = 1;
    // uint256 _fee = 0;
    // address _stargate = 0xB0D502E938ed5f4df2E681fE6E419ff29631d62b;

//     function setUp() public {

//         // count = 1;
//         // cheats.deal(address(this), 1000000000000000000);
//         vusd = new vUSDC(ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48));
//         // underlying = new ERC20( "tUSDC", "USDC", 6);
//         //usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
//         // faker = new ERC20TokenFaker();
        

        
//         // assert(fakeUSDC.balanceOf(address(this)) >= 1e18 ); // => 1e18
       
        
           
// }

//     function testOwner() public {
                // vusd = new vUSDC(ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48));
    // fakeUSDC = fakeOutERC20(address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48));
    // FakeERC20 fakeToken = fakeOutERC20(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
    // fakeToken._setBalance(address(this), 1e18);
   
    // assert(fakeUSDC.balanceOf(address(this)), 1e18);
        
//     }
}
