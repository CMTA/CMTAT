// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== FixDescriptorKit === */
import "@fixdescriptorkit/contracts/src/IFixDescriptor.sol";

/**
 * @title IFixDescriptorEngine
 * @notice Interface for FIX Descriptor Engine contract
 * @dev Engine contract that manages FIX descriptor for a single bound token
 *      Following CMTAT engine pattern similar to ISnapshotEngine
 *      One engine instance is bound to one token at construction time
 */
interface IFixDescriptorEngine {
    /**
     * @notice Get the address of the bound token
     * @return token The address of the token this engine is bound to
     */
    function token() external view returns (address);

    /**
     * @notice Get the complete FIX descriptor for the bound token
     * @return descriptor The FixDescriptor struct
     */
    function getFixDescriptor() external view returns (IFixDescriptor.FixDescriptor memory descriptor);

    /**
     * @notice Get the Merkle root commitment for the bound token
     * @return root The fixRoot for verification
     */
    function getFixRoot() external view returns (bytes32 root);

    /**
     * @notice Verify a specific field against the committed descriptor for the bound token
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
     * @notice Get SBE data chunk from SSTORE2 storage for the bound token
     * @param start Start offset (in the data, not including STOP byte)
     * @param size Number of bytes to read
     * @return chunk The requested SBE data
     */
    function getFixSBEChunk(
        uint256 start,
        uint256 size
    ) external view returns (bytes memory chunk);

    /**
     * @notice Set or update the FIX descriptor for the bound token
     * @dev Can only be called by authorized roles
     * @param descriptor The complete FixDescriptor struct
     */
    function setFixDescriptor(IFixDescriptor.FixDescriptor calldata descriptor) external;

    /**
     * @notice Deploy SBE data and set descriptor in one transaction
     * @dev Deploys SBE data using SSTORE2 pattern, then sets the descriptor
     *      This is a convenience function that combines deployment and descriptor setting
     * @param sbeData Raw SBE-encoded data to deploy
     * @param descriptor Descriptor struct (fixSBEPtr and fixSBELen will be set automatically)
     * @return sbePtr Address of the deployed SBE data contract
     */
    function setFixDescriptorWithSBE(
        bytes memory sbeData,
        IFixDescriptor.FixDescriptor memory descriptor
    ) external returns (address sbePtr);
}
