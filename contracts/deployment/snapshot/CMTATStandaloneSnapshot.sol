//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.24;

import {CMTATBaseERC2771Snapshot} from "../../modules/7_CMTATBaseERC2771Snapshot.sol";
import {ReentrancyGuardTransient} from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";
import {ValidationModuleRuleEngine} from "../../modules/wrapper/extensions/ValidationModule/ValidationModuleRuleEngine.sol";
import {IRuleEngine} from "../../interfaces/engine/IRuleEngine.sol";
import {ERC2771Module} from "../../modules/wrapper/options/ERC2771Module.sol";
import {ICMTATConstructor} from "../../interfaces/technical/ICMTATConstructor.sol";


/**
* @title CMTAT with snapshot engine — standalone deployment (without proxy)
*/
contract CMTATStandaloneSnapshot is CMTATBaseERC2771Snapshot, ReentrancyGuardTransient {
    /**
     * @notice Contract version for standalone deployment with snapshot engine
     * @param forwarderIrrevocable address of the forwarder, required for the gasless support
     * @param admin address of the admin of contract (Access Control)
     * @param ERC20Attributes_ ERC20 name, symbol and decimals
     * @param extraInformationAttributes_ tokenId, terms, information
     * @param engines_ external contract
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address forwarderIrrevocable,
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        ICMTATConstructor.ExtraInformationAttributes memory extraInformationAttributes_,
        ICMTATConstructor.Engine memory engines_
    ) ERC2771Module(forwarderIrrevocable) {
        // Initialize the contract to avoid front-running
        initialize(
            admin,
            ERC20Attributes_,
            extraInformationAttributes_,
            engines_
        );
    }

    /**
    * @inheritdoc ValidationModuleRuleEngine
    * @dev
    * @custom:security Wraps the external `ruleEngine.transferred(...)` call — the only point at
    * which a transfer hands control to an external contract — in a transient (EIP-1153) reentrancy
    * guard, so a rule engine that reenters the token during the callback reverts with
    * `ReentrancyGuardReentrantCall` instead of being re-validated against a stale pre-transfer
    * balance snapshot. Without it, a compromised engine can pass the active-balance check twice
    * against the same state and move more than a holder's unfrozen balance.
    *
    * This override is applied per deployment variant rather than in the shared base because it
    * costs ~195 bytes of deployed bytecode and several variants are within a few hundred bytes of
    * the EIP-170 24 KiB limit. See the module documentation for the per-variant table.
    */
    function _callRuleEngineTransferred(
        IRuleEngine ruleEngine_,
        address spender,
        address from,
        address to,
        uint256 value
    ) internal virtual override nonReentrant {
        super._callRuleEngineTransferred(ruleEngine_, spender, from, to, value);
    }
}
