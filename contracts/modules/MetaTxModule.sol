pragma solidity ^0.8.2;

import "../../openzeppelin-contracts-upgradeable/contracts/metatx/ERC2771ContextUpgradeable.sol";


/**
 * @dev Force transfer module.
 *
 * Useful for to force transfer of tokens by an authorized user
 */
abstract contract MetaTxModule is ERC2771ContextUpgradeable {
}