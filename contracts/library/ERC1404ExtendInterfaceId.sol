// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.24;

library ERC1404ExtendInterfaceId {
      /**
       * @dev ERC-165 interface id of IERC1404Extend.
       * Includes inherited IERC1404 functions:
       * - detectTransferRestriction(address,address,uint256)
       * - messageForTransferRestriction(uint8)
       * Plus IERC1404Extend function:
       * - detectTransferRestrictionFrom(address,address,address,uint256)
       *
       * Computed value: 0x78a8de7d
       */
      bytes4 public constant ERC1404EXTEND_INTERFACE_ID = 0x78a8de7d;
}
