//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {ValidationModule} from "../controllers/ValidationModule.sol";
/* ==== Tokenization === */
import {IERC3643ComplianceRead} from "../../../interfaces/tokenization/IERC3643Partial.sol";
import {IERC7551Compliance} from "../../../interfaces/tokenization/draft-IERC7551.sol";
/**
 * @dev Validation module Core
 *
 * Useful for to restrict and validate transfers
 */
abstract contract ValidationModuleCore is
    ValidationModule,
    IERC3643ComplianceRead,
    IERC7551Compliance
{
    /* ============ Transfer & TransferFrom ============ */
    function canTransfer(
        address from,
        address to,
        uint256 value
    ) public view virtual override(IERC3643ComplianceRead, IERC7551Compliance) returns (bool) {
        return _canTransferByModule(address(0), from, to, value);
    }

    function canTransferFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) public view virtual override(IERC7551Compliance) returns (bool) {
        return _canTransferByModule(spender, from, to, value);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ View functions ============ */

    /**
    * @dev function used by canTransfer and operateOnTransfer
    */
    function _canTransferByModule(
        address spender,
        address from,
        address to,
        uint256 /*value*/
    ) internal view virtual returns (bool) {
        return ValidationModule._canTransferGenericByModule(spender, from, to);
    }
}
