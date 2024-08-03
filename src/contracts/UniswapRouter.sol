// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IUniswapNonfungiblePositionManager} from "src/interfaces/IUniswapNonfungiblePositionManager.sol";
import {IERC20Metadata, IERC20} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ETHConverter} from "src/libraries/ETHConverter.sol";

// contract used to deposit on uniswap-based pools
abstract contract UniswapRouter {
	using SafeERC20 for IERC20;

	struct DepositUniswapParams {
		address token0;
		address token1;
		uint24 fee;
		uint256 token0Amount;
		uint256 token1Amount;
		uint256 token0Min;
		uint256 token1Min;
		uint256 deadline;
	}

	event UniswapRouter__Deposited(address token0, address token1, uint256 token0Amount, uint256 token1Amount, uint24 feeTier);

	error UniswapRouter__WETHConversionFailed(uint256 quantity);

	int24 constant MIN_TICK = -887272;
	int24 constant MAX_TICK = -MIN_TICK;

	IERC20 private immutable s_weth;

	constructor(address weth) {
		s_weth = IERC20(weth);
	}

	function ethDepositUniswap(
		IUniswapNonfungiblePositionManager callee,
		DepositUniswapParams calldata params
	) external payable returns (uint256 tokenId) {
		ETHConverter.convertToWETH(s_weth);

		if (params.token0 == address(s_weth)) {
			IERC20(params.token1).safeTransferFrom(msg.sender, address(this), params.token1Amount);
		} else {
			IERC20(params.token0).safeTransferFrom(msg.sender, address(this), params.token0Amount);
		}

		return _rawDepositUniswap(callee, params);
	}

	function depositUniswap(
		IUniswapNonfungiblePositionManager callee,
		DepositUniswapParams calldata params
	) public returns (uint256 tokenId) {
		IERC20(params.token0).safeTransferFrom(msg.sender, address(this), params.token0Amount);
		IERC20(params.token1).safeTransferFrom(msg.sender, address(this), params.token1Amount);

		return _rawDepositUniswap(callee, params);
	}

	function _rawDepositUniswap(
		IUniswapNonfungiblePositionManager callee,
		DepositUniswapParams calldata params
	) private returns (uint256 tokenId) {
		IERC20(params.token0).forceApprove(address(callee), params.token0Amount);
		IERC20(params.token1).forceApprove(address(callee), params.token1Amount);

		(tokenId, , , ) = callee.mint(
			IUniswapNonfungiblePositionManager.MintParams({
				token0: params.token0,
				token1: params.token1,
				fee: params.fee,
				tickLower: MIN_TICK,
				tickUpper: MAX_TICK,
				amount0Desired: params.token0Amount,
				amount1Desired: params.token1Amount,
				amount0Min: params.token0Min,
				amount1Min: params.token1Min,
				recipient: msg.sender,
				deadline: params.deadline
			})
		);

		emit UniswapRouter__Deposited(params.token0, params.token1, params.token0Amount, params.token0Amount, params.fee);
	}
}
