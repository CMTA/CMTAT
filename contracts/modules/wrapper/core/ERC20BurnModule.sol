//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
/* ==== Module === */
import {ERC20BurnModuleInternal} from "../../internal/ERC20BurnModuleInternal.sol";
/* ==== Technical === */
import {IBurnBatchERC20} from "../../../interfaces/technical/IMintBurnToken.sol";
/* ==== Tokenization === */
import {IERC3643Burn} from "../../../interfaces/tokenization/IERC3643Partial.sol";
import {IERC7551Burn} from "../../../interfaces/tokenization/draft-IERC7551.sol";
/**
 * @title ERC20Burn module.
 * @dev 
 *
 * Contains all burn functions, inherits from ERC-20
 */
abstract contract ERC20BurnModule is  ERC20BurnModuleInternal, AccessControlUpgradeable, IBurnBatchERC20, IERC3643Burn, IERC7551Burn {
    /* ============ State Variables ============ */
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev
     * @inheritdoc IERC7551Burn
     * @custom:access-control
     * - the caller must have the `BURNER_ROLE`.
     */
    function burn(
        address account,
        uint256 value,
        bytes calldata data
    ) public virtual override(IERC7551Burn) onlyRole(BURNER_ROLE) {
        _burn(account, value, data);
    }

    /**
     * @inheritdoc IERC3643Burn
     * @custom:access-control
     * - the caller must have the `BURNER_ROLE`.
     */
    function burn(
        address account,
        uint256 value
    ) public virtual override(IERC3643Burn) onlyRole(BURNER_ROLE) {
       _burn(account, value,"");
    }

    /**
     *
     * @inheritdoc IBurnBatchERC20
     * @custom:access-control
     * - the caller must have the `BURNER_ROLE`.
     */
    function batchBurn(
        address[] calldata accounts,
        uint256[] calldata values,
        bytes memory data
    ) public virtual override(IBurnBatchERC20) onlyRole(BURNER_ROLE) {
        _batchBurn(accounts, values);
        emit BatchBurn(_msgSender(),accounts, values, data );
    }

    /**
     *
     * @inheritdoc IERC3643Burn
     * @custom:access-control
     * - the caller must have the `BURNER_ROLE`.
     */
    function batchBurn(
        address[] calldata accounts,
        uint256[] calldata values
    ) public virtual override (IERC3643Burn) onlyRole(BURNER_ROLE) {
        _batchBurn(accounts, values);
        emit BatchBurn(_msgSender(),accounts, values, "" );
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _burn(
        address account,
        uint256 value,
        bytes memory data
    ) internal virtual {
        _burnOverride(account, value);
        emit Burn(_msgSender(), account, value, data);
    }
}
