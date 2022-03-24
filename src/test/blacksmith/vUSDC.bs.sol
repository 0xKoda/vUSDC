// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./Blacksmith.sol";
import "../../vUSDC.sol";

contract vUSDCBS {
    Bsvm constant bsvm = Bsvm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address addr;
    uint256 privateKey;
    address payable target;
    
    constructor( address _addr, uint256 _privateKey, address _target) {
        addr = _privateKey == 0 ? _addr : bsvm.addr(_privateKey);
        privateKey = _privateKey;
        target = payable(_target);
    }

    modifier prank() {
        bsvm.startPrank(addr, addr);
        _;
    }

    function DOMAIN_SEPARATOR() public prank returns (bytes32) {
        return vUSDC(target).DOMAIN_SEPARATOR();
    }

	function POOLTOKEN() public prank returns (ERC20) {
        return vUSDC(target).POOLTOKEN();
    }

	function STG() public prank returns (ERC20) {
        return vUSDC(target).STG();
    }

	function UNDERLYING() public prank returns (ERC20) {
        return vUSDC(target).UNDERLYING();
    }

	function _userInfo(address arg0) public prank returns (uint256, uint256) {
        return vUSDC(target)._userInfo(arg0);
    }

	function allowance(address arg0, address arg1) public prank returns (uint256) {
        return vUSDC(target).allowance(arg0, arg1);
    }

	function approve(address spender, uint256 amount) public prank returns (bool) {
        return vUSDC(target).approve(spender, amount);
    }

	function asset() public prank returns (ERC20) {
        return vUSDC(target).asset();
    }

	function balanceOf(address arg0) public prank returns (uint256) {
        return vUSDC(target).balanceOf(arg0);
    }

	function convertToAssets(uint256 shares) public prank returns (uint256) {
        return vUSDC(target).convertToAssets(shares);
    }

	function convertToShares(uint256 assets) public prank returns (uint256) {
        return vUSDC(target).convertToShares(assets);
    }

	function decimals() public prank returns (uint8) {
        return vUSDC(target).decimals();
    }

	function deposit(uint256 assets, address receiver) public prank returns (uint256) {
        return vUSDC(target).deposit(assets, receiver);
    }

	function fee() public prank returns (uint256) {
        return vUSDC(target).fee();
    }

	function feeCollector() public prank returns (address) {
        return vUSDC(target).feeCollector();
    }

	function maxDeposit(address arg0) public prank returns (uint256) {
        return vUSDC(target).maxDeposit(arg0);
    }

	function maxMint(address arg0) public prank returns (uint256) {
        return vUSDC(target).maxMint(arg0);
    }

	function maxRedeem(address owner) public prank returns (uint256) {
        return vUSDC(target).maxRedeem(owner);
    }

	function maxWithdraw(address owner) public prank returns (uint256) {
        return vUSDC(target).maxWithdraw(owner);
    }

	function mint(uint256 shares, address receiver) public prank returns (uint256) {
        return vUSDC(target).mint(shares, receiver);
    }

	function name() public prank returns (string memory) {
        return vUSDC(target).name();
    }

	function nonces(address arg0) public prank returns (uint256) {
        return vUSDC(target).nonces(arg0);
    }

	function owner() public prank returns (address) {
        return vUSDC(target).owner();
    }

	function pID() public prank returns (uint8) {
        return vUSDC(target).pID();
    }

	function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public prank  {
        vUSDC(target).permit(owner, spender, value, deadline, v, r, s);
    }

	function previewDeposit(uint256 assets) public prank returns (uint256) {
        return vUSDC(target).previewDeposit(assets);
    }

	function previewMint(uint256 shares) public prank returns (uint256) {
        return vUSDC(target).previewMint(shares);
    }

	function previewRedeem(uint256 shares) public prank returns (uint256) {
        return vUSDC(target).previewRedeem(shares);
    }

	function previewWithdraw(uint256 assets) public prank returns (uint256) {
        return vUSDC(target).previewWithdraw(assets);
    }

	function redeem(uint256 shares, address receiver, address owner) public prank returns (uint256) {
        return vUSDC(target).redeem(shares, receiver, owner);
    }

	function renounceOwnership() public prank  {
        vUSDC(target).renounceOwnership();
    }

	function router() public prank returns (address) {
        return vUSDC(target).router();
    }

	function setFee(uint256 _fee) public prank  {
        vUSDC(target).setFee(_fee);
    }

	function setFeeCollector(address _feeCollector) public prank  {
        vUSDC(target).setFeeCollector(_feeCollector);
    }

	function setPID(uint8 _pID) public prank  {
        vUSDC(target).setPID(_pID);
    }

	function setPoolToken(ERC20 _poolToken) public prank  {
        vUSDC(target).setPoolToken(_poolToken);
    }

	function setRouter(address _router) public prank  {
        vUSDC(target).setRouter(_router);
    }

	function setSTG(ERC20 _stg) public prank  {
        vUSDC(target).setSTG(_stg);
    }

	function setStaker(ERC20 _staker) public prank  {
        vUSDC(target).setStaker(_staker);
    }

	function staker() public prank returns (address) {
        return vUSDC(target).staker();
    }

	function symbol() public prank returns (string memory) {
        return vUSDC(target).symbol();
    }

	function totalAssets() public prank returns (uint256) {
        return vUSDC(target).totalAssets();
    }

	function totalSupply() public prank returns (uint256) {
        return vUSDC(target).totalSupply();
    }

	function transfer(address to, uint256 amount) public prank returns (bool) {
        return vUSDC(target).transfer(to, amount);
    }

	function transferFrom(address from, address to, uint256 amount) public prank returns (bool) {
        return vUSDC(target).transferFrom(from, to, amount);
    }

	function transferOwnership(address newOwner) public prank  {
        vUSDC(target).transferOwnership(newOwner);
    }

	function withdraw(uint256 assets, address receiver, address owner) public prank returns (uint256) {
        return vUSDC(target).withdraw(assets, receiver, owner);
    }

}
