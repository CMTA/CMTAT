// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
 * @title IFixDescriptorEngine
 * @notice Interface for external FIX descriptor engines
 * @dev Defines the standard interface for managing FIX Protocol descriptors
 * following the ERC-FIX specification with CBOR encoding and Merkle commitments
 */
interface IFixDescriptorEngine {

    /// @notice FIX descriptor structure per ERC-FIX spec
    struct FixDescriptor {
        uint16  fixMajor;              // FIX version major (e.g., 5)
        uint16  fixMinor;              // FIX version minor (e.g., 0)
        bytes32 dictHash;              // FIX dictionary hash
        address dictionaryContract;    // FixDictionary contract address
        bytes32 fixRoot;               // Merkle root commitment
        address fixCBORPtr;            // SSTORE2 data address
        uint32  fixCBORLen;            // CBOR payload length
        string  fixURI;                // Optional off-chain mirror URI
    }

    /* ============ View Functions ============ */

    /**
     * @notice Returns the complete FIX descriptor
     * @return descriptor The FIX descriptor with all metadata
     */
    function getFixDescriptor() external view returns (FixDescriptor memory descriptor);

    /**
     * @notice Returns only the Merkle root for gas-efficient verification
     * @return fixRoot The Merkle root commitment
     */
    function getFixRoot() external view returns (bytes32 fixRoot);

    /**
     * @notice Verifies a specific field using Merkle proof
     * @param pathCBOR CBOR-encoded path to the field (e.g., [55] for Symbol)
     * @param value The field value bytes to verify
     * @param proof Array of sibling hashes for Merkle proof
     * @param directions Boolean array indicating left (false) or right (true) at each level
     * @return valid True if the field is valid, false otherwise
     */
    function verifyField(
        bytes calldata pathCBOR,
        bytes calldata value,
        bytes32[] calldata proof,
        bool[] calldata directions
    ) external view returns (bool valid);

    /**
     * @notice Returns a human-readable representation of the FIX descriptor
     * @dev Parses CBOR and formats as readable string (JSON-like or FIX tag=value)
     * @return readable Human-readable descriptor string
     */
    function getHumanReadableDescriptor() external view returns (string memory readable);

    /**
     * @notice Get CBOR data chunk from SSTORE2 storage
     * @dev Reads from SSTORE2 contract bytecode, handling STOP byte offset
     * @param start Start offset (in the data, not including STOP byte)
     * @param size Number of bytes to read
     * @return chunk The requested CBOR data
     */
    function getFixCBORChunk(uint256 start, uint256 size) external view returns (bytes memory chunk);

    /**
     * @notice Checks if a FIX descriptor has been initialized
     * @return initialized True if descriptor is set, false otherwise
     */
    function isInitialized() external view returns (bool initialized);
}
