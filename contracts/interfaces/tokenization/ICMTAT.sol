// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IERC1643CMTAT} from "./draft-IERC1643CMTAT.sol";
import {IERC1643} from "./draft-IERC1643.sol";

// The former `ICMTATDeactivate` interface is now standardized as ERC-8343 and lives in
// {IERC8343} (`./draft-IERC8343.sol`).


/** 
* @title ICMTATBase - Core Tokenization Metadata Interface as part of CMTAT specification
* @notice Defines base properties and metadata structure for a tokenized asset.
* @dev Includes token ID, terms (using IERC1643-compliant document), and a general information field.
*/
interface ICMTATBase {
    /* ============ Struct ============ */
     /*
     * @dev A reference to (e.g. in the form of an Internet address) or a hash of the tokenization terms
     */ 
     struct CMTATTerms {
 	    string name;
 	    IERC1643.Document doc;
    }
    /* ============ Events ============ */
    /**
    * @notice Emitted when the general information field is updated.
    * @param newInformation The newly assigned metadata or descriptive text.
    */
    event Information(
        string newInformation
    );
    /**
     * @notice Emitted when new tokenization terms are set.
     * @param newTerm The new Terms structure containing name and document reference.
     */
    event Terms(CMTATTerms newTerm);

    /**
     * @notice Emitted when the token ID is set or updated.
     * @param newTokenIdIndexed The token ID (indexed for filtering).
     * @param newTokenId The full token ID string.
     */
    event TokenId(string indexed newTokenIdIndexed, string newTokenId);

    /* ============ View Functions ============ */

    /*
    * @notice return tokenization tokenId
    */
    function tokenId() external view returns (string memory tokenId_);
    /*
    * @notice returns tokenization terms
    */
    function terms() external view returns (CMTATTerms memory terms_);

    /*
    * @notice returns information field
    */
    function information() external view returns (string memory information_);


    /* ============ Write Functions ============ */
    /**
     * @notice Sets a new tokenization token ID.
     * @param tokenId_ The token ID string to assign to the tokenized asset.
     */
    function setTokenId(
        string calldata tokenId_
    ) external ;

    /**
     * @notice Sets new tokenization terms using a document reference.
     * @param terms_ The `DocumentInfo` structure referencing the terms document (name + URI + hash).
     */
    function setTerms(IERC1643CMTAT.DocumentInfo calldata terms_) external;

    /**
     * @notice Sets or updates the general information field.
     * @param information_ A string describing token attributes, usage, or metadata URI.
     */
    function setInformation(
        string calldata information_
    ) external;
}

interface ICMTATCreditEvents {
     /**
     * @notice Returns credit events
     */
    function creditEvents() external view returns(CreditEvents memory creditEvents_);

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
    struct DebtInformation {
        DebtIdentifier debtIdentifier;
        DebtInstrument debtInstrument;
    }
    /**
    * @dev Information on the issuer and other persons involved
    */
    struct DebtIdentifier {
        string issuerName;
        string issuerDescription;
        string guarantor;
        string debtHolder;
    }
    /**
    * dev Information on the Instruments
    */
    struct DebtInstrument {
        // uint256
        uint256 interestRate;
        uint256 parValue;
        uint256 minimumDenomination;
        // string
        string issuanceDate;
        string maturityDate;
        string couponPaymentFrequency;
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
        string currency; 
        // address
        address currencyContract;
    }
    /**
     * @notice Returns debt information
     */
    function debt() external view returns(DebtInformation memory debtInformation_);
}
