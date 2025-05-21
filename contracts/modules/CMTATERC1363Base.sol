//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
/* ==== OpenZeppelin === */
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {ERC1363Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC1363Upgradeable.sol";
import {ERC20Upgradeable, IERC20} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
/* ==== Module === */
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {AccessControlUpgradeable} from "./security/AuthorizationModule.sol";
import {CMTATBase} from "./CMTATBase.sol";
import {MetaTxModule, ERC2771ContextUpgradeable} from "./wrapper/options/MetaTxModule.sol";

/**
* @title CMTAT Base for ERC-1363
*/
abstract contract CMTATERC1363Base is ERC1363Upgradeable,CMTATBase, MetaTxModule {
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    /**
     * 
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1363Upgradeable, AccessControlUpgradeable) returns (bool) {
        return ERC1363Upgradeable.supportsInterface(interfaceId) || AccessControlUpgradeable.supportsInterface(interfaceId);
    }


    function transfer(address to, uint256 value) public virtual override(ERC20Upgradeable, CMTATBase, IERC20) returns (bool) {
        return CMTATBase.transfer(to, value);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    )
        public
        virtual
        override(ERC20Upgradeable, CMTATBase, IERC20)
        returns (bool)
    {
        return CMTATBase.transferFrom(sender, recipient, amount);
    }


    function decimals()
        public
        view
        virtual
        override(ERC20Upgradeable, CMTATBase)
        returns (uint8)
    {
        return CMTATBase.decimals();
    }


    /**
     * @notice Returns the name of the token.
     */
    function name() public virtual override(ERC20Upgradeable, CMTATBase) view returns (string memory) {
        return CMTATBase.name();
    }

    /**
     * @notice Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public virtual override(ERC20Upgradeable, CMTATBase) view returns (string memory) {
        return CMTATBase.symbol();
    }



     /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20Upgradeable, CMTATBase) {
        CMTATBase._update(from, to, amount);
    }

    /**
    * @dev initializer function
    */
    function __CMTAT_openzeppelin_init_unchained() internal virtual override onlyInitializing {
        __ERC1363_init_unchained();
        CMTATBase.__CMTAT_openzeppelin_init_unchained();
    }

    /*//////////////////////////////////////////////////////////////
                            METAXTX MODULE
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     */
    function _msgSender()
        internal
        view
        override(ContextUpgradeable, ERC2771ContextUpgradeable)
        returns (address sender)
    {
        return ERC2771ContextUpgradeable._msgSender();
    }

    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     */
    function _contextSuffixLength() internal view 
    override(ContextUpgradeable, ERC2771ContextUpgradeable)
    returns (uint256) {
         return ERC2771ContextUpgradeable._contextSuffixLength();
    }

    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     */
    function _msgData()
        internal
        view
        override(ContextUpgradeable, ERC2771ContextUpgradeable)
        returns (bytes calldata)
    {
        return ERC2771ContextUpgradeable._msgData();
    }
}
