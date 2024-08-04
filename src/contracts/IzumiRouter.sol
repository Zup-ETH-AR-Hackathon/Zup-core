// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IIzumiLiquidityManager} from "src/interfaces/IIzumiLiquidityManager.sol";
import {ETHConverter} from "src/libraries/ETHConverter.sol";

abstract contract IzumiRouter {
	using SafeERC20 for IERC20;

	IERC20 private immutable s_weth;

	constructor(address weth) {
		s_weth = IERC20(weth);
	}

	struct DepositIzumiParams {
		address token0;
		address token1;
		uint24 fee;
		uint128 token0Amount;
		uint128 token1Amount;
		uint128 token0Min;
		uint128 token1Min;
		uint256 deadline;
	}

	int24 constant MIN_PRICE_LEFT = -6960;
	int24 constant MAX_PRICE_RIGHT = -MIN_PRICE_LEFT;

	event IzumiRouter__Deposited(
		address depositor,
		address tokenX,
		address tokenY,
		uint256 tokenXAmount,
		uint256 tokenYAmount,
		uint24 feeTier,
		uint256 poolId
	);

	function depositIzumi(IIzumiLiquidityManager callee, DepositIzumiParams memory mintParams) external returns (uint256 poolId) {
		IERC20(mintParams.token0).safeTransferFrom(msg.sender, address(this), mintParams.token0Amount);
		IERC20(mintParams.token1).safeTransferFrom(msg.sender, address(this), mintParams.token1Amount);

		(poolId) = _rawDeposit(callee, mintParams);
	}

	function ethDepositIzumi(
		IIzumiLiquidityManager callee,
		DepositIzumiParams memory mintParams
	) external payable returns (uint256 poolNftId) {
		ETHConverter.convertToWETH(s_weth);

		if (mintParams.token0 == address(s_weth)) {
			IERC20(mintParams.token1).safeTransferFrom(msg.sender, address(this), mintParams.token1Amount);
		} else {
			IERC20(mintParams.token0).safeTransferFrom(msg.sender, address(this), mintParams.token0Amount);
		}

		return _rawDeposit(callee, mintParams);
	}

	function _rawDeposit(IIzumiLiquidityManager callee, DepositIzumiParams memory mintParams) private returns (uint256 poolId) {
		IERC20(mintParams.token0).forceApprove(address(callee), mintParams.token0Amount);
		IERC20(mintParams.token1).forceApprove(address(callee), mintParams.token1Amount);

		(poolId, , , ) = callee.mint(
			IIzumiLiquidityManager.MintParams({
				miner: msg.sender,
				tokenX: mintParams.token0,
				tokenY: mintParams.token1,
				fee: mintParams.fee,
				pl: MIN_PRICE_LEFT,
				pr: MAX_PRICE_RIGHT,
				xLim: mintParams.token0Amount,
				yLim: mintParams.token1Amount,
				amountXMin: mintParams.token0Min,
				amountYMin: mintParams.token1Min,
				deadline: mintParams.deadline
			})
		);

		emit IzumiRouter__Deposited(
			msg.sender,
			mintParams.token0,
			mintParams.token1,
			mintParams.token0Min,
			mintParams.token1Min,
			mintParams.fee,
			poolId
		);
	}
}
