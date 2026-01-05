// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
/* ==== Engine === */
import {ISnapshotEngine, ISnapshotEngineModule} from "../../../interfaces/modules/ISnapshotEngineModule.sol";

/**
 * @title SnapshotEngine module 
 * @dev 
 *
 * Add on-chain snapshot through a SnapshotEngine (external contract) 
 */
abstract contract SnapshotEngineModule is Initializable, ISnapshotEngineModule {
    /* ============ State Variables ============ */
    bytes32 public constant SNAPSHOOTER_ROLE = keccak256("SNAPSHOOTER_ROLE");

    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.SnapshotEngineModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant SnapshotEngineModuleStorageLocation = 0x1387b97dfab601d3023cb57858a6be29329babb05c85597ddbe4926c1193a900;
    /* ==== ERC-7201 State Variables === */
    struct SnapshotEngineModuleStorage {
        ISnapshotEngine _snapshotEngine;
    }

    /* ============ Modifier ============ */
    modifier onlySnapshooter() {
        _authorizeSnapshots();
        _;
    }

    /* ============  Initializer Function ============ */
    /**
     * @dev
     *
     * - The grant to the admin role is done by AccessControlDefaultAdminRules
     * - The control of the zero address is done by AccessControlDefaultAdminRules
     * Warning: not used in the different deployment version to reduce contract code size and simplify code
     * If not used, the function will not be included in the final bytecode if compiled with the optimizer enabled
     */
    function __SnapshotEngineModule_init_unchained(ISnapshotEngine snapshotEngine_)
    internal virtual onlyInitializing {
        if (address(snapshotEngine_) != address (0)) {
            SnapshotEngineModuleStorage storage $ = _getSnapshotEngineModuleStorage();
            _setSnapshotEngine($, snapshotEngine_);
        }
    }


    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /* ============  State Restricted Functions ============ */
    /**
    * @inheritdoc ISnapshotEngineModule
    * @custom:access-control
    * - The caller must have the `SNAPSHOOTER_ROLE`.
    */
    function setSnapshotEngine(
        ISnapshotEngine snapshotEngine_
    ) public virtual override(ISnapshotEngineModule) onlySnapshooter  {
        SnapshotEngineModuleStorage storage $ = _getSnapshotEngineModuleStorage();
        require($._snapshotEngine != snapshotEngine_, CMTAT_SnapshotModule_SameValue());
        _setSnapshotEngine($, snapshotEngine_);
    }

    
    /* ============ View functions ============ */

    /**
    * @inheritdoc ISnapshotEngineModule
    */
    function snapshotEngine() public view virtual override(ISnapshotEngineModule) returns (ISnapshotEngine) {
        SnapshotEngineModuleStorage storage $ = _getSnapshotEngineModuleStorage();
        return $._snapshotEngine;
    }
    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _setSnapshotEngine(
        SnapshotEngineModuleStorage storage $, ISnapshotEngine snapshotEngine_
    ) internal virtual {
        $._snapshotEngine = snapshotEngine_;
        emit SnapshotEngine(snapshotEngine_);
    }

    /* ============ Access Control ============ */
    function _authorizeSnapshots() internal virtual;
    /* ============ ERC-7201 ============ */
    function _getSnapshotEngineModuleStorage() private pure returns (SnapshotEngineModuleStorage storage $) {
        assembly {
            $.slot := SnapshotEngineModuleStorageLocation
        }
    }


}
