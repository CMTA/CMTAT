//SPDX-License-Identifier: MPL-2.0

pragma solidity 0.8.17;

library FactoryErrors {
    error CMTAT_Factory_AddressZeroNotAllowedForFactoryAdmin();
    error CMTAT_Factory_AddressZeroNotAllowedForBeaconOwner();
    error CMTAT_Factory_AddressZeroNotAllowedForLogicContract();
    error CMTAT_Factory_SaltAlreadyUsed();
}