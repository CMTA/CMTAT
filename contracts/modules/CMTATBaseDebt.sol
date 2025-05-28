//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
/* ==== OpenZeppelin === */
/* ==== Module === */
import {DebtEngineModule, DebtModule, ICMTATDebt} from "./wrapper/options/DebtEngineModule.sol";
import {CMTATBase} from "./wrapper/options/ERC20CrossChainModule.sol";
import {AccessControlUpgradeable} from "./security/AuthorizationModule.sol";
import {ICMTATConstructor} from "../interfaces/technical/ICMTATConstructor.sol";
/**
* @title Extend CMTAT Base with option modules
*/
abstract contract CMTATBaseDebt is CMTATBase,DebtEngineModule {
    function __CMTAT_modules_init_unchained(address admin, ICMTATConstructor.ERC20Attributes memory ERC20Attributes_, ICMTATConstructor.BaseModuleAttributes memory baseModuleAttributes_, ICMTATConstructor.Engine memory engines_ ) internal virtual override onlyInitializing {
        CMTATBase.__CMTAT_modules_init_unchained(admin, ERC20Attributes_, baseModuleAttributes_,  engines_);
         DebtModule.__DebtModule_init_unchained();
    }
}
