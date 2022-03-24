// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./Blacksmith.sol";
import "../../interfaces/IRouter.sol";

contract IRouterBS {
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

    function addLiquidity(uint256 _pid, uint256 _amount, address _to) public prank  {
        IRouter(target).addLiquidity(_pid, _amount, _to);
    }

	function instantRedeemLocal(uint256 _pid, uint256 _amountLP, address _to) public prank  {
        IRouter(target).instantRedeemLocal(_pid, _amountLP, _to);
    }

}
