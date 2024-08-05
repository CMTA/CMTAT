//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "./modules/CMTAT_BASE.sol";

contract CMTAT_STANDALONE is CMTAT_BASE {
    /**
     * @notice Contract version for standalone deployment
     * @param forwarderIrrevocable address of the forwarder, required for the gasless support
     * @param admin address of the admin of contract (Access Control)
     * @param authorizationEngineIrrevocable
     * @param nameIrrevocable name of the token
     * @param symbolIrrevocable name of the symbol
     * @param decimalsIrrevocable number of decimals used to get its user representation, should be 0 to be compliant with the CMTAT specifications.
     * @param tokenId_ name of the tokenId
     * @param terms_ terms associated with the token
     * @param information_ additional information to describe the token
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
        string memory information_,
        IEngine.Engine memory engine_ 
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
            information_,
            engine_
        );
    }

    // No storage gap because the contract is deployed in standalone mode
}
