//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "../../../../openzeppelin-contracts-upgradeable/contracts/metatx/ERC2771ContextUpgradeable.sol";

/**
 * @dev Meta transaction (gasless) module.
 *
 * Useful for to provide UX where the user does not pay gas for token exchange
 * To follow OpenZeppelin, this contract does not implement the functions init & init_unchained.
 * ()
 */
abstract contract MetaTxModule is ERC2771ContextUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address trustedForwarder
    ) ERC2771ContextUpgradeable(trustedForwarder) {
        // Nothing to do
    }

    uint256[50] private __gap;
}
