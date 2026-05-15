# Document Management

CMTAT supports two layers of on-chain document management:

1. **Terms** — the primary tokenization terms stored directly in the token contract via `ExtraInformationModule`.
2. **Additional documents** — arbitrary documents managed through an external `DocumentEngine` contract via `DocumentEngineModule`.

## Terms

The tokenization terms are a single `Terms` struct stored in the token contract. They can be read by anyone and set by an address with `EXTRA_INFORMATION_ROLE`.

```solidity
interface ICMTATBase {
    struct Terms {
        string name;
        IERC1643.Document doc;
    }
    event Term(Terms newTerm);

    function terms() external view returns (Terms memory);
    function setTerms(IERC1643CMTAT.DocumentInfo calldata terms_) external;
}
```

A `Document` contains:
- `uri` — a URI pointing to the document (e.g., IPFS link or HTTPS URL)
- `documentHash` — hash of the document contents for integrity verification
- `lastModified` — block timestamp of the last on-chain update (set automatically)

## Additional Documents via DocumentEngine (ERC-1643)

The `DocumentEngine` is an optional external contract that implements [ERC-1643](https://github.com/ethereum/EIPs/issues/1643). CMTAT exposes two read-only functions delegated to the engine:

```solidity
interface IERC1643 {
    struct Document {
        string uri;
        bytes32 documentHash;
        uint256 lastModified;
    }

    function getDocument(string memory name) external view returns (Document memory doc);
    function getAllDocuments() external view returns (string[] memory);
}
```

**Note**: CMTAT uses `string` for document names instead of the `bytes32` proposed by the EIP, to allow names longer than 32 characters.

The engine is completely free to implement its own storage and management logic. CMTAT only calls `getDocument` and `getAllDocuments` — it never writes to the engine.

### Setting the DocumentEngine

An address with `DOCUMENT_ROLE` can update the engine:

```solidity
function setDocumentEngine(address documentEngine_) external;
```

### Benefits of the External Engine

- Reduces CMTAT contract size (which is near the maximum EVM limit).
- Allows one engine to serve multiple token contracts simultaneously.

## Compatible DocumentEngine Releases

| CMTAT version | DocumentEngine |
|---|---|
| CMTAT v3.0.0 | Under development |
| CMTAT v2.5.0 (unaudited) | [DocumentEngine v0.3.0](https://github.com/CMTA/DocumentEngine/releases/tag/v0.3.0) |
