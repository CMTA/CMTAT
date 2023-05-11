//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "./CMTAT_BASE_SnapshotTest.sol";

contract CMTATSnapshotStandaloneTest is CMTAT_BASE_SnapshotTest {
    /** 
    @notice Contract version for standalone deployment
    @param forwarderIrrevocable address of the forwarder, required for the gasless support
    @param admin address of the admin of contract (Access Control)
    @param nameIrrevocable name of the token
    @param symbolIrrevocable name of the symbol
    @param tokenId name of the tokenId
    @param terms terms associated with the token
    @param ruleEngine address of the ruleEngine to apply rules to transfers
    @param information additional information to describe the token
    @param flag add information under the form of bit(0, 1)
    */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address forwarderIrrevocable,
        address admin,
        string memory nameIrrevocable,
        string memory symbolIrrevocable,
        string memory tokenId,
        string memory terms,
        IEIP1404Wrapper ruleEngine,
        string memory information,
        uint256 flag
    ) MetaTxModule(forwarderIrrevocable) {
        // Initialize the contract to avoid front-running
        // Warning : do not initialize the proxy
        initialize(
            admin,
            nameIrrevocable,
            symbolIrrevocable,
            tokenId,
            terms,
            ruleEngine,
            information,
            flag
        );
    }

    // No storage gap because the contract is deployed in standalone mode
}
