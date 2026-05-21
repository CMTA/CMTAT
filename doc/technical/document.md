# Document Management

CMTAT supports two layers of on-chain document management:

1. **Terms** — the primary tokenization terms stored directly in the token contract via `ExtraInformationModule`.
2. **Additional documents** — arbitrary ERC-1643 documents, managed through one of two patterns:
   - **Native storage** (`DocumentERC1643Module`) — documents are stored directly in the token contract (available in all shipped deployment variants).
   - **External engine delegation** (`DocumentEngineModule`) — documents are managed by a separate `DocumentEngine` contract (not integrated in any shipped deployment variant; available as an optional module).

## Terms

The tokenization terms are a single `CMTATTerms` struct stored in the token contract. They can be read by anyone and set by an address with `EXTRA_INFORMATION_ROLE`.

```solidity
interface ICMTATBase {
    struct CMTATTerms {
        string name;
        IERC1643.Document doc;
    }
    event Terms(CMTATTerms newTerm);

    function terms() external view returns (CMTATTerms memory);
    function setTerms(IERC1643CMTAT.DocumentInfo calldata terms_) external;
}
```

A `Document` contains:
- `uri` — a URI pointing to the document (e.g., IPFS link or HTTPS URL)
- `documentHash` — hash of the document contents for integrity verification
- `lastModified` — block timestamp of the last on-chain update (set automatically)

## Additional Documents — Native Storage (`DocumentERC1643Module`)

`DocumentERC1643Module` implements the full ERC-1643 interface directly inside the token contract. Documents are stored in ERC-7201 namespaced storage (slot `0x24fbb1cf6345ced60d5278ef6f68f4f7576fd9068704b4c8f1eec8f0bbd8a200`) using:

```solidity
mapping(bytes32 => Document) _documents;
bytes32[]                    _documentNames;
mapping(bytes32 => uint256)  _documentKey;   // 1-based index for O(1) removal
```

All four ERC-1643 operations are available on the token contract directly — no external engine contract is required:

```solidity
function getDocument(bytes32 name) external view returns (Document memory);
function getAllDocuments() external view returns (bytes32[] memory);
function setDocument(bytes32 name, string calldata uri, bytes32 documentHash) external;  // requires DOCUMENT_ROLE
function removeDocument(bytes32 name) external;                                           // requires DOCUMENT_ROLE
```

`removeDocument` uses a swap-and-pop pattern to keep the `_documentNames` array compact without gaps.

### Deployment Availability

`DocumentERC1643Module` is included in **all shipped CMTAT deployment variants except Light** through the inheritance chain `CMTATBaseDocument` (level 1) → `CMTATBaseAccessControl` (level 2). The Light variant (`CMTATStandaloneLight`, `CMTATUpgradeableLight`) is based on `CMTATBaseCore`, which does not extend `CMTATBaseDocument` and therefore has no ERC-1643 document support. The concrete access-control hook `_authorizeDocumentManagement()` enforces `DOCUMENT_ROLE` in `CMTATBaseAccessControl`.

### Trade-offs vs External Engine

| | `DocumentERC1643Module` | `DocumentEngineModule` |
|---|---|---|
| Storage location | On-chain in token contract | External engine contract |
| Deployment complexity | None (built-in) | Requires separate engine deployment |
| Token contract size | Adds storage overhead | Keeps token contract lean |
| Multi-token sharing | One registry per token | One engine can serve many tokens |
| Shipped in CMTAT variants | Yes (all standard variants) | No |

---

## Additional Documents via External Engine (`DocumentEngineModule`)

`DocumentEngineModule` is an alternative to the native storage pattern. Instead of storing documents in the token contract, it delegates all four ERC-1643 operations to a separate `DocumentEngine` contract that implements [ERC-1643](https://github.com/ethereum/EIPs/issues/1643):

```solidity
interface IERC1643 {
    struct Document {
        string uri;
        bytes32 documentHash;
        uint256 lastModified;
    }

    function getDocument(bytes32 name) external view returns (Document memory doc);
    function getAllDocuments() external view returns (bytes32[] memory);
    function setDocument(bytes32 name, string calldata uri, bytes32 documentHash) external;
    function removeDocument(bytes32 name) external;
}
```

**Note**: CMTAT uses `bytes32` for document identifiers, aligned with the original EIP proposal. Only the CMTAT tokenization terms path (`IERC1643CMTAT.DocumentInfo`) still uses `string name`.

The engine is completely free to implement its own storage and management logic. CMTAT forwards both read (`getDocument`, `getAllDocuments`) and write (`setDocument`, `removeDocument`) calls to the engine. Write operations and engine configuration require `DOCUMENT_ENGINE_ROLE`.

### Setting the DocumentEngine

An address with `DOCUMENT_ENGINE_ROLE` can update the engine:

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
