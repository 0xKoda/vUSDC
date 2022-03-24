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
    address public staker;
    //fee collector
    address public  feeCollector;
    //stargate pool ID (usd = 1)
    uint256 public pID;
    //stargate pool ID (usd = 0)
    uint256 public spID;
    //user info for rewards
    mapping(address => userInfo) public _userInfo;
    //router
    address public router;
    //deposit fee
    uint256 public fee;
    // address public _owner;
   
    constructor(ERC20 _asset) ERC4626(_asset, "vault", "vUSDC") {
        UNDERLYING = _asset;
    }
    // constructor(ERC20 asset) ERC4626(_underlying,  "vault",  "vUSD"){
    //     UNDERLYING = _underlying;
    //     _owner = msg.sender;

    // }
    function totalAssets() public view virtual override returns (uint256){
        return UNDERLYING.balanceOf(address(this)) + UNDERLYING.balanceOf(staker);
    }

    function afterDeposit(uint256 assets, uint256 shares)internal virtual override {
        userInfo storage user = _userInfo[msg.sender];
        uint256 _fee = assets.mulWadDown(fee);
        UNDERLYING.transferFrom(msg.sender, feeCollector, _fee);
        assets -= _fee;
        shares = convertToShares(assets);
        uint256 balance = convertToShares(assets - _fee);
        UNDERLYING.approve(router, assets);
        IRouter(router).addLiquidity(pID, assets, msg.sender);
        POOLTOKEN.approve(staker, assets);
        IStargate(staker).deposit(pID, assets);
        if(user.balance > 0){
            uint256 pending =  user.balance.mulWadDown(stgPS()) - user.rewardDebt;
            STG.transferFrom(address(this), msg.sender, pending);
            }
        user.balance += balance;
        user.rewardDebt = user.balance.mulWadDown(stgPS());
    }

    function stgPS() internal view returns (uint256) {
        uint256 rate = STG.balanceOf(address(this)).mulDivDown(1e12, totalSupply);
        return rate;
    }
    function beforeWithdraw(uint256 assets, uint256 shares)internal virtual override {
        IStargate(staker).withdraw(pID, assets);
        IRouter(router).instantRedeemLocal(pID, assets, msg.sender);
        userInfo storage user = _userInfo[msg.sender];
        uint256 pending =  user.balance.mulWadDown(stgPS()) - user.rewardDebt;
        STG.transferFrom(address(this), msg.sender, pending);

        user.balance -= shares;
        user.rewardDebt = user.balance.mulWadDown(stgPS());
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
        staker = _staker;
    }
    function setSTG(ERC20 _stg)public onlyOwner{
        STG = _stg;
    }
    function setFeeCollector(address _feeCollector)public onlyOwner{
        feeCollector = _feeCollector;
    }
    function setRouter(address _router)public onlyOwner{
        router = _router;
    }
}
