//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IERC1643CMTAT, IERC1643} from "./draft-IERC1643CMTAT.sol";

/**
* The issuer must be able to “deactivate” the smart contract, to prevent execution of transactions on
* the distributed ledger.
* Contrary to the “burn” function, the “deactivateContract” function
* affects all tokens in issuance, and not only some of them. 
* 
* a) This function is necessary to allow the issuer to carry out certain corporate actions 
* (e.g. share splits, reverse splits or mergers), which 
* require that all existing tokens are either canceled or immobilized and decoupled from the shares
* (i.e. the tokens no longer represent shares).
* 
* b) The “deactivateContract” function can also be used if the issuer decides that it no longer wishes
* to have its shares issued in the form of ledger-based securities
* 
* The “deactivateContract” function does not delete the smart contract’s 
* storage and code, i.e. tokens are not burned by the function, however it permanently and
* irreversibly deactivates the smart contract (unless a proxy is used). 
* 
*/
interface ICMTATDeactivate {
    event Deactivated(address account);
    /**
    * @notice deactivate the contract
    * Warning: the operation is irreversible, be careful
    */
    function deactivateContract() external;

    /**
    * @notice Returns true if the contract is deactivated, and false otherwise.
    */
    function deactivated() external view returns (bool) ;
}


/**
*  BASIC PARAMETERS OF THE TOKEN
* 
* 
*/
interface ICMTATBase {
     /*
     * @dev A reference to (e.g. in the form of an Internet address) or a hash of the tokenization terms
     */ 
     struct Terms {
 	    string name;
 	    IERC1643.Document doc;
    }
    /* ============ Events ============ */
    event Term(Terms newTerm);
    event TokenId(string indexed newTokenIdIndexed, string newTokenId);
    /* ============ Functions ============ */
    /*
    * @notice return tokenization tokenId
    */
    function tokenId() external view returns (string memory);
    /*
    * @notice returns tokenization terms
    */
    function terms() external view returns (Terms memory);

    /*
    * @notice returns information field
    */
    function information() external view returns (string memory);

    /*
    * @notice set tokenization tokenId
    */
    function setTokenId(
        string calldata tokenId_
    ) external ;
    /*
    * @notice set tokenization terms
    */
    function setTerms(IERC1643CMTAT.DocumentInfo calldata terms_) external;

    /*
    * @notice set information field
    */
    function setInformation(
        string calldata information_
    ) external;
}

interface ICMTATCreditEvents {
     /**
     * @notice Returns credit events
     */
    function creditEvents() external view returns(CreditEvents memory);

    struct CreditEvents {
        bool flagDefault;
        bool flagRedeemed;
        string rating;
    }
}
/**
* @notice interface to represent debt tokens
*/
interface ICMTATDebt {
    struct DebtBase {
        uint256 interestRate;
        uint256 parValue;
        string guarantor;
        string bondHolder;
        string maturityDate;
        /*
        * Interest schedule format (if any). The purpose of the interest schedule is to set, in the parameters of the smart
        *   contract, the dates on which the interest payments accrue.
        *    - Format A: start date/end date/period
        *   - Format B: start date/end date/day of period (e.g. quarter or year)
        *    - Format C: date 1/date 2/date 3/….
        */
        string interestScheduleFormat;
        /*
        * - Format A: period (indicating the period between the accrual date for the interest payment and the date on
        *   which the payment is scheduled to be made)
        * - Format B: specific date
        */
        string interestPaymentDate;
        string dayCountConvention;
        string businessDayConvention;
        string publicHolidaysCalendar;
        string issuanceDate;
        string couponFrequency;
    }



    /**
     * @notice Returns debt information
     */
    function debt() external view returns(DebtBase memory);
   
}


