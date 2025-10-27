// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
/* ==== OpenZeppelin === */
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {ERC1363Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC1363Upgradeable.sol";
import {ERC20Upgradeable, IERC20} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
/* ==== Module === */
import {CMTATBaseRuleEngine} from "./1_CMTATBaseRuleEngine.sol";
import {CMTATBaseERC2771, CMTATBaseERC20CrossChain} from "../modules/4_CMTATBaseERC2771.sol";

/* ==== Interface and other library === */
import {ICMTATConstructor} from "../interfaces/technical/ICMTATConstructor.sol";
/**
* @title CMTAT Base for ERC-1363
*/
abstract contract CMTATBaseERC1363 is ERC1363Upgradeable,CMTATBaseERC2771{
    /*//////////////////////////////////////////////////////////////
                         INITIALIZER FUNCTION
    //////////////////////////////////////////////////////////////*/
    /**
    * @dev initializer function
    */
    function __CMTAT_openzeppelin_init_unchained(ICMTATConstructor.ERC20Attributes memory ERC20Attributes_) internal virtual override onlyInitializing {
        CMTATBaseRuleEngine.__CMTAT_openzeppelin_init_unchained(ERC20Attributes_);
        __ERC1363_init_unchained();
    }
    
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    /* ============ State functions ============ */

    /**
    * @inheritdoc CMTATBaseERC20CrossChain
    */
    function transfer(address to, uint256 value) public virtual override(ERC20Upgradeable, CMTATBaseERC20CrossChain, IERC20) returns (bool) {
        return CMTATBaseERC20CrossChain.transfer(to, value);
    }

    /**
    * @inheritdoc CMTATBaseERC20CrossChain
    */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    )
        public
        virtual
        override(ERC20Upgradeable, CMTATBaseERC20CrossChain, IERC20)
        returns (bool)
    {
        return CMTATBaseERC20CrossChain.transferFrom(sender, recipient, amount);
    }

    /* ============ View functions ============ */
    /**
     * 
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1363Upgradeable, CMTATBaseERC20CrossChain) returns (bool) {
        return ERC1363Upgradeable.supportsInterface(interfaceId) || CMTATBaseERC20CrossChain.supportsInterface(interfaceId);
    }


    /**
    * @inheritdoc CMTATBaseERC20CrossChain
    */
    function decimals()
        public
        view
        virtual
        override(ERC20Upgradeable, CMTATBaseERC20CrossChain)
        returns (uint8)
    {
        return CMTATBaseERC20CrossChain.decimals();
    }


    /**
    * @inheritdoc CMTATBaseERC20CrossChain
    */
    function name() public virtual override(ERC20Upgradeable, CMTATBaseERC20CrossChain) view returns (string memory) {
        return CMTATBaseERC20CrossChain.name();
    }

    /**
    * @inheritdoc CMTATBaseERC20CrossChain
    */
    function symbol() public virtual override(ERC20Upgradeable, CMTATBaseERC20CrossChain) view returns (string memory) {
        return CMTATBaseERC20CrossChain.symbol();
    }



     /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
    * @inheritdoc CMTATBaseERC20CrossChain
    */
    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20Upgradeable, CMTATBaseERC20CrossChain) {
        CMTATBaseERC20CrossChain._update(from, to, amount);
    }

    /*//////////////////////////////////////////////////////////////
                            ERC2771 MODULE
    //////////////////////////////////////////////////////////////*/
    /**
    * @inheritdoc CMTATBaseERC2771
    */
    function _msgSender()
        internal
        view
        override(ContextUpgradeable, CMTATBaseERC2771)
        returns (address sender)
    {
        return CMTATBaseERC2771._msgSender();
    }

    /**
    * @inheritdoc CMTATBaseERC2771
    */
    function _contextSuffixLength() internal view 
    override(ContextUpgradeable, CMTATBaseERC2771)
    returns (uint256) {
         return CMTATBaseERC2771._contextSuffixLength();
    }

    /**
    * @inheritdoc CMTATBaseERC2771
    */
    function _msgData()
        internal
        view
        override(ContextUpgradeable, CMTATBaseERC2771)
        returns (bytes calldata)
    {
        return CMTATBaseERC2771._msgData();
    }
}
