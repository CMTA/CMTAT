//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
/* ==== OpenZeppelin === */
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {IERC165} from "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
/* ==== Module === */
import {CMTATBaseERC1404, ERC20Upgradeable} from "./2_CMTATBaseERC1404.sol";
/* ==== Interfaces === */
import {IERC7802} from "../interfaces/technical/IERC7802.sol";
import {IBurnFromERC20} from "../interfaces/technical/IMintBurnToken.sol";
/**
 * @title ERC20CrossChainModule (ERC-7802)
 * @dev 
 *
 * Contains all burn functions, inherits from ERC-20
 */
abstract contract CMTATBaseERC20CrossChain is CMTATBaseERC1404, IERC7802, IBurnFromERC20 {
    bytes32 public constant BURNER_FROM_ROLE = keccak256("BURNER_FROM_ROLE");
    bytes32 public constant CROSS_CHAIN_ROLE = keccak256("CROSS_CHAIN_ROLE");
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
    * @inheritdoc IERC7802
    * @dev
    * Don't emit the same event as configured in the ERC20MintModule
    */
    function crosschainMint(address to, uint256 value) external virtual onlyRole(CROSS_CHAIN_ROLE) whenNotPaused {
        _mintOverride(to, value);
        emit CrosschainMint(to, value,_msgSender());
    }

    /**
    * @inheritdoc IERC7802
    * @dev
    * Don't emit the same event as configured in the ERC20BurnModule
    */
    function crosschainBurn(address from, uint256 value) external virtual onlyRole(CROSS_CHAIN_ROLE) whenNotPaused{
        address sender =  _msgSender();
        _burnFrom(sender, from, value);
        emit CrosschainBurn(from, value, _msgSender());
    }

    /**
     * @inheritdoc IBurnFromERC20
     * @dev 
     * This function decreases the total supply.
     * Can be used to authorize a bridge (e.g. CCIP) to burn token owned by the bridge
     * No data parameter reason to be compatible with Bridge, e.g. CCIP
     * 
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `value`.
     */
    function burnFrom(address account, uint256 value)
        public override(IBurnFromERC20)
        onlyRole(BURNER_FROM_ROLE) whenNotPaused
    {
        address sender =  _msgSender();
        _burnFrom(sender, account, value);
       
    }

    function burn(
        uint256 value
    ) public virtual onlyRole(BURNER_FROM_ROLE) whenNotPaused {
        _burnOverride(_msgSender(), value);
        emit CrosschainBurn(_msgSender() , value, _msgSender());
    }

    /* ============ View functions ============ */
    function supportsInterface(bytes4 _interfaceId) public view virtual override(AccessControlUpgradeable, IERC165) returns (bool) {
        return _interfaceId == type(IERC7802).interfaceId || AccessControlUpgradeable.supportsInterface( _interfaceId);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _burnFrom(address sender, address account, uint256 value) internal virtual{
        // Allowance check
        ERC20Upgradeable._spendAllowance(account, sender, value );
        // burn
        // We also emit a burn event since its a burn operation
        _burnOverride(account, value);
        //_burn(account, value,  "burnFrom");
        // Specific event for the operation
        emit Spend(account, sender, value);
        emit BurnFrom(sender, account, sender, value);
    }
}