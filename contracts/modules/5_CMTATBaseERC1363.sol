//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
/* ==== OpenZeppelin === */
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {ERC1363Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC1363Upgradeable.sol";
import {ERC20Upgradeable, IERC20} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
/* ==== Module === */
import {CMTATBaseERC1404, CMTATBaseCommon} from "./2_CMTATBaseERC1404.sol";
import {CMTATBaseRuleEngine} from "./1_CMTATBaseRuleEngine.sol";
import {CMTATBaseERC2771, CMTATBaseERC20CrossChain} from "../modules/4_CMTATBaseERC2771.sol";
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
    function __CMTAT_openzeppelin_init_unchained() internal virtual override onlyInitializing {
        __ERC1363_init_unchained();
        CMTATBaseRuleEngine.__CMTAT_openzeppelin_init_unchained();
    }
    
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    /* ============ State functions ============ */

    /**
    * @inheritdoc CMTATBaseCommon
    */
    function transfer(address to, uint256 value) public virtual override(ERC20Upgradeable, CMTATBaseCommon, IERC20) returns (bool) {
        return CMTATBaseCommon.transfer(to, value);
    }

    /**
    * @inheritdoc CMTATBaseCommon
    */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    )
        public
        virtual
        override(ERC20Upgradeable, CMTATBaseCommon, IERC20)
        returns (bool)
    {
        return CMTATBaseCommon.transferFrom(sender, recipient, amount);
    }

    /* ============ View functions ============ */
    /**
     * 
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1363Upgradeable, CMTATBaseERC20CrossChain) returns (bool) {
        return ERC1363Upgradeable.supportsInterface(interfaceId) || CMTATBaseERC20CrossChain.supportsInterface(interfaceId);
    }


    /**
    * @inheritdoc CMTATBaseCommon
    */
    function decimals()
        public
        view
        virtual
        override(ERC20Upgradeable, CMTATBaseCommon)
        returns (uint8)
    {
        return CMTATBaseCommon.decimals();
    }


    /**
    * @inheritdoc CMTATBaseCommon
    */
    function name() public virtual override(ERC20Upgradeable, CMTATBaseCommon) view returns (string memory) {
        return CMTATBaseCommon.name();
    }

    /**
    * @inheritdoc CMTATBaseCommon
    */
    function symbol() public virtual override(ERC20Upgradeable, CMTATBaseCommon) view returns (string memory) {
        return CMTATBaseCommon.symbol();
    }



     /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
    * @inheritdoc CMTATBaseCommon
    */
    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20Upgradeable, CMTATBaseCommon) {
        CMTATBaseCommon._update(from, to, amount);
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
