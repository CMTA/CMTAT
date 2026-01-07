// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
/* ==== OpenZeppelin === */
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
/* ==== Module === */
import {CMTATBaseERC20CrossChain} from "./4_CMTATBaseERC20CrossChain.sol";
import {ERC2771Module, ERC2771ContextUpgradeable} from "./wrapper/options/ERC2771Module.sol";
/**
* @title Extend CMTAT Base with ERC2771Module
*/
abstract contract CMTATBaseERC2771 is CMTATBaseERC20CrossChain, ERC2771Module {
    
    /*//////////////////////////////////////////////////////////////
                            ERC2771 MODULE
    //////////////////////////////////////////////////////////////*/
       /**
     * @dev This surcharge is not necessary if you do not use the 2771Module
     */
    function _msgSender()
        internal virtual
        view
        override(ContextUpgradeable, ERC2771ContextUpgradeable)
        returns (address sender)
    {
        return ERC2771ContextUpgradeable._msgSender();
    }

    /**
     * @dev This surcharge is not necessary if you do not use the 2771Module
     */
    function _contextSuffixLength() internal virtual view 
    override(ContextUpgradeable, ERC2771ContextUpgradeable)
    returns (uint256) {
         return ERC2771ContextUpgradeable._contextSuffixLength();
    }

    /**
     * @dev This surcharge is not necessary if you do not use the 2771Module
     */
    function _msgData()
        internal virtual
        view
        override(ContextUpgradeable, ERC2771ContextUpgradeable)
        returns (bytes calldata)
    {
        return ERC2771ContextUpgradeable._msgData();
    }
}
