---
name: openzeppelin-v5
description: OpenZeppelin Contracts v5 - A library for secure smart contract development. Use when implementing ERC20, ERC721, ERC1155 tokens, access control, governance, upgradeable contracts, or account abstraction.
---

# OpenZeppelin Contracts v5

A library for secure smart contract development. Build on a solid foundation of community-vetted code.

## Installation

### Hardhat (npm)

```bash
npm install @openzeppelin/contracts
```

### Foundry (git)

```bash
forge install OpenZeppelin/openzeppelin-contracts
```

Add to `remappings.txt`:
```
@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/
```

## Token Standards

### ERC-20 (Fungible Tokens)

Basic ERC-20 token:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
        _mint(msg.sender, initialSupply);
    }
}
```

**Key Points:**
- `decimals` defaults to 18 (like Ether)
- Override `decimals()` to change: `function decimals() public view virtual override returns (uint8) { return 16; }`
- When transferring, use `amount * (10 ** decimals)` for the actual value

**Common Extensions:**
- `ERC20Burnable` - Token burning capability
- `ERC20Capped` - Supply cap enforcement
- `ERC20Pausable` - Pausable transfers
- `ERC20Permit` - Gasless approvals (EIP-2612)
- `ERC20Votes` - Voting and delegation
- `ERC20Wrapper` - Wrap existing tokens

### ERC-721 (Non-Fungible Tokens)

Basic ERC-721 NFT:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721URIStorage, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract GameItem is ERC721URIStorage {
    uint256 private _nextTokenId;

    constructor() ERC721("GameItem", "ITM") {}

    function awardItem(address player, string memory tokenURI) public returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _mint(player, tokenId);
        _setTokenURI(tokenId, tokenURI);
        return tokenId;
    }
}
```

**Common Extensions:**
- `ERC721URIStorage` - Per-token metadata URIs
- `ERC721Enumerable` - Token enumeration
- `ERC721Burnable` - Token burning
- `ERC721Pausable` - Pausable transfers
- `ERC721Votes` - Voting power from NFT ownership

### ERC-1155 (Multi-Token)

For both fungible and non-fungible tokens in one contract:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract GameItems is ERC1155 {
    uint256 public constant GOLD = 0;
    uint256 public constant SILVER = 1;
    uint256 public constant SWORD = 2;

    constructor() ERC1155("https://game.example/api/item/{id}.json") {
        _mint(msg.sender, GOLD, 10**18, "");
        _mint(msg.sender, SILVER, 10**27, "");
        _mint(msg.sender, SWORD, 1, "");
    }
}
```

## Access Control

### Ownable (Simple Ownership)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MyContract is Ownable {
    constructor(address initialOwner) Ownable(initialOwner) {}

    function normalThing() public {
        // Anyone can call
    }

    function specialThing() public onlyOwner {
        // Only owner can call
    }
}
```

**Ownable2Step** - Safer ownership transfer requiring acceptance:
```solidity
import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract MyContract is Ownable2Step {
    constructor(address initialOwner) Ownable(initialOwner) {}
}
// New owner must call acceptOwnership()
```

### AccessControl (Role-Based)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    constructor(address minter, address burner) ERC20("MyToken", "TKN") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, minter);
        _grantRole(BURNER_ROLE, burner);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyRole(BURNER_ROLE) {
        _burn(from, amount);
    }
}
```

**Key Functions:**
- `hasRole(role, account)` - Check if account has role
- `grantRole(role, account)` - Grant role (requires admin)
- `revokeRole(role, account)` - Revoke role (requires admin)
- `renounceRole(role, account)` - Renounce own role
- `getRoleMemberCount(role)` - Count role members
- `getRoleMember(role, index)` - Get role member by index

### AccessManager (Centralized Management)

For managing access across multiple contracts:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessManaged} from "@openzeppelin/contracts/access/manager/AccessManaged.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20, AccessManaged {
    constructor(address manager) ERC20("MyToken", "TKN") AccessManaged(manager) {}

    function mint(address to, uint256 amount) public restricted {
        _mint(to, amount);
    }
}
```

Configure via AccessManager:
```javascript
const MINTER = 42n; // Roles are uint64

await manager.grantRole(MINTER, user, 0);
await manager.setTargetFunctionRole(
    target,
    ['0x40c10f19'], // bytes4(keccak256('mint(address,uint256)'))
    MINTER
);
```

### TimelockController (Delayed Operations)

```solidity
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

// Deploy with min delay, proposers, executors, admin
TimelockController timelock = new TimelockController(
    1 days,           // minDelay
    proposers,        // array of proposer addresses
    executors,        // array of executor addresses
    admin             // admin address
);
```

## Governance

### Setting Up a Governor

**1. Voting Token with ERC20Votes:**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20Votes} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import {Nonces} from "@openzeppelin/contracts/utils/Nonces.sol";

