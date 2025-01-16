//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {AuthorizationModule} from "../../security/AuthorizationModule.sol";
import {Errors} from "../../../libraries/Errors.sol";
/**
 * @title Pause Module
 * @dev 
 * Put in pause or deactivate the contract
 * The issuer must be able to “pause” the smart contract, 
 * to prevent execution of transactions on the distributed ledger until the issuer puts an end to the pause. 
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 */
abstract contract PauseModule is PausableUpgradeable, AuthorizationModule {
    /* ============ State Variables ============ */
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    string internal constant TEXT_TRANSFER_REJECTED_PAUSED =
        "All transfers paused";
    /* ============ Events ============ */
    event Deactivated(address account);
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.ERC20BaseModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant PauseModuleStorageLocation = 0x9bd8d607565c0370ae5f91651ca67fd26d4438022bf72037316600e29e6a3a00;
    /* ==== ERC-7201 State Variables === */
    struct PauseModuleStorage {
        bool _isDeactivated;
    }
    /* ============  Initializer Function ============ */
    function __PauseModule_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }
    
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Pauses all token transfers.
     * @dev See {ERC20Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     *
     */
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /**
     * @notice Unpauses all token transfers.
     * @dev See {ERC20Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public onlyRole(PAUSER_ROLE) {
        PauseModuleStorage storage $ = _getPauseModuleStorage();
        if($._isDeactivated){
            revert Errors.CMTAT_PauseModule_ContractIsDeactivated();
        }
        _unpause();
    }

    /**
    * @notice  deactivate the contract
    * Warning: the operation is irreversible, be careful
    * @dev
    * Emits a {Deactivated} event indicating that the contract has been deactivated.
    * Requirements:
    *
    * - the caller must have the `DEFAULT_ADMIN_ROLE`.
    */
    function deactivateContract()
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        PauseModuleStorage storage $ = _getPauseModuleStorage();
        $._isDeactivated = true;
       _pause();
       emit Deactivated(_msgSender());
    }

    /**
    * @notice Returns true if the contract is deactivated, and false otherwise.
    */
    function deactivated() view public returns (bool){
        PauseModuleStorage storage $ = _getPauseModuleStorage();
        return $._isDeactivated;
    }


    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/


    /* ============ ERC-7201 ============ */
    function _getPauseModuleStorage() private pure returns (PauseModuleStorage storage $) {
        assembly {
            $.slot := PauseModuleStorageLocation
        }
    }
}
