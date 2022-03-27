pragma solidity ^0.8.10;

import {IStargate} from "./interfaces/IStargate.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";

contract Strategy is Ownable {
    IStargate staker;
    address feeCollector;
    address vault;

    constructor(address _staker){
        staker = IStargate(_staker);
    }
    function _deposit(uint256 _pid, uint256 _amount) public onlyVault{
        staker.deposit(_pid, _amount);
    }
    function harvest() public onlyVault{
        staker.deposit(0, 0);
        uint256 stgBal = stg.balanceOf(address(this));
        uint256 fee = stgBal * 0.01;
        stg.transfer(address(feeCollector), fee);
        stg._swap(0, stgBal);
        //stakes.transfer(address(feeCollector), fee);
        //swap to want to use stg
    }
    function withdraw(uint256 _pid, uint256 _amount) public onlyVault{
        staker.withdraw(_pid, _amount);
    }
    function setVault(address _vault) public onlyOwner{
        vault = _vault;
    }
    
    modifier onlyVault(){
        require(msg.sender == vault);
        _;
    }
}