// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

/**
 * @title DataContractFactory
 * @notice Factory for deploying SSTORE2-style data contracts
 * @dev Uses the same pattern as 0xSequence's SSTORE2 library
 * Stores data as contract bytecode which is much more gas-efficient than storage
 */
contract DataContractFactory {
    event DataDeployed(address indexed ptr, uint256 length);

    /**
     * @notice Deploy data to a contract using SSTORE2 pattern
     * @dev Prepends STOP opcode (0x00) to prevent calls to the contract
     * The data can then be read using EXTCODECOPY, skipping the first byte
     * @param data The data to store
     * @return ptr Address of the deployed data contract
     */
    function deploy(bytes calldata data) external returns (address ptr) {
        // Prepend STOP opcode (0x00) to prevent calls to the contract
        bytes memory runtimeCode = abi.encodePacked(hex"00", data);

        // Create initialization code that returns the runtime code
        // Pattern from 0xSequence SSTORE2:
        // 0x63 - PUSH4 (size)
        // size - runtime code size (4 bytes)
        // 0x80 - DUP1
        // 0x60 0x0E - PUSH1 14 (offset where runtime code starts)
        // 0x60 0x00 - PUSH1 0 (memory destination)
        // 0x39 - CODECOPY
        // 0x60 0x00 - PUSH1 0 (offset in memory to return from)
        // 0xF3 - RETURN
        bytes memory creationCode = abi.encodePacked(
            hex"63",
            uint32(runtimeCode.length),
            hex"80_60_0E_60_00_39_60_00_F3",
            runtimeCode
        );

        assembly {
            ptr := create(0, add(creationCode, 0x20), mload(creationCode))
        }

        require(ptr != address(0), "DEPLOY_FAIL");
        emit DataDeployed(ptr, data.length);
    }

    /**
     * @notice Read data from an SSTORE2 pointer
     * @dev Helper function to read data deployed via this factory
     * @param ptr Address of the data contract
     * @return data The stored data (excluding STOP byte)
     */
    function read(address ptr) external view returns (bytes memory data) {
        // Get code size
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(ptr)
        }

        require(codeSize > 0, "NO_CODE");

        // Data starts at byte 1 (after STOP byte at position 0)
        uint256 dataLength = codeSize - 1;
        data = new bytes(dataLength);

        assembly {
            // extcodecopy(address, memory destination, code offset, size)
            // Skip first byte (STOP opcode) by starting at offset 1
            extcodecopy(ptr, add(data, 0x20), 1, dataLength)
        }
    }

    /**
     * @notice Read a chunk of data from an SSTORE2 pointer
     * @dev More gas-efficient when you don't need all the data
     * @param ptr Address of the data contract
     * @param start Start offset (in the data, not including STOP byte)
     * @param size Number of bytes to read
     * @return chunk The requested data chunk
     */
    function readChunk(address ptr, uint256 start, uint256 size)
        external
        view
        returns (bytes memory chunk)
    {
        // Get code size
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(ptr)
        }

        require(codeSize > 0, "NO_CODE");

        // Data starts at byte 1 (after STOP byte)
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
        chunk = new bytes(actualSize);

        assembly {
            // Add 1 to start to skip the STOP byte
            extcodecopy(ptr, add(chunk, 0x20), add(start, 1), actualSize)
        }
    }
}
