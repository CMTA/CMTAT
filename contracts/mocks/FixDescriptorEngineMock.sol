
// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;
import {IFixDescriptorEngine} from "../interfaces/engine/IFixDescriptorEngine.sol";

/**
 * @title FixDescriptorEngine Mock
 * @notice Mock implementation for testing - NOT for production use
 * @dev Provides simple storage and retrieval without SSTORE2 or full verification
 */
contract FixDescriptorEngineMock is IFixDescriptorEngine {

    FixDescriptor private _descriptor;
    bytes private _cborData;
    bool private _isInitialized;

    /* ============ Errors ============ */
    error DescriptorNotInitialized();
    error DescriptorAlreadyInitialized();

    /* ============ Events ============ */
    event DescriptorSet(bytes32 indexed fixRoot, uint16 fixMajor, uint16 fixMinor);
    event DescriptorUpdated(bytes32 indexed fixRoot, uint16 fixMajor, uint16 fixMinor);

    /* ============ Admin Functions ============ */

    /**
     * @notice Sets the FIX descriptor (mock - no access control for simplicity)
     * @param descriptor_ The FIX descriptor to store
     * @param cborData_ The CBOR-encoded data
     */
    function setFixDescriptor(
        FixDescriptor calldata descriptor_,
        bytes calldata cborData_
    ) external {
        require(!_isInitialized, DescriptorAlreadyInitialized());
        _descriptor = descriptor_;
        _cborData = cborData_;
        _isInitialized = true;
        emit DescriptorSet(descriptor_.fixRoot, descriptor_.fixMajor, descriptor_.fixMinor);
    }

    /**
     * @notice Updates the FIX descriptor (mock - allows updates for testing)
     * @param descriptor_ The FIX descriptor to store
     * @param cborData_ The CBOR-encoded data
     */
    function updateFixDescriptor(
        FixDescriptor calldata descriptor_,
        bytes calldata cborData_
    ) external {
        _descriptor = descriptor_;
        _cborData = cborData_;
        _isInitialized = true;
        emit DescriptorUpdated(descriptor_.fixRoot, descriptor_.fixMajor, descriptor_.fixMinor);
    }

    /* ============ View Functions ============ */

    /// @inheritdoc IFixDescriptorEngine
    function getFixDescriptor()
        external
        view
        override
        returns (FixDescriptor memory descriptor)
    {
        if (!_isInitialized) {
            revert DescriptorNotInitialized();
        }
        return _descriptor;
    }

    /// @inheritdoc IFixDescriptorEngine
    function getFixRoot()
        external
        view
        override
        returns (bytes32 fixRoot)
    {
        return _descriptor.fixRoot;
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
        // Mock implementation - simple hash check without full Merkle verification
        bytes32 leaf = keccak256(abi.encodePacked(pathCBOR, value));

        // For mock, just verify proof is not empty and root matches
        if (proof.length == 0 || directions.length != proof.length) {
            return false;
        }

        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            if (directions[i]) {
                computedHash = keccak256(abi.encodePacked(computedHash, proof[i]));
            } else {
                computedHash = keccak256(abi.encodePacked(proof[i], computedHash));
            }
        }

        return computedHash == _descriptor.fixRoot;
    }

    /// @inheritdoc IFixDescriptorEngine
    function getHumanReadableDescriptor()
        external
        view
        override
        returns (string memory readable)
    {
        if (!_isInitialized) {
            return "FIX Descriptor not initialized";
        }

        // Mock implementation: Returns simplified output
        // Production should use FixHumanReadable.toHumanReadable() with full CBOR parsing
        // and dictionary contract for tag name lookups

        string memory dictInfo = "";
        if (_descriptor.dictionaryContract != address(0)) {
            dictInfo = string(abi.encodePacked(
                " | Dict: ",
                _addressToHexString(_descriptor.dictionaryContract)
            ));
        }

        return string(abi.encodePacked(
            "FIX ",
            _uint16ToString(_descriptor.fixMajor),
            ".",
            _uint16ToString(_descriptor.fixMinor),
            " | Root: 0x",
            _bytes32ToHexString(_descriptor.fixRoot),
            dictInfo,
            " | [MOCK - Use production engine for full CBOR parsing]"
        ));
    }

    /// @inheritdoc IFixDescriptorEngine
    function getFixCBORChunk(uint256 start, uint256 size)
        external
        view
        override
        returns (bytes memory chunk)
    {
        if (!_isInitialized) {
            revert DescriptorNotInitialized();
        }

        // If fixCBORPtr is set, read from SSTORE2 bytecode (like production)
        // Otherwise read from storage (for testing without SSTORE2)
        if (_descriptor.fixCBORPtr != address(0)) {
            return _readFromSSTORE2(_descriptor.fixCBORPtr, start, size);
        } else {
            return _readFromStorage(start, size);
        }
    }

    /* ============ Internal Reading Functions ============ */

    /**
     * @dev Read chunk from SSTORE2 bytecode (simulates production behavior)
     * @param ptr SSTORE2 contract address
     * @param start Start offset
     * @param size Chunk size
     * @return chunk The data chunk
     */
    function _readFromSSTORE2(address ptr, uint256 start, uint256 size)
        internal
        view
        returns (bytes memory chunk)
    {
        // Get code size using extcodesize
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(ptr)
        }

        require(codeSize > 0, "No CBOR data at pointer");

        // Data starts at byte 1 (after STOP byte at position 0)
        // Data length is codeSize - 1
        uint256 dataLength = codeSize - 1;

        // Validate and adjust range
        if (start >= dataLength) {
            return new bytes(0);
        }

        uint256 end = start + size;
        if (end > dataLength) {
            end = dataLength;
        }

        uint256 actualSize = end - start;

        // Use extcodecopy to read directly from contract bytecode
        // Add 1 to start to skip the STOP byte (data begins at position 1)
        chunk = new bytes(actualSize);
        assembly {
            extcodecopy(ptr, add(chunk, 0x20), add(start, 1), actualSize)
        }
    }

    /**
     * @dev Read chunk from storage array (for testing without SSTORE2)
     * @param start Start offset
     * @param size Chunk size
     * @return chunk The data chunk
     */
    function _readFromStorage(uint256 start, uint256 size)
        internal
        view
        returns (bytes memory chunk)
    {
        uint256 dataLength = _cborData.length;

        // Validate and adjust range
        if (start >= dataLength) {
            return new bytes(0);
        }

        uint256 end = start + size;
        if (end > dataLength) {
            end = dataLength;
        }

        uint256 actualSize = end - start;
        chunk = new bytes(actualSize);

        // Copy data from storage
        for (uint256 i = 0; i < actualSize; i++) {
            chunk[i] = _cborData[start + i];
        }
    }

    /// @inheritdoc IFixDescriptorEngine
    function isInitialized()
        external
        view
        override
        returns (bool initialized)
    {
        return _isInitialized;
    }

    /* ============ Helper Functions ============ */

    function _uint16ToString(uint16 value) private pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint16 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint16(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function _bytes32ToHexString(bytes32 value) private pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(64);
        for (uint256 i = 0; i < 32; i++) {
            str[i*2] = alphabet[uint8(value[i] >> 4)];
            str[1+i*2] = alphabet[uint8(value[i] & 0x0f)];
        }
        return string(str);
    }

    function _addressToHexString(address addr) private pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(42); // "0x" + 40 hex chars
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < 20; i++) {
            uint8 b = uint8(uint160(addr) >> (8 * (19 - i)));
            str[2 + i * 2] = alphabet[b >> 4];
            str[3 + i * 2] = alphabet[b & 0x0f];
        }
        return string(str);
    }
}
