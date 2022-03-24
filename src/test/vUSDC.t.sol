// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../vUSDC.sol";
import "foundry-playground/ERC20TokenFaker.sol";
import "foundry-playground/FakeERC20.sol";
import "solmate/tokens/ERC20.sol";
import "solmate/mixins/ERC4626.sol";
import "./blacksmith/vUSDC.bs.sol";
import "./blacksmith/Blacksmith.sol";
import "./blacksmith/IRouter.bs.sol";
import "./blacksmith/IStargate.bs.sol";

// import "openzeppelin/token/ERC20/IERC20.sol";
// interface CheatCodes {
//   function prank(address) external;
//   function expectRevert(bytes calldata) external;
//   function deal(address who, uint256 newBalance) external;
// }

contract vUSDCtest is DSTest, ERC20TokenFaker {
    uint256 count;
    vUSDC vusd;
    FakeERC20 fakeUSDC;

//     struct User {
//     address addr;  // to avoid external call, we save it in the struct
//     Blacksmith base;  // contains call(), sign(), deal()
//     IRouterBS router;  // interacts with FooToken contract
//     IStargateBS stargate;  // interacts with BarToken contract
// }

// function createUser(address _addr, uint256 _privateKey) public returns (User memory) {
//     Blacksmith base = new Blacksmith(_addr, _privateKey);
//     IRouterBS _router = new IRouterBS(_addr, _privateKey, address(0x8731d54E9D02c286767d56ac03e8037C07e01e98));
//     IStargateBS _stargate = new IStargateBS(_addr, _privateKey, address(0xB0D502E938ed5f4df2E681fE6E419ff29631d62b));
//     base.deal(100);
//     return User(base.addr(), base, _router, _stargate);
// }

function setUp() public {
    vusd = new vUSDC(ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48));
    // Blacksmith base = new Blacksmith(0xDC539c8F693da965C5AaAFEf36E4eA233BF2E567);
    // IRouterBS = new IRouter();
    // IStargateBS = new IStargate();
    // User alice = createUser(address(0), 111);  // addrss will be 0x052b91ad9732d1bce0ddae15a4545e5c65d02443
    // bob = createUser(address(111), 0);  // address will be 0x000000000000000000000000000000000000006f
    // eve = createUser(address(0), 0);  // address will be 0x0000000000000000000000000000000000000000
}
function test() public {
    fakeUSDC = fakeOutERC20(address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48));
    // FakeERC20 fakeToken = fakeOutERC20(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
    // fakeToken._setBalance(address(this), 1e18);
    fakeUSDC._setBalance(address(this), 1e18);
    // assert(fakeUSDC.balanceOf(address(this)), 1e18);
}
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
        
        
//     }
}
