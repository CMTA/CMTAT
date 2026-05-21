// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
/* ==== OpenZeppelin === */
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {ERC1363Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC1363Upgradeable.sol";
import {ERC20Upgradeable, IERC20} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
/* ==== Module === */
import {CMTATBaseRuleEngine} from "./3_CMTATBaseRuleEngine.sol";
import {CMTATBaseERC20CrossChain} from "./5_CMTATBaseERC20CrossChain.sol";
import {CMTATBaseERC7551Enforcement} from "./7_CMTATBaseERC7551Enforcement.sol";

/* ==== Interface and other library === */
import {ICMTATConstructor} from "../interfaces/technical/ICMTATConstructor.sol";
/**
* @title CMTAT Base for ERC-1363
*/
abstract contract CMTATBaseERC1363 is ERC1363Upgradeable, CMTATBaseERC7551Enforcement {
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
    * @dev revert if the contract is in pause state
    */
    function approve(address spender, uint256 value) public virtual override(ERC20Upgradeable, CMTATBaseERC7551Enforcement, IERC20) returns (bool) {
        return CMTATBaseERC7551Enforcement.approve(spender, value);
    }

    /**
    * @inheritdoc CMTATBaseERC7551Enforcement
    */
    function transfer(address to, uint256 value) public virtual override(ERC20Upgradeable, CMTATBaseERC7551Enforcement, IERC20) returns (bool) {
        return CMTATBaseERC7551Enforcement.transfer(to, value);
    }

    /**
    * @inheritdoc CMTATBaseERC7551Enforcement
    */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    )
        public
        virtual
        override(ERC20Upgradeable, CMTATBaseERC7551Enforcement, IERC20)
        returns (bool)
    {
        return CMTATBaseERC7551Enforcement.transferFrom(sender, recipient, amount);
    }

    /* ============ View functions ============ */
    /**
     * 
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1363Upgradeable, CMTATBaseERC20CrossChain) returns (bool) {
        return ERC1363Upgradeable.supportsInterface(interfaceId) || CMTATBaseERC20CrossChain.supportsInterface(interfaceId);
    }


    /**
    * @inheritdoc CMTATBaseERC7551Enforcement
    */
    function decimals()
        public
        view
        virtual
        override(ERC20Upgradeable, CMTATBaseERC7551Enforcement)
        returns (uint8)
    {
        return CMTATBaseERC7551Enforcement.decimals();
    }


    /**
    * @inheritdoc CMTATBaseERC7551Enforcement
    */
    function name() public virtual override(ERC20Upgradeable, CMTATBaseERC7551Enforcement) view returns (string memory) {
        return CMTATBaseERC7551Enforcement.name();
    }

    /**
    * @inheritdoc CMTATBaseERC7551Enforcement
    */
    function symbol() public virtual override(ERC20Upgradeable, CMTATBaseERC7551Enforcement) view returns (string memory) {
        return CMTATBaseERC7551Enforcement.symbol();
    }



     /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /*//////////////////////////////////////////////////////////////
                            ERC2771 MODULE
    //////////////////////////////////////////////////////////////*/
    /**
    * @inheritdoc CMTATBaseERC7551Enforcement
    */
    function _msgSender()
        internal
        view
        override(ContextUpgradeable, CMTATBaseERC7551Enforcement)
        returns (address sender)
    {
        return CMTATBaseERC7551Enforcement._msgSender();
    }

    /**
    * @inheritdoc CMTATBaseERC7551Enforcement
    */
    function _contextSuffixLength() internal view 
    override(ContextUpgradeable, CMTATBaseERC7551Enforcement)
    returns (uint256) {
         return CMTATBaseERC7551Enforcement._contextSuffixLength();
    }

    /**
    * @inheritdoc CMTATBaseERC7551Enforcement
    */
    function _msgData()
        internal
        view
        override(ContextUpgradeable, CMTATBaseERC7551Enforcement)
        returns (bytes calldata)
    {
        return CMTATBaseERC7551Enforcement._msgData();
    }
}
