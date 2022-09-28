//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "openzeppelin-contracts-upgradeable/contracts/metatx/ERC2771ContextUpgradeable.sol";


/**
 * @dev Meta transaction (gasless) module.
 *
 * Useful for to provide UX where the user does not pay gas for token exchange
 */
abstract contract MetaTxModule is ERC2771ContextUpgradeable {
  function __MetaTx_init(address forwarder) internal initializer {
    __Context_init_unchained();
    __ERC2771Context_init_unchained(forwarder);
    __MetaTx_init_unchained();
  }

  function __MetaTx_init_unchained() internal initializer {
  }
}
