// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
/* ==== Tokenization === */
import {IERC3643Pause} from "../../../interfaces/tokenization/IERC3643Partial.sol";
import {IERC7551Pause} from "../../../interfaces/tokenization/draft-IERC7551.sol";
import {ICMTATDeactivate} from "../../../interfaces/tokenization/ICMTAT.sol";


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
abstract contract PauseModule is PausableUpgradeable, IERC3643Pause, IERC7551Pause, ICMTATDeactivate {
    error CMTAT_PauseModule_ContractIsDeactivated();
    /* ============ State Variables ============ */
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.PauseModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant PauseModuleStorageLocation = 0xab1527b6135145d8da1edcbd6b7b270624e17f2b41c74a8c746ff388ad454700;
    /* ==== ERC-7201 State Variables === */
    struct PauseModuleStorage {
        bool _isDeactivated;
    }

    /* ============ Modifier ============ */
    /// @dev Modifier to restrict access to the burner functions
    modifier onlyPauseManager() {
        _authorizePause();
        _;
    }

    modifier onlyDeactivateContractManager() {
        _authorizeDeactivate();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ State restricted functions ============ */
    /**
     * @inheritdoc IERC3643Pause
     * @custom:access-control
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public virtual override(IERC3643Pause, IERC7551Pause) onlyPauseManager{
        PausableUpgradeable._pause();
    }

    /**
     * @inheritdoc IERC3643Pause
     * @custom:access-control
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public virtual override(IERC3643Pause, IERC7551Pause) onlyPauseManager{
        PauseModuleStorage storage $ = _getPauseModuleStorage();
        require(!$._isDeactivated, CMTAT_PauseModule_ContractIsDeactivated());
        PausableUpgradeable._unpause();
    }

    /**
    * @inheritdoc ICMTATDeactivate
    * @custom:access-control
    * - the caller must have the `DEFAULT_ADMIN_ROLE`.
    * @custom:devimpl
    * With a proxy architecture, it is still possible to rollback by deploying a new implementation which sets the variable to false.
    */
    function deactivateContract()
        public virtual override(ICMTATDeactivate)
        onlyDeactivateContractManager
    {
        // Contract must be in pause state
        PausableUpgradeable._requirePaused();
        PauseModuleStorage storage $ = _getPauseModuleStorage();
        $._isDeactivated = true;
       emit Deactivated(_msgSender());
    }

    /* ============ View functions ============ */
    /**
    * @inheritdoc IERC3643Pause
    */
    function paused() public virtual view override(IERC3643Pause, IERC7551Pause, PausableUpgradeable) returns (bool){
        return PausableUpgradeable.paused();
   }

    /**
    * @inheritdoc ICMTATDeactivate
    */
    function deactivated() public view virtual override(ICMTATDeactivate) returns (bool){
        PauseModuleStorage storage $ = _getPauseModuleStorage();
        return $._isDeactivated;
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ Access Control ============ */
    function _authorizePause() internal virtual;
    function _authorizeDeactivate() internal virtual;

    /* ============ ERC-7201 ============ */
    function _getPauseModuleStorage() private pure returns (PauseModuleStorage storage $) {
        assembly {
            $.slot := PauseModuleStorageLocation
        }
    }
}
