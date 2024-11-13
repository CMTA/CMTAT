//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "../../security/AuthorizationModule.sol";
import "../../../libraries/Errors.sol";
import "../../../interfaces/engine/ITransferEngine.sol";

abstract contract TransferEngineModule is AuthorizationModule {
    /* ============ Events ============ */
    /**
     * @dev Emitted when a rule engine is set.
     */
    event TransferEngine(ITransferEngine indexed newTransferEngine);
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.TransferModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant TransferEngineModuleStorageLocation = 0x59b7f077fa4ad020f9053fd2197fef0113b19f0b11dcfe516e88cbc0e9226d00;
    /* ==== ERC-7201 State Variables === */
    struct TransferEngineModuleStorage {
        ITransferEngine _transferEngine;
    }
    /* ============  Initializer Function ============ */
    /**
     * @dev
     *
     * - The grant to the admin role is done by AccessControlDefaultAdminRules
     * - The control of the zero address is done by AccessControlDefaultAdminRules
     *
     */
    function __TransferModule_init_unchained(ITransferEngine TransferEngine_)
    internal onlyInitializing {
        if (address(TransferEngine_) != address (0)) {
            TransferEngineModuleStorage storage $ = _getTransferEngineModuleStorage();
            $._transferEngine = TransferEngine_;
            emit TransferEngine(TransferEngine_);
        }
    }


    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function transferEngine() public view virtual returns (ITransferEngine) {
        TransferEngineModuleStorage storage $ = _getTransferEngineModuleStorage();
        return $._transferEngine;
    }

    /*
    * @notice set an TransferEngine if not already set
    * @dev once an TransferEngine is set, it is not possible to unset it
    */
    function setTransferEngine(
        ITransferEngine transferEngine_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        TransferEngineModuleStorage storage $ = _getTransferEngineModuleStorage();
        $._transferEngine = transferEngine_;
        emit TransferEngine(transferEngine_);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /* ============ ERC-7201 ============ */
    function _getTransferEngineModuleStorage() private pure returns (TransferEngineModuleStorage storage $) {
        assembly {
            $.slot := TransferEngineModuleStorageLocation
        }
    }
}
