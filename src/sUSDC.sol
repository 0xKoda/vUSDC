// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;
import {ERC4626} from "solmate/mixins/ERC4626.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {IStargate} from "./interfaces/IStargate.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";
import {IRouter} from "./interfaces/IRouter.sol";
 import {IAsset, IBalancer} from "./interfaces/IBalancer.sol";

contract sUSDC is ERC4626, Ownable{
    ERC20 public UNDERLYING;
    //pUSDC
    ERC20 public POOLTOKEN;
    IRouter public router;
    IStargate public staker;
    uint256 public poolId;
    address public vault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    bytes32 public balancerPool;
    ERC20 public STG;

    // Underluying is sUSDC pool token
    constructor(address _underlying, string memory name, string memory symbol, address _router, address _staker, ERC20 _pooltoken) ERC4626(ERC20(_underlying), name, symbol){
        UNDERLYING = ERC20(_underlying);
        router = IRouter(_router);
        staker = IStargate(_staker);
        POOLTOKEN = _pooltoken;
        UNDERLYING.approve(address(router), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        POOLTOKEN.approve(address(staker), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    }
    function balanceOfPool() public view returns (uint256) {
        (uint256 amount, ) = staker.userInfo(
            poolId,
            address(this)
        );
        return amount;
    }
    function totalAssets() public view override returns (uint256){
        return balanceOfPool();
    }
    function afterDeposit(uint256 assets, uint256 shares) internal virtual override {
        staker.deposit(
            poolId,
            assets
        );
        compound();
    }
    function beforeWithdraw(uint256 assets, uint256 shares) internal virtual override {
        staker.withdraw(
            poolId,
            assets
        );
    }
    function compound() internal {
        uint256 _stg = STG.balanceOf(address(this));
        if(_stg > 10000000000000000000){
         IBalancer.SingleSwap memory swapParams = IBalancer
            .SingleSwap({
                poolId: balancerPool,
                kind: IBalancer.SwapKind.GIVEN_IN,
                //STG token
                assetIn: IAsset(0xAf5191B0De278C7286d6C7CC6ab6BB8A73bA2Cd6),
                //USDC
                assetOut: IAsset(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48),
                amount: _stg,
                userData: "0x"
            });
        IBalancer.FundManagement memory funds = IBalancer
            .FundManagement({
                sender: address(this),
                recipient: payable(address(this)),
                fromInternalBalance: false,
                toInternalBalance: false
            });
        IBalancer(vault).swap(swapParams, funds, 1, block.timestamp + 60);

        uint256 _underlying = ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48).balanceOf(address(this));

        // Deposit stablecoin liquidity
        router.addLiquidity(
            1,
            _underlying,
            address(this)
        );

        _deposit();
    } return;
        }
    function _deposit() internal {
        staker.deposit(poolId, UNDERLYING.balanceOf(address(this)));
    }
}