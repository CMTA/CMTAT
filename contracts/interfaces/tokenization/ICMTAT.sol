//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IERC1643CMTAT, IERC1643} from "./draft-IERC1643CMTAT.sol";

/**
* The issuer must be able to “pause” the smart contract, to prevent execution of transactions on
* the distributed ledger until the issuer puts an end to the pause. This function can be used to block
* transactions in case of a “hard fork” of the distributed ledger, pending a decision of the issuer as
* to which version of the distributed ledger it will support.
*/
interface ICMTATDeactivate {
    /**
    * Contrary to the “burn” function mentioned under 5 above, the “deactivateContract” function
    * affects all tokens in issue, and not only some of them. 
    * 
    * a) This function is necessary to allow the issuer to carry out certain corporate actions 
    * (e.g. share splits, reverse splits or mergers), which 
    * require that all existing tokens are either canceled or immobilized and decoupled from the shares
    * (i.e. the tokens no longer represent shares).
    * 
    * b) The “deactivateContract” function can also be used if the issuer decides that it no longer wishes
    * to have its shares issued in the form of ledger-based securities within the meaning of Article
    * 973d CO, but rather as “simple” uncertificated securities within the meaning of Article 973c CO or
    * as certificated securities. 
    * The “deactivateContract” function does not delete the smart contract’s 
    * storage and code, i.e. tokens are not burned by the function, however it permanently and
    * irreversibly deactivates the smart contract (unless a proxy is used). In such cases, the last entries
    * in the distributed ledger make it possible to identify the owners of the uncertificated securities or
    * the persons entitled to receive share certificates.
    */
    event Deactivated(address account);
    function deactivateContract() external;
    function deactivated() external view returns (bool) ;
}


/**
*  BASIC PARAMETERS OF THE TOKEN
* a reference to (e.g. in the form of an Internet address) or a hash of the tokenization terms
* and the information required by law about the distributed ledger and the smart contract 
*/
interface ICMTATBase {
     struct Terms {
 	    string name;
 	    IERC1643.Document doc;
    }
    /* ============ Events ============ */
    event Term(Terms indexed newTermIndexed, Terms newTerm);
    event TokenId(string indexed newTokenIdIndexed, string newTokenId);
    /* ============ Functions ============ */
    /*
    * return tokenization tokenId
    */
    function tokenId() external view returns (string memory);
    /*
    * returns tokenization terms
    */
    function terms() external view returns (Terms memory);
    /*
    * @dev set tokenization tokenId
    */
    function setTokenId(
        string calldata tokenId_
    ) external ;
    /*
    * @dev set tokenization terms
    */
    function setTerms(IERC1643CMTAT.DocumentInfo calldata terms_) external;
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

    struct CreditEvents {
        bool flagDefault;
        bool flagRedeemed;
        string rating;
    }

        /**
     * @dev Returns debt information
     */
    function debt() external view returns(ICMTATDebt.DebtBase memory);
    /**
     * @dev Returns credit events
     */
    function creditEvents() external view returns(ICMTATDebt.CreditEvents memory);
}