contract MyToken is ERC20, ERC20Permit, ERC20Votes {
    constructor() ERC20("MyToken", "MTK") ERC20Permit("MyToken") {}

    function _update(address from, address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._update(from, to, amount);
    }

    function nonces(address owner) public view virtual override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }
}
```

**2. Governor Contract:**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Governor} from "@openzeppelin/contracts/governance/Governor.sol";
import {GovernorCountingSimple} from "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import {GovernorVotes} from "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import {GovernorVotesQuorumFraction} from "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import {GovernorTimelockControl} from "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";

contract MyGovernor is
    Governor,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorVotesQuorumFraction,
    GovernorTimelockControl
{
    constructor(IVotes _token, TimelockController _timelock)
        Governor("MyGovernor")
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(4) // 4% quorum
        GovernorTimelockControl(_timelock)
    {}

    function votingDelay() public pure override returns (uint256) {
        return 7200; // 1 day in blocks
    }

    function votingPeriod() public pure override returns (uint256) {
        return 50400; // 1 week in blocks
    }

    function proposalThreshold() public pure override returns (uint256) {
        return 0;
    }

    // Required overrides for multiple inheritance
    function state(uint256 proposalId) public view override(Governor, GovernorTimelockControl) returns (ProposalState) {
        return super.state(proposalId);
    }

    function proposalNeedsQueuing(uint256 proposalId) public view virtual override(Governor, GovernorTimelockControl) returns (bool) {
        return super.proposalNeedsQueuing(proposalId);
    }

    function _queueOperations(uint256 proposalId, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash) internal override(Governor, GovernorTimelockControl) returns (uint48) {
        return super._queueOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _executeOperations(uint256 proposalId, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash) internal override(Governor, GovernorTimelockControl) {
        super._executeOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash) internal override(Governor, GovernorTimelockControl) returns (uint256) {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor() internal view override(Governor, GovernorTimelockControl) returns (address) {
        return super._executor();
    }
}
```

## Utilities

### Cryptography

**ECDSA Signature Verification:**
```solidity
using ECDSA for bytes32;
using MessageHashUtils for bytes32;

function _verify(bytes32 data, bytes memory signature, address account) internal pure returns (bool) {
    return data.toEthSignedMessageHash().recover(signature) == account;
}
```

**P256 Signatures (secp256r1):**
```solidity
using P256 for bytes32;

function _verify(bytes32 data, bytes32 r, bytes32 s, bytes32 qx, bytes32 qy) internal pure returns (bool) {
    return data.verify(r, s, qx, qy);
}
```

**Merkle Proof Verification:**
```solidity
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) public pure returns (bool) {
    return MerkleProof.verify(proof, root, leaf);
}
```

### Data Structures

- `EnumerableSet` - Set with enumeration
- `EnumerableMap` - Map with enumeration
- `BitMaps` - Packed boolean storage
- `Checkpoints` - Historical value tracking
- `DoubleEndedQueue` - Queue with O(1) operations
- `Heap` - Binary heap priority queue
- `MerkleTree` - On-chain Merkle tree

### Math

```solidity
using Math for uint256;

(bool success, uint256 result) = x.tryAdd(y);
uint256 avg = Math.average(a, b);
uint256 sqrt = Math.sqrt(x);
```

### Multicall

```solidity
import {Multicall} from "@openzeppelin/contracts/utils/Multicall.sol";

contract Box is Multicall {
    function foo() public { }
    function bar() public { }
}

// Call multiple functions atomically
await box.multicall([
    box.interface.encodeFunctionData("foo"),
    box.interface.encodeFunctionData("bar")
]);
```

### Base64

```solidity
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

function tokenURI(uint256 tokenId) public pure override returns (string memory) {
    string memory json = '{"name": "NFT"}';
    return string.concat("data:application/json;base64,", Base64.encode(bytes(json)));
}
```

## Upgradeable Contracts

Use `@openzeppelin/contracts-upgradeable` for proxy patterns:

```bash
npm install @openzeppelin/contracts-upgradeable @openzeppelin/contracts
```

```solidity
import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";

contract MyNFT is ERC721Upgradeable {
    function initialize() public initializer {
        __ERC721_init("MyNFT", "MNFT");
    }
}
```

**Key Differences:**
- Use `initializer` modifier instead of constructor
- Call `__ContractName_init()` for parent initialization
- Uses ERC-7201 namespaced storage for safety

## Account Abstraction (ERC-4337)

### Account Contract

```solidity
import {Account} from "@openzeppelin/contracts/account/Account.sol";

contract MyAccount is Account {
    function validateUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external returns (uint256 validationData) {
        // Validation logic
    }
}
```

**Components:**
- `UserOperation` - Pseudo-transaction struct
- `EntryPoint` - Singleton contract at `0x4337084D9E255Ff0702461CF8895CE9E3b5Ff108`
- `Bundler` - Off-chain infrastructure for processing operations
- `Paymaster` - Optional gas sponsorship

## Extending Contracts

### Overriding Functions

```solidity
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract MyAccessControl is AccessControl {
    error AccessControlNonRevocable();

    function revokeRole(bytes32, address) public pure override {
        revert AccessControlNonRevocable();
    }
}
```

### Using `super`

```solidity
function revokeRole(bytes32 role, address account) public override {
    require(role != DEFAULT_ADMIN_ROLE, "Cannot revoke admin");
    super.revokeRole(role, account);
}
```

## Security Best Practices

1. **Always use installed code as-is** - Don't copy-paste or modify library code
2. **Use semantic versioning** - Different major versions may have incompatible storage layouts
3. **Upgrades require care** - Major version upgrades are NOT safe for upgradeable contracts
4. **Report security issues** via [Immunefi bug bounty](https://www.immunefi.com/bounty/openzeppelin)

## Common Import Paths

```solidity
// Tokens
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

// Access Control
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

// Governance
import {Governor} from "@openzeppelin/contracts/governance/Governor.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

// Utilities
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Multicall} from "@openzeppelin/contracts/utils/Multicall.sol";

// Proxy
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
```
