// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface IIzumiLiquidityManager {
	struct MintParams {
		address miner;
		address tokenX;
		address tokenY;
		uint24 fee;
		int24 pl;
		int24 pr;
		uint128 xLim;
		uint128 yLim;
		uint128 amountXMin;
		uint128 amountYMin;
		uint256 deadline;
	}

	function mint(MintParams calldata params) external returns (uint256 lid, uint128 liquidity, uint256 amountX, uint256 amountY);
}
