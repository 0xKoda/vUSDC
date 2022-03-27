// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;
import {ERC4626} from "solmate/mixins/ERC4626.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {IStargate} from "./interfaces/IStargate.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";
import {IRouter} from "./interfaces/IRouter.sol";
// import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";

contract vUSDC is ERC4626, Ownable{
    using FixedPointMathLib for uint256;
    using SafeTransferLib for ERC20;

    //usdc
    ERC20 public UNDERLYING;
    //pUSDC
    ERC20 public POOLTOKEN;
    //stg token
    ERC20 public STG;
    //stg contract, import interface
    IStargate public staker;
    //fee collector
    address public  feeCollector;
    //stargate pool ID (usd = 1)
    uint256 public pID;
    //stargate pool ID (usd = 0)
    uint256 public spID;
    //router
    IRouter public router;
    //deposit fee
    uint256 public fee;
    uint256 public _stgBal;
    uint256 public lpBal;
    address public gov;
    constructor(address _underlying, string memory name, string memory symbol, address _router, address _staker, ERC20 _pooltoken) ERC4626(ERC20(_underlying), name, symbol){
        UNDERLYING = ERC20(_underlying);
        router = IRouter(_router);
        staker = IStargate(_staker);
        POOLTOKEN = _pooltoken;
        UNDERLYING.approve(address(router), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        POOLTOKEN.approve(address(staker), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    }
    function totalAssets() public view virtual override returns (uint256){
        return UNDERLYING.balanceOf(address(this)) + value();
    }
    function lpStats() public view virtual returns (uint256){
        uint256 sup= POOLTOKEN.totalSupply();
        uint256 bal = UNDERLYING.balanceOf(address(POOLTOKEN));
        return bal / sup;
        // $ per token
    }
    function value() public view returns(uint256) {
       return  lpBal * lpStats();
    }
    function lpPerShare() public view returns(uint256) {
        return lpBal / totalSupply;
    }

    function afterDeposit(uint256 assets, uint256 shares)internal virtual override {
        UNDERLYING.approve(address(router), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        router.addLiquidity(1, assets, address(this));
        uint256 _lpBal = ERC20(0xdf0770dF86a8034b3EFEf0A1Bb3c889B8332FF56).balanceOf(address(this));
        lpBal += _lpBal;
        POOLTOKEN.approve(address(this), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        stake();
    }

    function stake() public {
        uint256 _bal = POOLTOKEN.balanceOf(address(this));
        staker.deposit(0, _bal);
        _stgBal = ERC20(0xAf5191B0De278C7286d6C7CC6ab6BB8A73bA2Cd6).balanceOf(address(this));
    }
    function beforeWithdraw(uint256 assets, uint256 shares)internal virtual override {
        uint256 _amount = lpPerShare().mulDivDown(shares, 1e12);
        uint256 lpps = lpBal.mulDivDown(1e12, totalSupply);
        uint256 _amt = lpps.mulWadDown(shares);
        //fix this, asstes count should be staked balance
        IStargate(staker).withdraw(pID, _amount);
        lpBal -= _amt;
        uint256 priorBal = UNDERLYING.balanceOf(address(this));
        IRouter(router).instantRedeemLocal(pID, _amt, address(this));
        uint256 newBal = UNDERLYING.balanceOf(address(this));
    }
    function setFee(uint256 _fee)public onlyOwner{
        fee = _fee;
    }
    function setPID(uint256 _pID)public onlyOwner{
        pID = _pID;
    }
    function setsPID(uint256 _spID)public onlyOwner{
        spID = _spID;
    }
    function setPoolToken(ERC20 _poolToken)public onlyOwner{
        POOLTOKEN = _poolToken;
    }
    function setStaker(address _staker)public onlyOwner{
        staker = IStargate(_staker);
    }
    function setSTG(ERC20 _stg)public onlyOwner{
        STG = _stg;
    }
    function setFeeCollector(address _feeCollector)public onlyOwner{
        feeCollector = _feeCollector;
    }
    function setRouter(address _router)public onlyOwner{
        router = IRouter(_router);
    }
    modifier onlyGov {
        if(msg.sender != gov) revert();
        _;
    }
    function setGov(address _gov)public onlyOwner{
        gov = _gov;
    }
}
