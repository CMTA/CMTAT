// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {IFixDescriptorEngine} from "../interfaces/engine/IFixDescriptorEngine.sol";
import {IFixDescriptor} from "@fixdescriptorkit/contracts/src/IFixDescriptor.sol";
import {FixDescriptorLib} from "@fixdescriptorkit/contracts/src/FixDescriptorLib.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title FixDescriptorEngine
 * @notice Production implementation of FIX descriptor engine using FixDescriptorLib
 * @dev Uses the full FixDescriptorLib from @fixdescriptorkit/contracts for all functionality
 * including SSTORE2 reading, Merkle verification, and human-readable output with CBOR parsing
 */
contract FixDescriptorEngine is IFixDescriptorEngine, Ownable {
    using FixDescriptorLib for FixDescriptorLib.Storage;

    /// @notice Storage for FIX descriptor using FixDescriptorLib
    FixDescriptorLib.Storage private _fixDescriptor;

    /* ============ Events ============ */
    // Note: FixDescriptorLib emits its own events (FixDescriptorSet, FixDescriptorUpdated)
    // through IFixDescriptor interface

    /* ============ Errors ============ */
    error DescriptorNotInitialized();

    /**
     * @notice Constructor
     * @param initialOwner Address to receive ownership
     */
    constructor(address initialOwner) Ownable(initialOwner) {}

    /* ============ Admin Functions ============ */

    /**
     * @notice Sets the FIX descriptor
     * @dev Can be called multiple times (library handles first-set vs update)
     * Emits FixDescriptorSet (first time) or FixDescriptorUpdated (subsequent)
     * Requires owner privileges
     * @param descriptor_ The complete FixDescriptor struct (with fixCBORPtr already set via SSTORE2)
     */
    function setFixDescriptor(
        FixDescriptor calldata descriptor_
    ) external onlyOwner {
        IFixDescriptor.FixDescriptor calldata libDescriptor = _asFixDescriptor(descriptor_);
        _fixDescriptor.setDescriptor(libDescriptor);
    }

    /* ============ View Functions ============ */

    /// @inheritdoc IFixDescriptorEngine
    function getFixDescriptor()
        external
        view
        override
        returns (FixDescriptor memory descriptor)
    {
        if (!_fixDescriptor.isInitialized()) {
            revert DescriptorNotInitialized();
        }
        IFixDescriptor.FixDescriptor memory libDescriptor = _fixDescriptor.getDescriptor();
        return _fromLibDescriptor(libDescriptor);
    }

    /// @inheritdoc IFixDescriptorEngine
    function getFixRoot()
        external
        view
        override
        returns (bytes32 fixRoot)
    {
        if (!_fixDescriptor.isInitialized()) {
            revert DescriptorNotInitialized();
        }
        return _fixDescriptor.getRoot();
    }

    /// @inheritdoc IFixDescriptorEngine
    function verifyField(
        bytes calldata pathCBOR,
        bytes calldata value,
        bytes32[] calldata proof,
        bool[] calldata directions
    )
        external
        view
        override
        returns (bool valid)
    {
        if (!_fixDescriptor.isInitialized()) {
            return false;
        }
        return _fixDescriptor.verifyFieldProof(pathCBOR, value, proof, directions);
    }

    /// @inheritdoc IFixDescriptorEngine
    function getHumanReadableDescriptor()
        external
        view
        override
        returns (string memory readable)
    {
        if (!_fixDescriptor.isInitialized()) {
            return "FIX Descriptor not initialized";
        }
        // This uses FixHumanReadable.toHumanReadable() internally
        // Requires dictionaryContract to be set for full tag name lookups
        return _fixDescriptor.getHumanReadable();
    }

    /// @inheritdoc IFixDescriptorEngine
    function getFixCBORChunk(uint256 start, uint256 size)
        external
        view
        override
        returns (bytes memory chunk)
    {
        if (!_fixDescriptor.isInitialized()) {
            return "";
        }
        // Reads from SSTORE2 bytecode using extcodecopy
        return _fixDescriptor.getFixCBORChunk(start, size);
    }

    /// @inheritdoc IFixDescriptorEngine
    function isInitialized()
        external
        view
        override
        returns (bool initialized)
    {
        return _fixDescriptor.isInitialized();
    }

    /**
     * @notice Get complete CBOR data from SSTORE2 storage
     * @dev Convenience function to read all CBOR data at once
     * Uses FixDescriptorLib.getFullCBORData() internally
     * @return cborData The complete CBOR-encoded descriptor
     */
    function getFullCBORData() external view returns (bytes memory cborData) {
        if (!_fixDescriptor.isInitialized()) {
            return "";
        }
        return _fixDescriptor.getFullCBORData();
    }

    function _asFixDescriptor(
        FixDescriptor calldata descriptor_
    )
        private
        pure
        returns (IFixDescriptor.FixDescriptor calldata libDescriptor)
    {
        assembly {
            libDescriptor := descriptor_
        }
    }

    function _fromLibDescriptor(
        IFixDescriptor.FixDescriptor memory libDescriptor
    ) private pure returns (FixDescriptor memory descriptor) {
        descriptor.fixMajor = libDescriptor.fixMajor;
        descriptor.fixMinor = libDescriptor.fixMinor;
        descriptor.dictHash = libDescriptor.dictHash;
        descriptor.dictionaryContract = libDescriptor.dictionaryContract;
        descriptor.fixRoot = libDescriptor.fixRoot;
        descriptor.fixCBORPtr = libDescriptor.fixCBORPtr;
        descriptor.fixCBORLen = libDescriptor.fixCBORLen;
        descriptor.fixURI = libDescriptor.fixURI;
    }
}
