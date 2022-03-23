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
    ERC20 public immutable UNDERLYING;
    //pUSDC
    ERC20 public immutable POOLTOKEN;
    //stg rewards
    ERC20 public immutable STG;
    //stg contract, import interface
    address public immutable stargate;
    //fee collector
    address public immutable feeCollector;
    //stargate pool ID (usd = 1)
    uint8 public pID;
    //user info for rewards
    mapping(address => userInfo) public _userInfo;
    //router
    address public router;
    //deposit fee
    uint256 public fee;

        constructor(
        ERC20 _underlying, ERC20 _poolToken, ERC20 _stgToken, address _router,
        address _stg, address _feeCollector, uint8 _pID, uint256 _fee) ERC4626(_underlying, "USDC Vault", "vUSDC"){
        UNDERLYING = _underlying;
        POOLTOKEN = _poolToken;
         stargate = _stg;
        STG = _stgToken;
        router = _router;
        feeCollector = _feeCollector;
        pID = _pID;
        fee = _fee;
    }
    function totalAssets() public view virtual override returns (uint256){
        return UNDERLYING.balanceOf(address(this)) + UNDERLYING.balanceOf(stargate);
    }

    function afterDeposit(uint256 assets, uint256 shares)internal virtual override {
        userInfo storage user = _userInfo[msg.sender];
        uint256 _fee = assets.mulWadDown(fee);
        asset.transferFrom(msg.sender, feeCollector, _fee);
        assets -= _fee;
        shares = convertToShares(assets);
        uint256 balance = convertToShares(assets - _fee);
        UNDERLYING.approve(router, assets);
        IRouter(router).addLiquidity(pID, assets, msg.sender);
        POOLTOKEN.approve(stargate, assets);
        IStargate(stargate).deposit(pID, assets);
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
        IStargate(stargate).withdraw(pID, assets);
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
    function setPID(uint8 _pID)public onlyOwner{
        pID = _pID;
    }
    
    
}
