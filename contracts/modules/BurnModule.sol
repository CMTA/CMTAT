//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "./AuthorizationModule.sol";
import "./BaseModule.sol";
import "../../openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";

abstract contract BurnModule is Initializable, BaseModule, AuthorizationModule {
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    event Burn(address indexed owner, uint256 amount);

        /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount)
        public
        onlyRole(BURNER_ROLE)
    {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(
            currentAllowance >= amount,
            "CMTAT: burn amount exceeds allowance"
        );
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
        emit Burn(account, amount);
    }
}
