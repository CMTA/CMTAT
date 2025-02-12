//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {ERC1363Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC1363Upgradeable.sol";
import {ERC20Upgradeable, IERC20} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ERC2771ContextUpgradeable} from "./wrapper/extensions/MetaTxModule.sol";
import {AccessControlUpgradeable} from "./security/AuthorizationModule.sol";
import {CMTAT_BASE} from "./CMTAT_BASE.sol";

/**
* @title CMTAT Proxy version for ERC1363
*/
abstract contract CMTAT_ERC1363_BASE is ERC1363Upgradeable,CMTAT_BASE {
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    /**
     * 
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1363Upgradeable, AccessControlUpgradeable) returns (bool) {
        return ERC1363Upgradeable.supportsInterface(interfaceId) || AccessControlUpgradeable.supportsInterface(interfaceId);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    )
        public
        virtual
        override(ERC20Upgradeable, CMTAT_BASE, IERC20)
        returns (bool)
    {
        return CMTAT_BASE.transferFrom(sender, recipient, amount);
    }

    function decimals()
        public
        view
        virtual
        override(ERC20Upgradeable, CMTAT_BASE)
        returns (uint8)
    {
        return CMTAT_BASE.decimals();
    }


        /**
     * @notice Returns the name of the token.
     */
    function name() public virtual override(ERC20Upgradeable, CMTAT_BASE) view returns (string memory) {
        return CMTAT_BASE.name();
    }

    /**
     * @notice Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public virtual override(ERC20Upgradeable, CMTAT_BASE) view returns (string memory) {
        return CMTAT_BASE.symbol();
    }



     /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev
     *
     */
    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20Upgradeable, CMTAT_BASE) {
        CMTAT_BASE._update(from, to, amount);
    }

    /**
    * @dev initializer function
    */
    function __CMTAT_openzeppelin_init_unchained() internal virtual override onlyInitializing {
        __ERC1363_init_unchained();
        CMTAT_BASE.__CMTAT_openzeppelin_init_unchained();
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
        override(ContextUpgradeable, CMTAT_BASE)
        returns (address sender)
    {
        return CMTAT_BASE._msgSender();
    }

    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     */
    function _contextSuffixLength() internal view 
    override(ContextUpgradeable, CMTAT_BASE)
    returns (uint256) {
         return CMTAT_BASE._contextSuffixLength();
    }

    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     */
    function _msgData()
        internal
        view
        override(ContextUpgradeable, CMTAT_BASE)
        returns (bytes calldata)
    {
        return CMTAT_BASE._msgData();
    }
}
