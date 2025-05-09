//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
/* ==== OpenZeppelin === */
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {IERC165} from "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
/* ==== Module === */
import {CMTAT_BASE, ERC20Upgradeable} from "../CMTAT_BASE.sol";
import {IERC7802} from "../../interfaces/technical/IERC7802.sol";
import {IBurnFromERC20} from "../../interfaces/technical/IMintBurnToken.sol";
/**
 * @title ERC20Burn module.
 * @dev 
 *
 * Contains all burn functions, inherits from ERC-20
 */
abstract contract ERC20CrossChainModule is CMTAT_BASE, IERC7802, IBurnFromERC20 {
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
    function crosschainMint(address _to, uint256 _amount) external virtual onlyRole(CROSS_CHAIN_ROLE) whenNotPaused {
        _mintOverride(_to, _amount);
        emit CrosschainMint(_to, _amount, msg.sender);
    }

    /**
    * @inheritdoc IERC7802
    * @dev
    * Don't emit the same event as configured in the ERC20BurnModule
    */
    function crosschainBurn(address _from, uint256 _amount) external virtual onlyRole(CROSS_CHAIN_ROLE) whenNotPaused{
        address sender =  _msgSender();
        _burnFrom(sender, _from, _amount);
        //_burnOverride(_from, _amount);
        emit CrosschainBurn(_from, _amount, msg.sender);
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
        //_burnFrom(_msgSender(), _msgSender(), value);
    }

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
        emit BurnFrom(account, sender, value);
    }
}
