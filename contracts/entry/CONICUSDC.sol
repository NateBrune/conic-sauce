// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "../CoreStrategyConic.sol";
import {SafeERC20, IERC20, Address} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20Metadata } from "../interfaces/IERC20Metadata.sol";

contract CONICUSDC is CoreStrategyConic {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    using SafeMath for uint8;

    constructor(address _vault)
        CoreStrategyConic(
            _vault,
            CoreStrategyConicConfig(
                0x07b577f10d4e00f3018542d08a87F255a49175A5, // conicPool
                0x472fCC880F01B32C55F1fB55F58f7bD930dE1944, // conicLp
                1e4                                         //mindeploy
            )
        )
    {}

    function _setup() internal override {
        want.safeApprove(address(conicPool), type(uint256).max);
    }

    function _deposit(uint256 _amount) public override {
        conicPool.depositFor(address(this), _amount, 1, true);
        //emit debug(1, _amount);
        //emit debug(2, balanceOfWant());
    }
    //TODO: REMOVE
    function _godDeposit(uint256 _amount) public {
        conicPool.depositFor(address(this), _amount, 1, true);
        //emit debug(1, _amount);
    } 

    function _withdraw(uint256 _amount) public override returns (uint256 _liquidatedAmount, uint256 _loss) {
        if (_amount > 0){
            uint256 balBefore = balanceOfWant();
            uint256 lpAmount = _wantToLp(_amount);
            if(lpAmount > countLpPooled()){
                lpAmount = countLpPooled();
            }
            conicPool.unstakeAndWithdraw(lpAmount, lpAmount.mul(slippageAdj).div(BASIS_PRECISION));
            _liquidatedAmount = balanceOfWant().sub(balBefore);
            _loss = 0;
        }
    }

    function _withdrawLp(uint256 _amount) public override {
        if (_amount > 0){
            if(_amount > countLpPooled()){
                _amount = countLpPooled();
            }
            conicPool.unstakeAndWithdraw(_amount, _amount.mul(slippageAdj).div(BASIS_PRECISION));
        }
    }

    function claimHarvest() internal override {
        //IFarmMasterChef(farmMasterChef).harvestFromMasterChef();
    }

    function balancePendingHarvest() public view override returns (uint256){
        return _lpToWant(countLpPooled());
    }
}