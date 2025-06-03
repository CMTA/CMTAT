//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
/* ==== OpenZeppelin === */
/* ==== Module === */
import {DebtEngineModule, DebtModule, ICMTATDebt} from "./wrapper/options/DebtEngineModule.sol";
import {CMTATBase} from "./wrapper/options/ERC20CrossChainModule.sol";
import {ICMTATConstructor} from "../interfaces/technical/ICMTATConstructor.sol";
/**
* @title Extend CMTAT Base with option modules
*/
abstract contract CMTATBaseDebt is CMTATBase,DebtEngineModule {
  // nothing to do
}
