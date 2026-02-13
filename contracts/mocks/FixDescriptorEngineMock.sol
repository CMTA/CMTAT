// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {IFixDescriptorEngine} from "../interfaces/engine/IFixDescriptorEngine.sol";
import {IFixDescriptor} from "./library/fix/IFixDescriptor.sol";

/*
 * @title a FixDescriptorEngine mock for testing, not suitable for production
 */
contract FixDescriptorEngineMock is IFixDescriptorEngine, IFixDescriptor {
    address public immutable token;
    IFixDescriptor.FixDescriptor private _descriptor;
    bool private _initialized;
    bool private _verifyFieldResult; // for testing verification results

    constructor(address token_, address admin) {
        token = token_;
        // admin not used but kept for consistency with SnapshotEngineMock pattern
        _verifyFieldResult = true; // default to true for tests
    }

    /**
     * @notice Set the descriptor for testing
     * @param descriptor The FixDescriptor struct to store
     */
    function setFixDescriptor(IFixDescriptor.FixDescriptor memory descriptor) external {
        bytes32 oldRoot = _descriptor.fixRoot;
        _descriptor = descriptor;
        _initialized = true;
        
        if (oldRoot != bytes32(0)) {
            emit FixDescriptorUpdated(oldRoot, descriptor.fixRoot, descriptor.fixSBEPtr);
        } else {
            emit FixDescriptorSet(
                descriptor.fixRoot,
                descriptor.dictHash,
                descriptor.fixSBEPtr,
                descriptor.fixSBELen
            );
        }
    }

    /**
     * @notice Set the verifyField result for testing
     * @param result The boolean result to return from verifyField
     */
    function setVerifyFieldResult(bool result) external {
        _verifyFieldResult = result;
    }

    /**
     * @notice Get the complete FIX descriptor
     * @return descriptor The FixDescriptor struct
     */
    function getFixDescriptor() external view override returns (IFixDescriptor.FixDescriptor memory descriptor) {
        return _descriptor;
    }

    /**
     * @notice Get the Merkle root commitment
     * @return root The fixRoot for verification
     */
    function getFixRoot() external view override returns (bytes32 root) {
        return _descriptor.fixRoot;
    }

    /**
     * @notice Verify a specific field against the committed descriptor
     * @param pathSBE SBE-encoded bytes of the field path
     * @param value Raw FIX value bytes
     * @param proof Merkle proof (sibling hashes)
     * @param directions Direction array (true=right child, false=left child)
     * @return valid True if the proof is valid (returns configured test result)
     */
    function verifyField(
        bytes calldata pathSBE,
        bytes calldata value,
        bytes32[] calldata proof,
        bool[] calldata directions
    ) external view override returns (bool valid) {
        // Return configured result for testing
        return _verifyFieldResult;
    }

    /**
     * @notice Get the descriptor engine address
     * @return engine Address of the FixDescriptorEngine contract (returns self)
     */
    function getDescriptorEngine() external view override returns (address engine) {
        return address(this);
    }
}
