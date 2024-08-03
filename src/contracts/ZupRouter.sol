// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {UniswapRouter} from "src/contracts/UniswapRouter.sol";

contract ZupRouter is UniswapRouter {
	constructor(address weth) UniswapRouter(weth) {}
}
