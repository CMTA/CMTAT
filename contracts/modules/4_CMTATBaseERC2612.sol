// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {ERC20PermitUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {MulticallUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/MulticallUpgradeable.sol";
import {EIP712Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
/* ==== Module === */
import {CMTATBaseERC20CrossChain, CMTATBaseRuleEngine} from "./4_CMTATBaseERC20CrossChain.sol";
/* ==== Interface and other library === */
import {ICMTATConstructor} from "../interfaces/technical/ICMTATConstructor.sol";

/**
* @title Extend CMTAT Base with ERC-2612 Permit and Multicall
*/
abstract contract CMTATBaseERC2612 is CMTATBaseERC20CrossChain, ERC20PermitUpgradeable, MulticallUpgradeable {
    /*//////////////////////////////////////////////////////////////
                         INITIALIZER FUNCTION
    //////////////////////////////////////////////////////////////*/
    /**
    * @dev initializer function
    */
    function __CMTAT_openzeppelin_init_unchained(
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_
    ) internal virtual override onlyInitializing {
        CMTATBaseRuleEngine.__CMTAT_openzeppelin_init_unchained(ERC20Attributes_);
        __EIP712_init_unchained(ERC20Attributes_.name, "1");
        __ERC20Permit_init_unchained(ERC20Attributes_.name);
        __Multicall_init_unchained();
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
    * @inheritdoc ERC20PermitUpgradeable
    * @dev Reverts if the contract is paused or if owner/spender is frozen.
    */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override(ERC20PermitUpgradeable) {
        _canTransferStandardByModuleAndRevert(spender, owner, spender);
        ERC20PermitUpgradeable.permit(owner, spender, value, deadline, v, r, s);
    }

    /* ============ State functions ============ */
    /**
    * @dev revert if the contract is in pause state
    */
    function approve(
        address spender,
        uint256 value
    ) public virtual override(ERC20Upgradeable, CMTATBaseERC20CrossChain) returns (bool) {
        return CMTATBaseERC20CrossChain.approve(spender, value);
    }

    /**
    * @inheritdoc CMTATBaseERC20CrossChain
    */
    function transfer(
        address to,
        uint256 value
    ) public virtual override(ERC20Upgradeable, CMTATBaseERC20CrossChain) returns (bool) {
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
        override(ERC20Upgradeable, CMTATBaseERC20CrossChain)
        returns (bool)
    {
        return CMTATBaseERC20CrossChain.transferFrom(sender, recipient, amount);
    }

    /* ============ View functions ============ */
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
    function name()
        public
        view
        virtual
        override(ERC20Upgradeable, CMTATBaseERC20CrossChain)
        returns (string memory)
    {
        return CMTATBaseERC20CrossChain.name();
    }

    /**
    * @inheritdoc CMTATBaseERC20CrossChain
    */
    function symbol()
        public
        view
        virtual
        override(ERC20Upgradeable, CMTATBaseERC20CrossChain)
        returns (string memory)
    {
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
    ) internal virtual override(ERC20Upgradeable, CMTATBaseERC20CrossChain) {
        CMTATBaseERC20CrossChain._update(from, to, amount);
    }
}
