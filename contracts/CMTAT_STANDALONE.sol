//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "./modules/CMTAT_BASE.sol";

contract CMTAT_STANDALONE is CMTAT_BASE {
    /**
     * @notice Contract version for standalone deployment
     * @param forwarderIrrevocable address of the forwarder, required for the gasless support
     * @param admin address of the admin of contract (Access Control)
     * @param nameIrrevocable name of the token
     * @param symbolIrrevocable name of the symbol
     * @param decimalsIrrevocable number of decimals used to get its user representation, should be 0 to be compliant with the CMTAT specifications.
     * @param tokenId_ name of the tokenId
     * @param terms_ terms associated with the token
     * @param ruleEngine_ address of the ruleEngine to apply rules to transfers
     * @param information_ additional information to describe the token
     * @param flag_ add information under the form of bit(0, 1)
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address forwarderIrrevocable,
        address admin,
        string memory nameIrrevocable,
        string memory symbolIrrevocable,
        uint8 decimalsIrrevocable,
        string memory tokenId_,
        string memory terms_,
        IEIP1404Wrapper ruleEngine_,
        string memory information_,
        uint256 flag_
    ) MetaTxModule(forwarderIrrevocable) {
        // Initialize the contract to avoid front-running
        // Warning : do not initialize the proxy
        initialize(
            admin,
            nameIrrevocable,
            symbolIrrevocable,
            decimalsIrrevocable,
            tokenId_,
            terms_,
            ruleEngine_,
            information_,
            flag_
        );
    }

    // No storage gap because the contract is deployed in standalone mode
}
