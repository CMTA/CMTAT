//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "../../openzeppelin-contracts-upgradeable/contracts/metatx/ERC2771ContextUpgradeable.sol";

/**
 * @dev Meta transaction (gasless) module.
 *
 * Useful for to provide UX where the user does not pay gas for token exchange
 */
abstract contract MetaTxModule is ERC2771ContextUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address trustedForwarder)
        ERC2771ContextUpgradeable(trustedForwarder)
    {
        // TODO : Emit an event ?
        // See : https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/mocks/ERC2771ContextMockUpgradeable.sol
        // emit Sender(_msgSender());
    }
}
