// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "../CoreStrategyConic.sol";
import {SafeERC20, IERC20, Address} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20Metadata } from "interfaces/IERC20Metadata.sol";
import "interfaces/ISwapRouter.sol";

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
        //IERC20(WETH).approve(address(this), type(uint256).max);
        CRV.safeApprove(address(crvPool), type(uint256).max);
        CVX.safeApprove(address(cvxPool), type(uint256).max);
        CNC.safeApprove(address(cncPool), type(uint256).max);
    }

    function _deposit(uint256 _amount) public override {
        //conicPool.depositFor(address(this), _amount, 1, true);
        emit debug2(_amount);
        emit debug2(balanceOfWant());
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

    function godSwapCNC(int128 i, int128 j, uint256 amt, uint256 min) public {
        cncPool.exchange_underlying(i, j, amt, min);
    }
    function claimHarvest() public override {
        //IFarmMasterChef(farmMasterChef).harvestFromMasterChef();
        (uint256 cncRewards, uint256 crvRewards, uint256 cvxRewards) = rewardsManager.claimEarnings();
        // emit debug2(cncRewards);
        // emit debug2(crvRewards);
        // emit debug2(cvxRewards);
        
        uint256 cncRet = cncPool.exchange_underlying(1, 0, cncRewards, 0);
        //uint256 cvxRet = cvxPool.exchange_underlying(1, 0, cvxRewards, 0);
        //uint256 crvRet = crvPool.exchange_underlying(1, 0, crvRewards, 0);
        // emit debug2(cncRet);
        // emit debug2(cvxRet);
        // emit debug2(crvRet);
        uint256 balance = address(this).balance;
        emit debug2(balance);
        // ISwapRouter router = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
        // struct ExactInputSingleParams {
        //     address(// address tokenIn;
        //     // address tokenOut;
        //     // uint24 fee;
        //     // address recipient;
        //     // uint256 deadline;
        //     // uint256 amountIn;
        //     // uint256 amountOutMinimum;
        //     // uint160 sqrtPriceLimitX96;
        // }
        // router.exactInputSingle(params);
    }

    function balancePendingHarvest() public view override returns (uint256){
        (uint256 cncRewards, uint256 crvRewards, uint256 cvxRewards) = rewardsManager.claimableRewards(address(this));

        return _lpToWant(countLpPooled());
    }
}