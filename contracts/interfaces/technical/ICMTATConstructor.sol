//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {IRuleEngine} from "../engine/IRuleEngine.sol";
import {IERC1643CMTAT} from "../tokenization/draft-IERC1643CMTAT.sol";


/**
* @notice interface to represent arguments used for CMTAT constructor / initialize
*/
interface ICMTATConstructor {
    struct Engine {
        IRuleEngine ruleEngine;
    }
    struct ERC20Attributes {
        // token name,
        string name;
        // token symbol
        string symbol;
        // number of decimals of the token, must be 0 to be compliant with Swiss law as per CMTAT specifications (non-zero decimal number may be needed for other use cases)
        uint8 decimalsIrrevocable;
    }
    struct ExtraInformationAttributes {
        // ISIN or other identifier
        string tokenId;
        // terms associated with the token
        IERC1643CMTAT.DocumentInfo terms;
        // additional information to describe the token
        string information;
    }
}
