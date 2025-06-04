//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
/* ==== OpenZeppelin === */
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {ERC1363Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC1363Upgradeable.sol";
import {ERC20Upgradeable, IERC20} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
/* ==== Module === */
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {CMTATBase, CMTATBaseCommon} from "./CMTATBase.sol";
import {CMTATBaseOption, ERC20CrossChainModule} from "../modules/CMTATBaseOption.sol";
/**
* @title CMTAT Base for ERC-1363
*/
abstract contract CMTATBaseERC1363 is ERC1363Upgradeable,CMTATBaseOption{
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    /**
     * 
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1363Upgradeable, ERC20CrossChainModule) returns (bool) {
        return ERC1363Upgradeable.supportsInterface(interfaceId) || ERC20CrossChainModule.supportsInterface(interfaceId);
    }

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
    * @inheritdoc CMTATBaseOption
    */
    function _msgSender()
        internal
        view
        override(ContextUpgradeable, CMTATBaseOption)
        returns (address sender)
    {
        return CMTATBaseOption._msgSender();
    }

    /**
    * @inheritdoc CMTATBaseOption
    */
    function _contextSuffixLength() internal view 
    override(ContextUpgradeable, CMTATBaseOption)
    returns (uint256) {
         return CMTATBaseOption._contextSuffixLength();
    }

    /**
    * @inheritdoc CMTATBaseOption
    */
    function _msgData()
        internal
        view
        override(ContextUpgradeable, CMTATBaseOption)
        returns (bytes calldata)
    {
        return CMTATBaseOption._msgData();
    }
}
