// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library ETHConverter {
	error ETHConverter__ConversionToWETHFailed(uint256 quantity);

	error ETHConverter__BalanceMismatchAfterConversion(uint256 currentBalance, uint256 expectedBalance);

	function convertToWETH(IERC20 weth) internal {
		uint256 wethBalanceBeforeConversion = weth.balanceOf(address(this));

		(bool success, ) = address(weth).call{value: msg.value}("");
		if (!success) revert ETHConverter__ConversionToWETHFailed(msg.value);

		uint256 wethBalanceAfterConversion = weth.balanceOf(address(this));

		if (wethBalanceAfterConversion != wethBalanceBeforeConversion + msg.value) {
			revert ETHConverter__BalanceMismatchAfterConversion(wethBalanceAfterConversion, wethBalanceBeforeConversion + msg.value);
		}
	}
}
