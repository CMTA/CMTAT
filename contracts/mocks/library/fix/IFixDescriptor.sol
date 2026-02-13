// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IFixDescriptor
 * @notice Standard interface for assets with embedded FIX descriptors
 * @dev Asset contracts (ERC20, ERC721, etc.) implement this to expose their FIX descriptor
 *      This is a local copy for testing purposes to avoid external package dependencies
 */
interface IFixDescriptor {
    /// @notice FIX descriptor structure
    struct FixDescriptor {
        uint16 fixMajor;           // FIX version major (e.g., 4)
        uint16 fixMinor;           // FIX version minor (e.g., 4)
        bytes32 dictHash;          // FIX dictionary/Orchestra hash
        bytes32 fixRoot;           // Merkle root commitment
        address fixSBEPtr;         // SSTORE2 data contract address
        uint32 fixSBELen;          // SBE data length
        string schemaURI;          // Optional SBE schema URI (ipfs:// or https://)
    }

    /// @notice Emitted when descriptor is first set
    event FixDescriptorSet(
        bytes32 indexed fixRoot,
        bytes32 indexed dictHash,
        address fixSBEPtr,
        uint32 fixSBELen
    );

    /// @notice Emitted when descriptor is updated
    event FixDescriptorUpdated(
        bytes32 indexed oldRoot,
        bytes32 indexed newRoot,
        address newPtr
    );

    /**
     * @notice Get the complete FIX descriptor for this asset
     * @return descriptor The FixDescriptor struct
     */
    function getFixDescriptor() external view returns (FixDescriptor memory descriptor);

    /**
     * @notice Get the Merkle root commitment
     * @return root The fixRoot for verification
     */
    function getFixRoot() external view returns (bytes32 root);

    /**
     * @notice Verify a specific field against the committed descriptor
     * @param pathSBE SBE-encoded bytes of the field path
     * @param value Raw FIX value bytes
     * @param proof Merkle proof (sibling hashes)
     * @param directions Direction array (true=right child, false=left child)
     * @return valid True if the proof is valid
     */
    function verifyField(
        bytes calldata pathSBE,
        bytes calldata value,
        bytes32[] calldata proof,
        bool[] calldata directions
    ) external view returns (bool valid);

    /**
     * @notice Get the descriptor engine address (optional)
     * @dev Returns address(0) if token uses embedded storage instead of engine
     * @return engine Address of the FixDescriptorEngine contract, or address(0) if not using engine
     */
    function getDescriptorEngine() external view returns (address engine);
}
