// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
/* ==== OpenZeppelin === */
import {ERC165Upgradeable, IERC165} from "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
/* ==== Module === */
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
/* ==== Interfaces === */
import {IERC7802} from "../../../interfaces/technical/IERC7802.sol";
import {IBurnFromERC20} from "../../../interfaces/technical/IMintBurnToken.sol";
import {IERC20Allowance} from "../../../interfaces/technical/IERC20Allowance.sol";
import {ERC20BurnModule, ERC20BurnModuleInternal} from "../core/ERC20BurnModule.sol";
import {ERC20MintModule, ERC20MintModuleInternal} from "../core/ERC20MintModule.sol";
/**
 * @title ERC20CrossChainModule (ERC-7802)
 * @dev 
 *
 * Contains all mint and burn functions, inherits from ERC-20
 */
abstract contract ERC20CrossChainModule is ERC20MintModule, ERC20BurnModule, ERC165Upgradeable, IERC7802, IBurnFromERC20 {
    /* ============ State Variables ============ */
    bytes32 public constant BURNER_FROM_ROLE = keccak256("BURNER_FROM_ROLE");
    bytes32 public constant CROSS_CHAIN_ROLE = keccak256("CROSS_CHAIN_ROLE");

    /* ============ Modifier ============ */
    /// @dev Modifier to restrict access to the token bridge.
    /// Source: OpenZeppelin v5.4.0 - draft-ERC20Bridgeable.sol
    modifier onlyTokenBridge() {
        // Token bridge should never be impersonated using a relayer/forwarder. Using msg.sender is preferable to
        // _msgSender() for security reasons.
        _checkTokenBridge(msg.sender);
        _;
    }

    /// @dev Modifier to restrict access to the burner functions
    modifier onlyBurnerFrom() {
        _authorizeBurnFrom();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
    * @inheritdoc IERC7802
    * @dev
    * Don't emit the same event as configured in the ERC20MintModule
    * @custom:access-control
    * Protected by the modifier onlyTokenBridge.
    */
    function crosschainMint(address to, uint256 value) public virtual override(IERC7802) onlyTokenBridge {
        _mintOverride(to, value);
        emit CrosschainMint(to, value,_msgSender());
    }

    /**
    * @inheritdoc IERC7802
    * @dev
    * Don't emit the same event as configured in the ERC20BurnModule
    * Don't require allowance to follow Optimism Superchain ERC20 and OpenZeppelin implementation
    * @custom:access-control
    * - Protected by the modifier onlyTokenBridge.
    */
    function crosschainBurn(address from, uint256 value) public virtual override(IERC7802) onlyTokenBridge{
        _burnOverride(from, value);
        emit CrosschainBurn(from, value, _msgSender());
    }

    /**
     * @inheritdoc IBurnFromERC20
     * @custom:access-control
     * - Protected by the modifier onlyBurnerFrom.
     */
    function burnFrom(address account, uint256 value)
        public virtual override(IBurnFromERC20) onlyBurnerFrom
    {
        address sender =  _msgSender();
        _burnFrom(sender, account, value); 
    }

    /**
    * @inheritdoc IBurnFromERC20
    * @custom:access-control
    * - Protected by the modifier onlyBurnerFrom
    */
    function burn(
        uint256 value
    ) public virtual override(IBurnFromERC20) onlyBurnerFrom{
        // Don't emit CrossChainBurn because this function burn is not part of the IERC7802 interface
        // Don't emit Spend event because allowance is not used here
        address sender = _msgSender();
        _burnOverride(sender, value);
        // Burn from itself
        emit BurnFrom(sender, sender, sender, value);
    }

    /* ============ View functions ============ */
    function supportsInterface(bytes4 _interfaceId) public view virtual override(ERC165Upgradeable, IERC165) returns (bool) {
        return _interfaceId == type(IERC7802).interfaceId || ERC165Upgradeable.supportsInterface(_interfaceId);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _burnFrom(address sender, address account, uint256 value) internal virtual{
        // Allowance check and spend
        ERC20Upgradeable._spendAllowance(account, sender, value );
        // Specific event for the spend operation, same as transferFrom (ERC20BaseModule)
        emit IERC20Allowance.Spend(account, sender, value);
        // burn
        _burnOverride(account, value);
        // Specific event to burnFrom and self-burn (burn)
        emit BurnFrom(sender, account, sender, value);
    }

    /* ==== Access Control ==== */
    /**
     * @dev Checks if the caller is a trusted token bridge. MUST revert otherwise.
     *
     * Source: OpenZeppelin v5.4.0 - draft-ERC20Bridgeable.sol
     */
    function _checkTokenBridge(address caller) internal virtual;

    function _authorizeBurnFrom() internal virtual;
}