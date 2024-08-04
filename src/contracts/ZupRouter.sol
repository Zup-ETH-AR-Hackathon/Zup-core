// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {UniswapRouter} from "src/contracts/UniswapRouter.sol";
import {IzumiRouter} from "src/contracts/IzumiRouter.sol";

contract ZupRouter is UniswapRouter, IzumiRouter {
	constructor(address weth) UniswapRouter(weth) IzumiRouter(weth) {}
}
