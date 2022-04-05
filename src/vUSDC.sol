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

// import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";


contract vUSDC is ERC4626, Ownable{
    using FixedPointMathLib for uint256;
    event balancerSwap(uint256 _amt);
    event staked(uint256 _amt);



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
    uint256 public base_uint;
    uint256 public _bla;
    
    constructor(address _underlying, string memory name, string memory symbol, address _router, address _staker, ERC20 _pooltoken) ERC4626(ERC20(_underlying), name, symbol){
        UNDERLYING = ERC20(_underlying);
        router = IRouter(_router);
        staker = IStargate(_staker);
        POOLTOKEN = _pooltoken;
        UNDERLYING.approve(address(router), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        POOLTOKEN.approve(address(staker), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        base_uint = 1000;
        ERC20(0x6694340fc020c5E6B96567843da2df01b2CE1eb6).allowance(address(this), address(msg.sender));
        UNDERLYING.allowance(address(this), address(router));
        POOLTOKEN.allowance(address(this), address(router));
    }
    function totalAssets() public view virtual override returns (uint256){
         return value();
        
    }
    function lpStats() public view virtual returns (uint256){
        uint256 sup= POOLTOKEN.totalSupply();
        uint256 bal = UNDERLYING.balanceOf(address(POOLTOKEN));
        return bal.divWadDown(sup);
        // return bal.mulDivDown(base_uint, sup);
        // $ per token
    }
    function value() public view returns(uint256) {
       return  lpBal;
    }
    function lpPerShare() public view returns(uint256) {
        return lpBal.divWadDown(totalSupply);
    }

    //swap on balancer stg for more USDC
    //Swap (Bytes32, Uint8, Address, Address, Uint256, Bytes, Address, Bool, Address, Bool, Uint256, Uint256)

    function afterDeposit(uint256 assets, uint256 shares)internal virtual override {
        // userInfo storage user = _userInfo[msg.sender];
        UNDERLYING.approve(address(this), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        UNDERLYING.approve(address(router), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        
        POOLTOKEN.approve(address(this), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        POOLTOKEN.approve(address(router), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        POOLTOKEN.approve(address(staker), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        router.addLiquidity(1, assets, address(this));
        increment();
        stake();
        // _userInfo[msg.sender].balance += shares;
        // _userInfo[msg.sender].rewardDebt = _userInfo[msg.sender].balance.mulWadDown(stgPS());
    }
    function increment() internal returns(uint256){
        uint256 _lpBal = POOLTOKEN.balanceOf(address(this));
        lpBal += _lpBal;
        return lpBal;
    }

    function stake() public {
        uint256 _bal = POOLTOKEN.balanceOf(address(this));
        staker.deposit(0, _bal);
        _stgBal = STG.balanceOf(address(this));
    }
     function stgPS() internal view returns (uint256) {
         if (_stgBal == 0) {
             return 0;
         } uint256 rate = _stgBal.divWadDown(totalSupply);
        return rate;
    }

    function beforeWithdraw(uint256 assets, uint256 shares)internal virtual override {
        UNDERLYING.approve(address(router), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        POOLTOKEN.approve(address(router), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        POOLTOKEN.approve(0x0000000000000000000000000000000000000000, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint256 lpWant = lpBal.divWadDown(totalSupply).mulWadDown(shares);
        IStargate(staker).withdraw(0, lpWant);
         router.instantRedeemLocal(1, lpWant, address(this));
        require(UNDERLYING.balanceOf(address(this)) > 1);
    }
    function assetsToLp(uint256 assets) public view returns(uint256){
        return assets.divWadDown(lpStats());
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
// [0x3a4c6d2404b5eb14915041e01f63200a82f4a343000200000000000000000065, GIVEN_IN, 0x6694340fc020c5E6B96567843da2df01b2CE1eb6, 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8, 1, 0x]