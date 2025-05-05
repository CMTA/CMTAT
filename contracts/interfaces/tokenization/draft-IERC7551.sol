//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;


interface IERC7551Mint {
    /**
     * @notice Emitted when the specified  `value` amount of new tokens are created and
     * allocated to the specified `account`.
     */
    event Mint(address indexed account, uint256 value, bytes data);
    /**
    * This function MUST increase the balance of to by amount without decreasing the amount of tokens from any other holder. 
    * This function MUST throw if the sum of amount and the amount of already issued tokens is greater than the total supply. 
    * It MUST emit a Transfer as well as an Mint event. 
    * If {IERC7551Pause} is implemented:
    *   Paused transfers MUST NOT prevent an issuance. 
    * The data parameter MAY be used to further document the action.
    */
    function mint(address to, uint256 amount, bytes calldata data) external;
}

interface IERC7551Burn {
    /**
    * @notice Emitted when the specified `value` amount of tokens owned by `owner`are destroyed with the given `reason`
    */
    event Burn(address indexed owner, uint256 value, bytes data);
    /*
    * This function MUST increase the balance of to by amount without decreasing the amount of tokens from any other holder. 
    * This function MUST throw if the sum of amount and the amount of already issued tokens is greater than the total supply. 
    * It MUST emit a Transfer as well as an TokensIssued event. 
    * If {IERC7551Pause} is implemented:
    *   Paused transfers MUST NOT prevent an issuance. The data parameter MAY be used to further document the action.
    */
    function burn(address to, uint256 amount, bytes calldata data) external;
}

interface IERC7551Pause {
    /*
    * This function MUST return true if token transfers are paused and MUST return false otherwise. 
    * If this function returns true, it MUST NOT be possible to transfer tokens to other accounts 
    * and the function canTransfer() MUST return false.
    */
    function paused() external view returns (bool);
    /**
    * If _paused is provided as true transfers MUST become paused. 
    * If false is provided, transfers MUST be unpaused. 
    * The function MUST throw if true is provided although transfers are already paused as well as if false is provided while transfers are already unpaused. 
    */
    function pause() external;
    function unpause() external;
}

interface IERC7551ERC20Enforcement {
    /**
    *  For events, see {IERC3643Partial - IERC3643EnforcementPartial}
    *  
    */

    /**
    * This function MUST return the unfrozen balance of an account. 
    * This balance can be used by the account for transfers to other account addresses.
    */
    function getActiveBalanceOf(address account) external view returns (uint256);
    /**
    * This function MUST return the frozen balance of an account. 
    * It MUST NOT be possible to transfer frozen tokens to other accounts. 
    * The implementation MAY provide other ways to transfer frozen tokens. 
    * If the sender’s unfrozen (“active”) balance is less than the amount to be transferred, 
    * the canTransfer() and canTransferFrom() MUST return false.
    */
    function getFrozenTokens(address account) external view returns (uint256);
    function freezePartialTokens(address account, uint256 amount) external;
    function unfreezePartialTokens(address account, uint256 amount) external;
    /*
    * This function MUST transfer amount tokens to to without requiring the consent of from. 
    * The function MUST throw if from’s balance is less than amount (including frozen tokens). 
    * If the frozen balance of from is used for the transfer a TokenUnfrozen event must be emitted. 
    * The function MUST emit a Transfer event. The data parameter MAY be used to further document the action.
    */
    function forcedTransfer(address account, address to, uint256 value, bytes calldata data) external returns (bool);

}

interface IERC7551Compliance {
     /*
    * This function MUST return true if the message sender is able to transfer amount tokens to to respecting all compliance, investor eligibility and other implemented restrictions. Otherwise it MUST return false.
    */
    function canTransfer(address from, address to, uint256 amount) external view returns (bool);
}


interface IERC7551Base {
    /*
    * @notice Returns the metadata file
    */
    function metaData() external view returns (string memory);

   

    /*
    * This function MUST update the metaData value, generally an url
    * It MAY be empty.
    *
    */
    function setMetaData(string calldata metaData) external;
}


