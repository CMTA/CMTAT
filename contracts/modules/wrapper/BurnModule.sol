//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "../../../openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import "../BaseModule.sol";

abstract contract BurnModule is ERC20Upgradeable, AuthorizationModule {
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    event Burn(address indexed owner, uint256 amount);

    /**
     * @dev Destroys `amount` tokens from `account`
     *
     * See {ERC20-_burn}
     */
    function forceBurn(address account, uint256 amount)
        public
        onlyRole(BURNER_ROLE)
    {
        _burn(account, amount);
        emit Burn(account, amount);
    }
}
