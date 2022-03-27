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
    // user info stores reward debt and balance of shares
    struct userInfo{
        uint256 balance;
        uint256 rewardDebt;
    }
    //usdc
    ERC20 public UNDERLYING;
    //pUSDC
    ERC20 public POOLTOKEN;
    //stg rewards
    ERC20 public STG;
    //stg contract, import interface
    IStargate public staker;
    //fee collector
    address public  feeCollector;
    //stargate pool ID (usd = 1)
    uint256 public pID;
    //stargate pool ID (usd = 0)
    uint256 public spID;
    //user info for rewards
    mapping(address => userInfo) public _userInfo;
    //router
    IRouter public router;
    //deposit fee
    uint256 public fee;
    // address public _owner;
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
    // constructor(ERC20 _asset) ERC4626(_asset, "vault", "vUSDC") {
    //     UNDERLYING = _asset;
    // }
    // constructor(ERC20 asset) ERC4626(_underlying,  "vault",  "vUSD"){
    //     UNDERLYING = _underlying;
    //     _owner = msg.sender;

    // }
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
        // UNDERLYING.allowance(address(this), address(this));
        // STG.allowance(address(this), address(this));
        // POOLTOKEN.allowance(address(this), address(this));
        // ERC20(0xdf0770dF86a8034b3EFEf0A1Bb3c889B8332FF56).approve(address(staker), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        // userInfo storage user = _userInfo[msg.sender];
        // uint256 _fee = assets.mulWadDown(fee);
        // UNDERLYING.transferFrom(msg.sender, feeCollector, _fee);
        // assets -= _fee;
        // shares = convertToShares(assets);
        // uint256 balance = convertToShares(assets - _fee );
        
        // POOLTOKEN.approve(address(this), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        // uint256 _bal = POOLTOKEN.balanceOf(address(this));
        // staker.deposit(0, _bal);
        
    }
        // _stgBal = ERC20(0xAf5191B0De278C7286d6C7CC6ab6BB8A73bA2Cd6).balanceOf(address(this));

        // if(user.balance > 0){
        //     uint256 pending =  user.balance.mulWadDown(stgPS()) - user.rewardDebt;
        //     STG.transferFrom(address(this), msg.sender, pending);
        //     }
        // user.balance += shares;
        // user.rewardDebt = user.balance.mulWadDown(stgPS());

    function stake() public {
        uint256 _bal = POOLTOKEN.balanceOf(address(this));
        staker.deposit(0, _bal);
        _stgBal = ERC20(0xAf5191B0De278C7286d6C7CC6ab6BB8A73bA2Cd6).balanceOf(address(this));
    }
    function stgPS() internal view returns (uint256) {
        uint256 rate = STG.balanceOf(address(this)).mulDivDown(1e12, totalSupply);
        return rate;
    }
    function ptBal() public view returns (uint256) {
        return STG.balanceOf(address(this));
    }
    function recFee() public view returns onlyGov (uint256) {
        return fee;
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
        // uint256 _want = priorBal - newBal;
        //design new contract for strategy. makes deposit logic easier. 
        // userInfo storage user = _userInfo[msg.sender];
        // uint256 pending =  user.balance.mulWadDown(stgPS()) - user.rewardDebt;
        // STG.transferFrom(address(this), msg.sender, pending);
        // STG.transferFrom(address(this), msg.sender, ERC20(0xAf5191B0De278C7286d6C7CC6ab6BB8A73bA2Cd6).balanceOf(address(this)));
        // user.balance -= shares;
        // user.rewardDebt = user.balance.mulWadDown(stgPS());
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
        if(msg.sender != gov) throw;
        _;
    }
    function setGov(address _gov)public onlyOwner{
        gov = _gov;
    }
}
