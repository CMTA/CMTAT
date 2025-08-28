// Sources flattened with hardhat v2.26.1 https://hardhat.org

// SPDX-License-Identifier: MIT AND MPL-2.0

// File @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.3.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.20;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Storage of the initializable contract.
     *
     * It's implemented on a custom ERC-7201 namespace to reduce the risk of storage collisions
     * when using with upgradeable contracts.
     *
     * @custom:storage-location erc7201:openzeppelin.storage.Initializable
     */
    struct InitializableStorage {
        /**
         * @dev Indicates that the contract has been initialized.
         */
        uint64 _initialized;
        /**
         * @dev Indicates that the contract is in the process of being initialized.
         */
        bool _initializing;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Initializable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant INITIALIZABLE_STORAGE = 0xf0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a00;

    /**
     * @dev The contract is already initialized.
     */
    error InvalidInitialization();

    /**
     * @dev The contract is not initializing.
     */
    error NotInitializing();

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint64 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that in the context of a constructor an `initializer` may be invoked any
     * number of times. This behavior in the constructor can be useful during testing and is not expected to be used in
     * production.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        // Cache values to avoid duplicated sloads
        bool isTopLevelCall = !$._initializing;
        uint64 initialized = $._initialized;

        // Allowed calls:
        // - initialSetup: the contract is not in the initializing state and no previous version was
        //                 initialized
        // - construction: the contract is initialized at version 1 (no reinitialization) and the
        //                 current contract is just being deployed
        bool initialSetup = initialized == 0 && isTopLevelCall;
        bool construction = initialized == 1 && address(this).code.length == 0;

        if (!initialSetup && !construction) {
            revert InvalidInitialization();
        }
        $._initialized = 1;
        if (isTopLevelCall) {
            $._initializing = true;
        }
        _;
        if (isTopLevelCall) {
            $._initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: Setting the version to 2**64 - 1 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint64 version) {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing || $._initialized >= version) {
            revert InvalidInitialization();
        }
        $._initialized = version;
        $._initializing = true;
        _;
        $._initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        _checkInitializing();
        _;
    }

    /**
     * @dev Reverts if the contract is not in an initializing state. See {onlyInitializing}.
     */
    function _checkInitializing() internal view virtual {
        if (!_isInitializing()) {
            revert NotInitializing();
        }
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing) {
            revert InvalidInitialization();
        }
        if ($._initialized != type(uint64).max) {
            $._initialized = type(uint64).max;
            emit Initialized(type(uint64).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint64) {
        return _getInitializableStorage()._initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _getInitializableStorage()._initializing;
    }

    /**
     * @dev Pointer to storage slot. Allows integrators to override it with a custom storage location.
     *
     * NOTE: Consider following the ERC-7201 formula to derive storage locations.
     */
    function _initializableStorageSlot() internal pure virtual returns (bytes32) {
        return INITIALIZABLE_STORAGE;
    }

    /**
     * @dev Returns a pointer to the storage namespace.
     */
    // solhint-disable-next-line var-name-mixedcase
    function _getInitializableStorage() private pure returns (InitializableStorage storage $) {
        bytes32 slot = _initializableStorageSlot();
        assembly {
            $.slot := slot
        }
    }
}


// File @openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


// File @openzeppelin/contracts/utils/introspection/IERC165.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (utils/introspection/IERC165.sol)

pragma solidity >=0.4.16;

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File @openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (utils/introspection/ERC165.sol)

pragma solidity ^0.8.20;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC-165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 */
abstract contract ERC165Upgradeable is Initializable, IERC165 {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


// File @openzeppelin/contracts/access/IAccessControl.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (access/IAccessControl.sol)

pragma solidity >=0.8.4;

/**
 * @dev External interface of AccessControl declared to support ERC-165 detection.
 */
interface IAccessControl {
    /**
     * @dev The `account` is missing a role.
     */
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

    /**
     * @dev The caller of a function is not the expected one.
     *
     * NOTE: Don't confuse with {AccessControlUnauthorizedAccount}.
     */
    error AccessControlBadConfirmation();

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted to signal this.
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call. This account bears the admin role (for the granted role).
     * Expected in cases where the role was granted using the internal {AccessControl-_grantRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     */
    function renounceRole(bytes32 role, address callerConfirmation) external;
}


// File @openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (access/AccessControl.sol)

pragma solidity ^0.8.20;





/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```solidity
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```solidity
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it. We recommend using {AccessControlDefaultAdminRules}
 * to enforce additional security measures for this role.
 */
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControl, ERC165Upgradeable {
    struct RoleData {
        mapping(address account => bool) hasRole;
        bytes32 adminRole;
    }

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;


    /// @custom:storage-location erc7201:openzeppelin.storage.AccessControl
    struct AccessControlStorage {
        mapping(bytes32 role => RoleData) _roles;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.AccessControl")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant AccessControlStorageLocation = 0x02dd7bc7dec4dceedda775e58dd541e08a116c6c53815c0bd028192f7b626800;

    function _getAccessControlStorage() private pure returns (AccessControlStorage storage $) {
        assembly {
            $.slot := AccessControlStorageLocation
        }
    }

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with an {AccessControlUnauthorizedAccount} error including the required role.
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual returns (bool) {
        AccessControlStorage storage $ = _getAccessControlStorage();
        return $._roles[role].hasRole[account];
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `_msgSender()`
     * is missing `role`. Overriding this function changes the behavior of the {onlyRole} modifier.
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `account`
     * is missing `role`.
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert AccessControlUnauthorizedAccount(account, role);
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual returns (bytes32) {
        AccessControlStorage storage $ = _getAccessControlStorage();
        return $._roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address callerConfirmation) public virtual {
        if (callerConfirmation != _msgSender()) {
            revert AccessControlBadConfirmation();
        }

        _revokeRole(role, callerConfirmation);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        AccessControlStorage storage $ = _getAccessControlStorage();
        bytes32 previousAdminRole = getRoleAdmin(role);
        $._roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Attempts to grant `role` to `account` and returns a boolean indicating if `role` was granted.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual returns (bool) {
        AccessControlStorage storage $ = _getAccessControlStorage();
        if (!hasRole(role, account)) {
            $._roles[role].hasRole[account] = true;
            emit RoleGranted(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Attempts to revoke `role` from `account` and returns a boolean indicating if `role` was revoked.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual returns (bool) {
        AccessControlStorage storage $ = _getAccessControlStorage();
        if (hasRole(role, account)) {
            $._roles[role].hasRole[account] = false;
            emit RoleRevoked(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }
}


// File @openzeppelin/contracts/interfaces/draft-IERC6093.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/draft-IERC6093.sol)
pragma solidity >=0.8.4;

/**
 * @dev Standard ERC-20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC-721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in ERC-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC-1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (token/ERC20/IERC20.sol)

pragma solidity >=0.4.16;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity >=0.6.2;

/**
 * @dev Interface for the optional metadata functions from the ERC-20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}


// File @openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;





/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC-20
 * applications.
 */
abstract contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20, IERC20Metadata, IERC20Errors {
    /// @custom:storage-location erc7201:openzeppelin.storage.ERC20
    struct ERC20Storage {
        mapping(address account => uint256) _balances;

        mapping(address account => mapping(address spender => uint256)) _allowances;

        uint256 _totalSupply;

        string _name;
        string _symbol;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ERC20")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC20StorageLocation = 0x52c63247e1f47db19d5ce0460030c497f067ca4cebf71ba98eeadabe20bace00;

    function _getERC20Storage() private pure returns (ERC20Storage storage $) {
        assembly {
            $.slot := ERC20StorageLocation
        }
    }

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * Both values are immutable: they can only be set once during construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        ERC20Storage storage $ = _getERC20Storage();
        $._name = name_;
        $._symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        ERC20Storage storage $ = _getERC20Storage();
        return $._name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        ERC20Storage storage $ = _getERC20Storage();
        return $._symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /// @inheritdoc IERC20
    function totalSupply() public view virtual returns (uint256) {
        ERC20Storage storage $ = _getERC20Storage();
        return $._totalSupply;
    }

    /// @inheritdoc IERC20
    function balanceOf(address account) public view virtual returns (uint256) {
        ERC20Storage storage $ = _getERC20Storage();
        return $._balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /// @inheritdoc IERC20
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        ERC20Storage storage $ = _getERC20Storage();
        return $._allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Skips emitting an {Approval} event indicating an allowance update. This is not
     * required by the ERC. See {xref-ERC20-_approve-address-address-uint256-bool-}[_approve].
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        ERC20Storage storage $ = _getERC20Storage();
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            $._totalSupply += value;
        } else {
            uint256 fromBalance = $._balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                $._balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                $._totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                $._balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner`'s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     *
     * ```solidity
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        ERC20Storage storage $ = _getERC20Storage();
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        $._allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner`'s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance < type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}


// File @openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.3.0) (utils/Pausable.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /// @custom:storage-location erc7201:openzeppelin.storage.Pausable
    struct PausableStorage {
        bool _paused;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Pausable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant PausableStorageLocation = 0xcd5ed15c6e187e77e9aee88184c21f4f2182ab5827cb3b7e07fbedcd63f03300;

    function _getPausableStorage() private pure returns (PausableStorage storage $) {
        assembly {
            $.slot := PausableStorageLocation
        }
    }

    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    /**
     * @dev The operation failed because the contract is paused.
     */
    error EnforcedPause();

    /**
     * @dev The operation failed because the contract is not paused.
     */
    error ExpectedPause();

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function __Pausable_init() internal onlyInitializing {
    }

    function __Pausable_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        PausableStorage storage $ = _getPausableStorage();
        return $._paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        if (paused()) {
            revert EnforcedPause();
        }
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        if (!paused()) {
            revert ExpectedPause();
        }
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        PausableStorage storage $ = _getPausableStorage();
        $._paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        PausableStorage storage $ = _getPausableStorage();
        $._paused = false;
        emit Unpaused(_msgSender());
    }
}


// File contracts/interfaces/tokenization/draft-IERC1643.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
* @title IERC1643 Document Management 
* @dev Part of the ERC1400 Security Token Standards
* Contrary to the original specification, use a struct Document to represent a Document
*/
interface IERC1643 {
     /// @dev Struct used to represent a document and its metadata.
    struct Document {
         // URI of the off-chain document (e.g., IPFS, HTTPS)
        string uri;  
         // Hash of the document content
        bytes32 documentHash; 
         // Timestamp of the last on-chain modification (set by the smart contract)
        uint256 lastModified;
    }

    // Document Management
    /**
     * @notice Retrieves a document by its registered name.
     * @param name The unique name used to identify the document.
     * @return document The associated document's metadata (URI, hash, timestamp).
     */
    function getDocument(string memory name) external view returns (Document memory document);
    /**
     * @notice Returns the list of all document names registered in the contract.
     * @return documentNames_ An array of strings representing all document identifiers.
     */
    function getAllDocuments() external view returns (string[] memory documentNames_);
}


// File contracts/interfaces/engine/IDocumentEngine.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.20;

/*
* @dev minimum interface to define a DocumentEngine
*/
interface IDocumentEngine is IERC1643 {
   // nothing more
}


// File contracts/interfaces/tokenization/draft-IERC1404.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.20;

/*
* @dev Contrary to the ERC-1404,
* this interface does not inherit directly from the ERC20 interface
*/
interface IERC1404 {

    /**
     * @notice Returns a uint8 code to indicate if a transfer is restricted or not
     * @dev 
     * See {ERC-1404}
     * This function is where an issuer enforces the restriction logic of their token transfers. 
     * Some examples of this might include:
     * - checking if the token recipient is whitelisted, 
     * - checking if a sender's tokens are frozen in a lock-up period, etc.
     * @return uint8 restricted code, 0 means the transfer is authorized
     *
     */
    function detectTransferRestriction(
        address from,
        address to,
        uint256 value
    ) external view returns (uint8);


    /**
     * @dev See {ERC-1404}
     * This function is effectively an accessor for the "message", 
     * a human-readable explanation as to why a transaction is restricted. 
     *
     */
    function messageForTransferRestriction(
        uint8 restrictionCode
    ) external view returns (string memory);
}

/**
* @title IERC1404 with custom related extensions
*/
interface IERC1404Extend is IERC1404{
    /* 
    * @dev leave the code 7-12 free/unused for further CMTAT additions in your ruleEngine implementation
    */
    enum REJECTED_CODE_BASE {
        TRANSFER_OK,
        TRANSFER_REJECTED_DEACTIVATED,
        TRANSFER_REJECTED_PAUSED,
        TRANSFER_REJECTED_FROM_FROZEN,
        TRANSFER_REJECTED_TO_FROZEN,
        TRANSFER_REJECTED_SPENDER_FROZEN,
        TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE
    }

    /**
     * @notice Returns a uint8 code to indicate if a transfer is restricted or not
     * @dev 
     * See {ERC-1404}
     * Add an additionnal argument `spender`
     * This function is where an issuer enforces the restriction logic of their token transfers. 
     * Some examples of this might include:
     * - checking if the token recipient is whitelisted, 
     * - checking if a sender's tokens are frozen in a lock-up period, etc.
     * @return uint8 restricted code, 0 means the transfer is authorized
     *
     */
    function detectTransferRestrictionFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) external view returns (uint8);
}


// File contracts/interfaces/tokenization/IERC3643Partial.sol

// Original license: SPDX_License_Identifier: MPL-2.0

/**
* Note:
* Parameter names may differ slightly from the original ERC3643 spec 
* to align with OpenZeppelin v5.3.0 naming conventions 
* (e.g., `amount` → `value`).
*/ 

pragma solidity ^0.8.20;

/**
 * @title IERC3643Pause
 * @dev Interface for pausing and unpausing token transfers.
 * Common interface shared between CMTAT and ERC3643 implementations.
 *
 */
interface IERC3643Pause {
    /**
     * @notice Indicates whether the contract is currently paused.
     * @dev When paused, token transfers are disabled.
     * @return True if the contract is paused, false otherwise.
     */
    function paused() external view returns (bool);
    /**
     * @notice Pauses all token transfers.
     * @dev Once paused, calls to transfer-related functions will revert.
     * Can only be called by an account with the appropriate permission.
     *
     * Emits a {Paused} event.
     */
    function pause() external;

    /**
     * @notice Unpauses token transfers.
     * @dev Restores normal token transfer behavior after a pause.
     * Can only be called by an account with the appropriate permission.
     *
     * Emits an {Unpaused} event.
     */
    function unpause() external;
} 
/**
 * @title ERC-3643 Base Interface for ERC-20 Token Metadata
 * @dev Provides functions to update token name and symbol.
 */
interface IERC3643ERC20Base {
    /**
     * @notice Updates the name of the token.
     * @dev Can be used to rename the token post-deployment.
     * @param name The new name to assign to the token.
     */
    function setName(string calldata name) external;

    /**
     * @notice Updates the symbol of the token.
     * @dev Can be used to change the token's symbol (e.g. for branding or reissuance).
     * @param symbol The new symbol to assign to the token.
     */
    function setSymbol(string calldata symbol) external;
}

/**
 * @title IERC3643BatchTransfer
 * @notice Interface for batch token transfers under the ERC-3643 standard.
 */
interface IERC3643BatchTransfer {
     /**
     * @notice Transfers tokens to multiple recipient addresses in a single transaction.
     * @dev 
     * Batch version of `transfer`
     * - Each recipient receives the number of tokens specified in the `values` array.
     * Requirement:
     * - The `tos` array must not be empty.
     * - `tos.length` must equal `values.length`.
     * - `tos`cannot contain a zero address
     * - the caller must have a balance cooresponding to the total values
     * Events:
     * - Emits one `Transfer` event per recipient (i.e., `tos.length` total).
     * 
     * Enforcement-specific behavior:
     * - If `IERC3643Enforcement` is implemented: 
     *   - The sender (`msg.sender`) and each recipient in `tos` MUST NOT be frozen.
     * - If `IERC3643ERC20Enforcement` is implemented:
     *   - The total amount transferred MUST NOT exceed the sender's available (unfrozen) balance.
     *
     * Note: This implementation differs from the base ERC-3643 specification by returning a `bool`
     *       value for compatibility with the ERC-20 `transfer` function semantics.
     *
     * @param tos The list of recipient addresses.
     * @param values The list of token amounts corresponding to each recipient.
     * @return success_ A boolean indicating whether the batch transfer was successful.
     */
    function batchTransfer(address[] calldata tos,uint256[] calldata values) external returns (bool success_);
}

/**
 * @title IERC3643Base
 * @notice Interface to retrieve version
 */
interface IERC3643Base {
     /**
     * @notice Returns the current version of the token contract.
     * @dev This value is useful to know which smart contract version has been used
     * @return version_ A string representing the version of the token implementation (e.g., "1.0.0").
     */
    function version() external view returns (string memory version_);
}

/**
 * @title IERC3643EnforcementEvent
 * @notice Interface defining the event for account freezing and unfreezing.
 */
interface IERC3643EnforcementEvent {
    /**
     * @notice Emitted when an account's frozen status is changed.
     * @dev 
     * - `account` is the address whose status changed.
     * - `isFrozen` reflects the new status after the function execution:
     *    - `true`: account is frozen.
     *    - `false`: account is unfrozen.
     * - `enforcer` is the address that executed the freezing/unfreezing.
     * - `data` provides optional contextual information for auditing or documentation purposes.
     * The event is emitted by `setAddressFrozen` and `batchSetAddressFrozen` functions
     * Note: This event extends the ERC-3643 specification by including the `data` field.
     * 
     * @param account The address that was frozen or unfrozen.
     * @param isFrozen The resulting freeze status of the account.
     * @param enforcer The address that initiated the change.
     * @param data Additional data related to the freezing action.
     */
    event AddressFrozen(address indexed account, bool indexed isFrozen, address indexed enforcer, bytes data);
}

/**
 * @title IERC3643Enforcement
 * @notice Interface for account-level freezing logic.
 * @dev Provides methods to check and update whether an address is frozen.
 */
interface IERC3643Enforcement {
    /**
     * @notice Checks whether a given account is currently frozen.
     * @param account The address to query.
     * @return isFrozen_ A boolean indicating if the account is frozen (`true`) or not (`false`).
     */
    function isFrozen(address account) external view returns (bool isFrozen_);
    /**
     * @notice Sets the frozen status of a specific address.
     * @dev Emits an `AddressFrozen` event.
     * @param account The address whose frozen status is being updated.
     * @param freeze The new frozen status (`true` to freeze, `false` to unfreeze).
     */
    function setAddressFrozen(address account, bool freeze) external;
    /**
     * @notice Batch version of {setAddressFrozen}, allowing multiple addresses to be updated in one call.
     * @param accounts An array of addresses to update.
     * @param freeze An array of corresponding frozen statuses for each address.
     * Requirements:
     * - `accounts.length` must be equal to `freeze.length`.
     */
    function batchSetAddressFrozen(address[] calldata accounts, bool[] calldata freeze) external;
}

/**
 * @title IERC3643ERC20Enforcement
 * @notice Interface for enforcing partial token freezes and forced transfers, typically used in compliance-sensitive ERC-1400 scenarios.
 * @dev For event definitions, see {IERC7551ERC20Enforcement}.
 */
interface IERC3643ERC20Enforcement {
    /* ============ View Functions ============ */
    /**
     * @notice Returns the number of tokens that are currently frozen (i.e., non-transferable) for a given account.
     * @dev The frozen amount is always less than or equal to the total balance of the account.
     * @param account The address of the wallet being queried.
     * @return frozenBalance_ The amount of frozen tokens held by the account.
     */
    function getFrozenTokens(address account) external view returns (uint256 frozenBalance_);


    /* ============ State Functions ============ */

    /**
     * @notice Freezes a specific amount of tokens for a given account.
     * @dev Emits a `TokensFrozen` event. Prevents the frozen amount from being transferred.
     * @param account The wallet address whose tokens are to be frozen.
     * @param value The amount of tokens to freeze.
     */
    function freezePartialTokens(address account, uint256 value) external;
 
     /**
     *  @notice unfreezes token amount specified for given address
     *  @dev Emits a TokensUnfrozen event
     *  @param account The address for which to update frozen tokens
     *  @param value Amount of Tokens to be unfrozen
     */
    function unfreezePartialTokens(address account, uint256 value) external;
    /**
     *  
     *  @notice Triggers a forced transfer.
     *  @dev 
*    *  Force a transfer of tokens between 2 token holders
     *  If IERC364320Enforcement is implemented:
     *      Require that the total value should not exceed available balance.
     *      In case the `from` address has not enough free tokens (unfrozen tokens)
     *      but has a total balance higher or equal to the `amount`
     *      the amount of frozen tokens is reduced in order to have enough free tokens
     *      to proceed the transfer, in such a case, the remaining balance on the `from`
     *      account is 100% composed of frozen tokens post-transfer.
     *      emits a `TokensUnfrozen` event if `value` is higher than the free balance of `from`
     *  Emits a `Transfer` event
     *  @param from The address of the token holder
     *  @param to The address of the receiver
     *  @param value amount of tokens to transfer
     *  @return success_ `true` if successful and revert if unsuccessful

     */
    function forcedTransfer(address from, address to, uint256 value) external returns (bool success_);

}
/**
* @title IERC3643Mint — Token Minting Interface
* @dev Interface for mintint ERC-20 compatible tokens under the ERC-3643 standard.
* Implements both single and batch mint functionalities, with support for frozen address logic if enforced.
*/
interface IERC3643Mint{
    /**
     * @notice Creates (`mints`) a specified `value` of tokens and assigns them to the `account`.
     * @dev Tokens are minted by transferring them from the zero address (`address(0)`).
     * Emits a {Mint} event and a {Transfer} event with `from` set to `address(0)`.
     * Requirement:
     * Account must not be the zero address.
     * @param account The address that will receive the newly minted tokens. 
     * @param value The amount of tokens to mint to `account`.
     */
    function mint(address account, uint256 value) external;
    /**
     * @notice Batch version of {mint}, allowing multiple mint operations in a single transaction.
     * @dev
     * For each mint action:
     *   - Emits a {Mint} event.
     *   - Emits a {Transfer} event with `from` set to the zero address.
     * - Requires that `accounts` and `values` arrays have the same length.
     * - None of the addresses in `accounts` can be the zero address.
     * - Be cautious with large arrays as the transaction may run out of gas.
     * @param accounts The list of recipient addresses for the minted tokens.
     * @param values The respective amounts of tokens to mint for each recipient.
     */
    function batchMint( address[] calldata accounts,uint256[] calldata values) external;
}

/**
* @title IERC3643Burn — Token Burning Interface
* @dev Interface for burning ERC-20 compatible tokens under the ERC-3643 standard.
* Implements both single and batch burn functionalities, with support for frozen token logic if enforced.
*/
interface IERC3643Burn{
     /**
     * @notice Burns a specified amount of tokens from a given account by transferring them to `address(0)`.
     * @dev 
     * - Decreases the total token supply by the specified `value`.
     * - Emits a `Transfer` event to indicate the burn (with `to` set to `address(0)`).
     * - If `IERC364320Enforcement` is implemented:
     *   - If the account has insufficient free (unfrozen) tokens but a sufficient total balance, 
     *     frozen tokens are reduced to complete the burn.
     *   - The remaining balance on the account will consist entirely of frozen tokens after the burn.
     *   - Emits a `TokensUnfrozen` event if frozen tokens are unfrozen to allow the burn.
     * 
     * @param account The address from which tokens will be burned.
     * @param value The amount of tokens to burn.
     */
    function burn(address account,uint256 value) external;
    /**
     * @notice Performs a batch burn operation, removing tokens from multiple accounts in a single transaction.
     * @dev 
     * - Batch version of {burn}
     * - Executes the burn operation for each account in the `accounts` array, using corresponding amounts in the `values` array.
     * - Emits a `Transfer` event for each burn (with `to` set to `address(0)`).
     * - This operation is gas-intensive and may fail if the number of accounts (`accounts.length`) is too large, causing an "out of gas" error.
     * - Use with caution to avoid unnecessary transaction fees.
     * Requirement:
     *  - `accounts` and `values` must have the same length
     * @param accounts An array of addresses from which tokens will be burned.
     * @param values An array of token amounts to burn, corresponding to each address in `accounts`.
     */
    function batchBurn(address[] calldata accounts,uint256[] calldata values) external;
}

interface IERC3643ComplianceRead {
    /**
     * @notice Returns true if the transfer is valid, and false otherwise.
     * @dev Don't check the balance and the user's right (access control)
     */
    function canTransfer(
        address from,
        address to,
        uint256 value
    ) external view returns (bool isValid);
}

interface IERC3643IComplianceContract {
    /**
     *  @notice
     *  Function called whenever tokens are transferred
     *  from one wallet to another
     *  @dev 
     *  This function can be used to update state variables of the compliance contract
     *  This function can be called ONLY by the token contract bound to the compliance
     *  @param from The address of the sender
     *  @param to The address of the receiver
     *  @param value value of tokens involved in the transfer
     */
    function transferred(address from, address to, uint256 value) external;
}


// File contracts/interfaces/tokenization/draft-IERC7551.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.20;


/**
 * @title IERC7551Mint
 * @dev Interface for token minting operations. 
 */
interface IERC7551Mint {
     /**
     * @notice Emitted when new tokens are minted and assigned to an account.
     * @param minter The address that initiated the mint operation.
     * @param account The address receiving the newly minted tokens.
     * @param value The amount of tokens created.
     * @param data Optional metadata associated with the mint (e.g., reason, reference ID).
     */
    event Mint(address indexed minter, address indexed account, uint256 value, bytes data);
    /**
     * @notice Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0)
     * @dev
     * - Increases the total supply of tokens.
     * - Emits both a `Mint` event and a standard ERC-20 `Transfer` event (with `from` set to the zero address).
     * - The `data` parameter can be used to attach off-chain metadata or audit information.
     * - If {IERC7551Pause} is implemented:
     *   - Token issuance MUST NOT be blocked by paused transfer state.
     * Requirements:
     * - `account` cannot be the zero address
     * @param account The address that will receive the newly minted tokens.
     * @param value The amount of tokens to mint.
     * @param data Additional contextual data to include with the mint (optional).
     */
    function mint(address account, uint256 value, bytes calldata data) external;
}

/**
* @title interface for burn operation
*/
interface IERC7551Burn {
     /**
     * @notice Emitted when tokens are burned from an account.
     * @param burner The address that initiated the burn.
     * @param account The address from which tokens were burned.
     * @param value The amount of tokens burned.
     * @param data Additional data related to the burn.
     */
    event Burn(address indexed burner, address indexed account, uint256 value, bytes data);
   
    /**
     * @notice Burns a specific number of tokens from the given account by transferring it to address(0)
     * @dev 
     * - The account's balance is decreased by the specified amount.
     * - Emits a `Burn` event and a standard `Transfer` event with `to` set to `address(0)`.
     * - If the account balance (including frozen tokens) is less than the burn amount, the transaction MUST revert.
     * - If the token contract supports {IERC7551Pause}, paused transfers MUST NOT prevent this burn operation.
     * - The `data` parameter MAY be used to provide additional context (e.g., audit trail or documentation).
     * @param account The address whose tokens will be burned.
     * @param amount The number of tokens to remove from circulation.
     * @param data Arbitrary additional data to document the burn.
     */
    function burn(address account, uint256 amount, bytes calldata data) external;
}

interface IERC7551Pause {
    /**
     * @notice Returns true if token transfers are currently paused.
     * @return True if paused, false otherwise.
     * @dev  
     * If this function returns true, it MUST NOT be possible to transfer tokens to other accounts 
     * and the function canTransfer() MUST return false.
     */
    function paused() external view returns (bool);
    /**
     * @notice Pauses token transfers.
     * @dev Reverts if already paused.
          * Emits a `Paused` event
     */
    function pause() external;
    /**
     * @notice Unpauses token transfers.
     * @dev Reverts if token is not in pause state.
     * emits an `Unpaused` event
     */
    function unpause() external;
}
interface IERC7551ERC20EnforcementEvent {
    /**
     * @notice Emitted when a forced transfer or burn occurs.
     * @param enforcer The address that initiated the enforcement.
     * @param account The address affected by the enforcement.
     * @param amount The number of tokens involved.
     * @param data Additional data related to the enforcement.
     */
    event Enforcement (address indexed enforcer, address indexed account, uint256 amount, bytes data);
}

interface IERC7551ERC20EnforcementTokenFrozenEvent {
    /**
     * @notice Emitted when a specific amount of tokens are frozen on an address.
     * @param account The address whose tokens are frozen.
     * @param value The number of tokens frozen.
     * @param data Additional data related to the freezing action.
     *  @dev
     *  Same name as ERC-3643 but with a supplementary data parameter
     *  The event is emitted by freezePartialTokens and batchFreezePartialTokens functions
     */
    event TokensFrozen(address indexed account, uint256 value, bytes data);

    /**
     * @notice Emitted when a specific amount of tokens are unfrozen on an address.
     * @param account The address whose tokens are unfrozen.
     * @param value The number of tokens unfrozen.
     * @param data Additional data related to the unfreezing action.
     * @dev 
     * Same name as ERC-3643 but with a supplementary data parameter
     * The event is emitted by `unfreezePartialTokens`, `batchUnfreezePartialTokens`and potentially `forcedTransfer` functions
     */
    event TokensUnfrozen(address indexed account, uint256 value, bytes data);
}

interface IERC7551ERC20Enforcement {
     /* ============ View Functions ============ */
    /**
     * @notice Returns the active (unfrozen) token balance of a given account.
     * @param account The address to query.
     * @return activeBalance_ The amount of tokens that can be transferred using standard ERC-20 functions.
     */
    function getActiveBalanceOf(address account) external view returns (uint256 activeBalance_);


    /**
     * @notice Returns the frozen token balance of a given account.
     * @dev Frozen tokens cannot be transferred using standard ERC-20 functions.
     * Implementations MAY support transferring frozen tokens using other mechanisms like `forcedTransfer`.
     * If the active balance is insufficient to cover a transfer, `canTransfer` and `canTransferFrom` MUST return false.
     * @param account The address to query.
     * @return frozenBalance_ The amount of tokens that are frozen and non-transferable via ERC-20 `transfer` and `transferFrom`.
     */
    function getFrozenTokens(address account) external view returns (uint256 frozenBalance_);
    
     /* ============ State Functions ============ */
    /**
     * @notice Freezes a specified amount of tokens for a given account.
     * @dev Emits a `TokensFrozen` event.
     * @param account The address whose tokens will be frozen.
     * @param amount The number of tokens to freeze.
     * @param data Arbitrary additional data for logging or business logic.
     */
    function freezePartialTokens(address account, uint256 amount, bytes memory data) external;
    

    /**
     * @notice Unfreezes a specified amount of tokens for a given account.
     * @dev Emits a `TokensUnfrozen` event.
     * @param account The address whose tokens will be unfrozen.
     * @param amount The number of tokens to unfreeze.
     * @param data Arbitrary additional data for logging or business logic.
     */
    function unfreezePartialTokens(address account, uint256 amount, bytes memory data) external;
    /**
     * @notice Executes a forced transfer of tokens from one account to another.
     * @dev Transfers `value` tokens from `account` to `to` without requiring the account’s consent.
     * If the `account` does not have enough active (unfrozen) tokens, frozen tokens may be automatically unfrozen to fulfill the transfer.
     * Emits a `Transfer` event. Emits a `TokensUnfrozen` event if frozen tokens are used.
     * @param account The address to debit tokens from.
     * @param to The address to credit tokens to.
     * @param value The amount of tokens to transfer.
     * @param data Optional additional metadata to accompany the transfer.
     * @return success_ Returns true if the transfer was successful.
     */
    function forcedTransfer(address account, address to, uint256 value, bytes calldata data) external returns (bool success_);
}

interface IERC7551Compliance is IERC3643ComplianceRead {
     /**
     * @notice Checks if `spender` can transfer `value` tokens from `from` to `to` under compliance rules.
     * @dev Does not check balances or access rights (Access Control).
     * @param spender The address performing the transfer.
     * @param from The source address.
     * @param to The destination address.
     * @param value The number of tokens to transfer.
     * @return isCompliant True if the transfer complies with policy.
     */
    function canTransferFrom(
        address spender,
        address from,
        address to,
        uint256 value
    )  external view returns (bool);
}

interface IERC7551Document {
    /**
     * @notice Returns the hash of the "Terms" document.
     * @return hash_ The `bytes32` hash of the terms document.
     */
    function termsHash() external view returns (bytes32 hash_);

    /**
     * @notice Sets the terms hash and URI.
     * @param _hash The new hash of the document.
     * @param _uri The corresponding URI.
     */
    function setTerms(bytes32 _hash, string calldata _uri) external;

    /**
    * @notice Returns the metadata string (e.g. URL).
    * @return metadata_ The metadata string.
    */
    function metaData() external view returns (string memory metadata_);

    /**
    * @notice Sets a new metadata string (e.g. URL).
    * @param metaData_ The new metadata value.
    */
    function setMetaData(string calldata metaData_) external;
}


// File contracts/interfaces/engine/IRuleEngine.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.20;



/*
* @title Minimum interface to define a RuleEngine
*/
interface IRuleEngine is IERC1404Extend, IERC7551Compliance,  IERC3643IComplianceContract {
    /**
     *  @notice
     *  Function called whenever tokens are transferred from one wallet to another
     *  @dev 
     *  Must revert if the transfer is invalid
     *  Same name as ERC-3643 but with one supplementary argument `spender`
     *  This function can be used to update state variables of the RuleEngine contract
     *  This function can be called ONLY by the token contract bound to the RuleEngine
     *  @param spender spender address (sender)
     *  @param from token holder address
     *  @param to receiver address
     *  @param value value of tokens involved in the transfer
     */
    function transferred(address spender, address from, address to, uint256 value) external;
}


// File contracts/interfaces/engine/ISnapshotEngine.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.20;

/*
* @dev minimum interface to define a SnapshotEngine
*/
interface ISnapshotEngine {
   /**
    * @notice Records balance and total supply snapshots before any token transfer occurs.
    * @dev This function should be called inside the {_update} hook so that
    * snapshots are updated prior to any state changes from {_mint}, {_burn}, or {_transfer}.
    * It ensures historical balances and total supply remain accurate for snapshot queries.
    *
    * @param from The address tokens are being transferred from (zero address if minting).
    * @param to The address tokens are being transferred to (zero address if burning).
    * @param balanceFrom The current balance of `from` before the transfer (used to update snapshot).
    * @param balanceTo The current balance of `to` before the transfer (used to update snapshot).
    * @param totalSupply The current total supply before the transfer (used to update snapshot).
    */
    function operateOnTransfer(address from, address to, uint256 balanceFrom, uint256 balanceTo, uint256 totalSupply) external;
}

/**
 * @title IERC20BatchBalance
 * @notice Interface to query multiple account balances and the total supply in a single call.
 */
interface IERC20BatchBalance {
     /**
     * @notice Returns the balances of multiple addresses and the total token supply.
     * @param addresses The list of addresses to retrieve balances for.
     * @return balances An array of token balances corresponding to each address in the input list.
     * @return totalSupply_ The total supply of the token.
     * @dev 
     * - Useful for scenarios like dividend distribution or performing on-chain balance snapshots.
     * - Optimizes gas costs by aggregating balance reads into one function call.
     */
    function batchBalanceOf(address[] calldata addresses) external view 
    returns(uint256[] memory balances , uint256 totalSupply_);
}


// File contracts/interfaces/tokenization/draft-IERC1643CMTAT.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.20;

interface IERC1643CMTAT {
    struct DocumentInfo {
        string name;
        string uri;
        bytes32 documentHash;
 }
}


// File contracts/interfaces/technical/ICMTATConstructor.sol

// Original license: SPDX_License_Identifier: MPL-2.0
pragma solidity ^0.8.20;




/**
* @notice interface to represent arguments used for CMTAT constructor / initialize
*/
interface ICMTATConstructor {
    struct Engine {
        IRuleEngine ruleEngine;
        ISnapshotEngine snapshotEngine;
        IERC1643 documentEngine;
    }
    struct ERC20Attributes {
        // token name,
        string name;
        // token symbol
        string symbol;
        // number of decimals of the token, must be 0 to be compliant with Swiss law as per CMTAT specifications (non-zero decimal number may be needed for other use cases)
        uint8 decimalsIrrevocable;
    }
    struct ExtraInformationAttributes {
        // ISIN or other identifier
        string tokenId;
        // terms associated with the token
        IERC1643CMTAT.DocumentInfo terms;
        // additional information to describe the token
        string information;
    }
}


// File contracts/interfaces/technical/IMintBurnToken.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.20;


/**
 * @title IMintERC20Event
 * @notice Standard interface for minting ERC-20 tokens.
 */
interface IMintBatchERC20Event {
    /**
     * @notice Emitted when tokens are minted in batch by a single minter.
     * @dev The `values` array specifies the amount of tokens minted to each corresponding address in `accounts`.
     * @param minter The address that initiated the batch mint operation.
     * @param accounts The list of addresses receiving minted tokens.
     * @param values The amounts of tokens minted to each corresponding account.
     */
    event BatchMint(
        address indexed minter,
        address[] accounts,
        uint256[] values
    );
}

/**
* @title IBurnMintERC20
* @notice standard interface for burn and mint atomically
 */
interface IBurnMintERC20 {
/**
* @notice burn and mint atomically
* @param from current token holder to burn tokens
* @param to receiver to send the new minted tokens
* @param amountToBurn number of tokens to burn
* @param amountToMint number of tokens to mint
*/
 function burnAndMint(address from, address to, uint256 amountToBurn, uint256 amountToMint, bytes calldata data) external;
}


interface IForcedBurnERC20 {
    /**
    * @notice Allows the issuer to forcibly burn tokens from a frozen address.
    * @param account The address from which tokens will be burned.
    * @param value The amount of tokens to burn.
    * @param data Additional data providing context for the burn (e.g., reason or reference).
    * @dev This function is typically restricted to authorized roles such as the issuer.
    */
  function forcedBurn(
        address account,
        uint256 value,
        bytes memory data
    ) external;
}

/** 
 * @notice Standard interface for token burning operations.
 */
interface IBurnBatchERC20 {
   /* ============ Events ============ */
    /**
     * @notice Emitted when tokens are burned in a batch operation.
     * @param burner The address that initiated the batch burn.
     * @param accounts The list of addresses from which tokens were burned.
     * @param values The respective amounts of tokens burned from each address.
     * @param data Additional data associated with the batch burn operation.
     */
    event BatchBurn(
        address indexed burner,
        address[] accounts,
        uint256[] values,
        bytes data
    );

    /**
     * @notice Burns tokens from multiple accounts in a single transaction.
     * @dev 
     *  Batch version of {burn}.
     * - For each burn, emits a `Transfer` event to the zero address.
     * - Emits a `burnBatch` event
     * - The `data` parameter applies uniformly to all burn operations in this batch.
     * - Requirements:
     *   - `accounts.length` must equal `values.length`.
     * @param accounts The list of addresses whose tokens will be burned.
     * @param values The respective number of tokens to burn from each account.
     * @param data Optional metadata or reason for the batch burn.
     */
    function batchBurn(
        address[] calldata accounts,
        uint256[] calldata values,
        bytes memory data
    ) external;
}

/**
 * @notice Standard interface for token burning operations with allowance.
 */
interface IBurnFromERC20 {
   /* ============ Events ============ */
    /**
     * @notice Emitted when a spender burns tokens on behalf of an account, reducing the spender's allowance.
     * @param burner The address that initiated the burn.
     * @param account The owner address from which tokens were burned.
     * @param spender The address authorized to burn tokens on behalf of the owner.
     * @param value The amount of tokens burned.
     */
    event BurnFrom(address indexed burner, address indexed account, address indexed spender, uint256 value);

    /* ============ Functions ============ */
   /**
     * @notice Burns a specified amount of tokens from a given account, deducting from the caller's allowance.
     * @param account The address whose tokens will be burned.
     * @param value The number of tokens to burn.
     * @dev The caller must have allowance for `account`'s tokens of at least `value`.
     * - Emits a `Spend` event
     * - Emits a `BurnFrom` event
     * This function decreases the total supply.
     * Can be used to authorize a bridge (e.g. CCIP) to burn token owned by the bridge
     * No data parameter reason to be compatible with Bridge, e.g. CCIP
     */
  function burnFrom(address account, uint256 value) external;

    /**
    * @notice Burns a specified amount of tokens from the caller's own balance.
    * @param value The number of tokens to burn.
    * @dev This function is typically restricted to token holders or authorized roles.
    */
    function burn(uint256 value) external;
}


// File contracts/libraries/Errors.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.20;

/*
* @dev CMTAT custom errors
*/
library Errors {
    // CMTAT Base
    error CMTAT_InvalidTransfer(address from, address to, uint256 amount);
}


// File contracts/modules/wrapper/core/BaseModule.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Tokenization === */

abstract contract BaseModule is IERC3643Base {
    /* ============ State Variables ============ */
    /** 
    * @dev 
    * Get the current version of the smart contract
    */
    string private constant VERSION = "3.0.0";
    /* ============ Events ============ */
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
    * @inheritdoc IERC3643Base
    */
    function version() public view virtual override(IERC3643Base) returns (string memory version_) {
       return VERSION;
    }
}


// File contracts/modules/internal/common/EnforcementModuleLibrary.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
 * @dev Enforcement module library
 *
 * Common functions and errors between AllowlistModuleInternal & EnforcementModuleInternal
 */
library EnforcementModuleLibrary
{
    error CMTAT_Enforcement_EmptyAccounts();
    error CMTAT_Enforcement_AccountsValueslengthMismatch();

    function _checkInput(address[] calldata accounts, bool[] calldata status) internal pure{
        require(accounts.length > 0, CMTAT_Enforcement_EmptyAccounts());
        // We do not check that values is not empty since
        // this require will throw an error in this case.
        require(bool(accounts.length == status.length), CMTAT_Enforcement_AccountsValueslengthMismatch());
    }
}


// File contracts/modules/internal/EnforcementModuleInternal.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */


/* ==== Module === */

/**
 * @dev Enforcement module internal.
 *
 * Allows the issuer to set an allowlist
 */
abstract contract EnforcementModuleInternal is
    Initializable,
    ContextUpgradeable
{
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.EnforcementModuleInternal")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant EnforcementModuleInternalStorageLocation = 0x0c7bc8a17be064111d299d7669f49519cb26c58611b72d9f6ccc40a1e1184e00;

    /* ==== ERC-7201 State Variables === */
    struct EnforcementModuleInternalStorage {
        mapping(address account => bool status)_list;
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ View functions ============ */
    function _addAddressToTheList(address account, bool status, bytes memory data) internal virtual{
        EnforcementModuleInternalStorage storage $ = _getEnforcementModuleInternalStorage();
        _addAddressToTheList($, account, status, data);
    }

    function _addAddressToTheList(EnforcementModuleInternalStorage storage $,address account, bool status, bytes memory /*data */) internal virtual{
        $._list[account] = status;
    }

  function _addAddressesToTheList(address[] calldata accounts, bool[] calldata status, bytes memory data) internal virtual{
        EnforcementModuleLibrary._checkInput(accounts, status);
        EnforcementModuleInternalStorage storage $ = _getEnforcementModuleInternalStorage();
        for (uint256 i = 0; i < accounts.length; ++i) {
            _addAddressToTheList($, accounts[i], status[i], data);
        }
    }

    /* ============ View functions ============ */
    /**
     * @dev Returns true if the account is frozen, and false otherwise.
     */
    function _addressIsListed(address account) internal view virtual returns (bool _isListed) {
        EnforcementModuleInternalStorage storage $ = _getEnforcementModuleInternalStorage();
        return $._list[account];
    }

    /* ============ ERC-7201 ============ */
    function _getEnforcementModuleInternalStorage() internal pure returns (EnforcementModuleInternalStorage storage $) {
        assembly {
            $.slot := EnforcementModuleInternalStorageLocation
        }
    }
}


// File contracts/modules/wrapper/core/EnforcementModule.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */

/* ==== Module === */


/*
/**
 * @title Enforcement module.
 * @dev 
 *
 * Allows the issuer to freeze transfers from a given address
 */
abstract contract EnforcementModule is
    EnforcementModuleInternal,
    AccessControlUpgradeable,
    IERC3643Enforcement,
    IERC3643EnforcementEvent
{
    /* ============ State Variables ============ */
    bytes32 public constant ENFORCER_ROLE = keccak256("ENFORCER_ROLE");

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ State restricted functions ============ */
    /**
    * @inheritdoc IERC3643Enforcement
    * @custom:access-control
    * - the caller must have the `ENFORCER_ROLE`.
    */
    function setAddressFrozen(address account, bool freeze) public virtual override(IERC3643Enforcement) onlyRole(ENFORCER_ROLE){
         _addAddressToTheList(account, freeze, "");
    }
    
    /**
    * @notice Sets the frozen status of a specific account.
    * @dev 
    * Extend ERC-3643 functions `setAddressFrozen` with a supplementary `data` parameter
    * - Freezing an account prevents it from transferring or receiving tokens depending on enforcement logic.
    * - Emits an `AddressFrozen` event.
    * @param account The address whose frozen status is being updated.
    * @param freeze Set to `true` to freeze the account, or `false` to unfreeze it.
    * @param data Optional metadata providing context or justification for the action (e.g. compliance reason).
    * @custom:access-control
    * - the caller must have the `ENFORCER_ROLE`.
    */
    function setAddressFrozen(
        address account, bool freeze, bytes calldata data
    ) public virtual onlyRole(ENFORCER_ROLE)  {
         _addAddressToTheList(account, freeze, data);
    }

    /**
    * @inheritdoc IERC3643Enforcement
    * @custom:access-control
    * - the caller must have the `ENFORCER_ROLE`.
    */
    function batchSetAddressFrozen(
        address[] calldata accounts, bool[] calldata freezes
    ) public virtual override(IERC3643Enforcement) onlyRole(ENFORCER_ROLE) {
         _addAddressesToTheList(accounts, freezes, "");
    }

    /* ============ View functions ============ */
    /**
    * @inheritdoc IERC3643Enforcement
    */
    function isFrozen(address account) public override(IERC3643Enforcement) view virtual returns (bool isFrozen_) {
       return _addressIsListed(account);
       
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _addAddressToTheList(EnforcementModuleInternalStorage storage $,address account, bool freeze, bytes memory data) internal override(EnforcementModuleInternal){
        EnforcementModuleInternal._addAddressToTheList($, account, freeze, data);
        emit AddressFrozen(account, freeze, _msgSender(), data);
    }
}


// File contracts/interfaces/technical/IERC20Allowance.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
 * @title IERC20Allowance
 * @notice Interface for emitting spend-related events in ERC-20 based tokens.
 */
interface IERC20Allowance {
   /* ============ Events ============ */
    /**
     * @notice Emitted when a `spender` spends a `value` amount of tokens on behalf of an `account`.
     * @dev 
     * - This event is similar in semantics to the ERC-20 `Approval` event.
     * Approval(address indexed _owner, address indexed _spender, uint256 _value)
     * - It represents a reduction in the spender’s allowance granted by the account.
     * - Can also be used for function which uses the allowance, e.g.`burnFrom
     * @param account The owner of the tokens whose allowance is being spent.
     * @param spender The address authorized to spend the tokens.
     * @param value The amount of tokens that were spent.
     */
    event Spend(address indexed account, address indexed spender, uint256 value);
}


// File contracts/modules/wrapper/core/ERC20BaseModule.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */


/* ==== Technical === */


/* ==== Tokenization === */

/**
 * @title ERC20Base module
 * @dev 
 *
 * Contains ERC-20 base functions and extension
 * Inherits from ERC-20
 * 
 */
abstract contract ERC20BaseModule is ERC20Upgradeable, AccessControlUpgradeable, IERC20Allowance, IERC3643ERC20Base, IERC20BatchBalance{
    event Name(string indexed newNameIndexed, string newName);
    event Symbol(string indexed newSymbolIndexed, string newSymbol);

    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.ERC20BaseModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC20BaseModuleStorageLocation = 0x9bd8d607565c0370ae5f91651ca67fd26d4438022bf72037316600e29e6a3a00;
    /* ==== ERC-7201 State Variables === */
    struct ERC20BaseModuleStorage {
        uint8 _decimals;
        // We don't use ERC20Upgradeable name and private because we can not modify them
        string _name;
        string _symbol;
    }

    /* ============  Initializer Function ============ */
    /**
     * @dev Initializers: Sets the values for decimals.
     *
     * this value is immutable: it can only be set once during
     * construction/initialization.
     */
    function __ERC20BaseModule_init_unchained(
        uint8 decimals_,
        string memory name_,
        string memory symbol_
    ) internal virtual onlyInitializing {
        ERC20BaseModuleStorage storage $ = _getERC20BaseModuleStorage();
        $._decimals = decimals_;
        $._symbol = symbol_;
        $._name = name_;
    }
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /* ============  ERC-20 standard ============ */
    
    /* ======== State functions ======= */
     /**
     * @notice Transfers `value` amount of tokens from address `from` to address `to`
     * @custom:devimpl
     * Emits a {Spend} event indicating the allowance spent.
     * @inheritdoc ERC20Upgradeable
     *
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual override(ERC20Upgradeable) returns (bool) {
        bool result = ERC20Upgradeable.transferFrom(from, to, value);
        // The result will be normally always true because OpenZeppelin will revert in case of an error
        if (result) {
            emit Spend(from, _msgSender(), value);
        }

        return result;
    }

    /* ======== View functions ======= */
    /**
     *
     * @notice Returns the number of decimals used to get its user representation.
     * @inheritdoc ERC20Upgradeable
     */
    function decimals() public view virtual override(ERC20Upgradeable) returns (uint8) {
        ERC20BaseModuleStorage storage $ = _getERC20BaseModuleStorage();
        return $._decimals;
    }

    /**
     * @notice Returns the name of the token.
     */
    function name() public virtual override(ERC20Upgradeable) view returns (string memory) {
        ERC20BaseModuleStorage storage $ = _getERC20BaseModuleStorage();
        return $._name;
    }

    /**
     * @notice  Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public virtual override(ERC20Upgradeable) view returns (string memory) {
        ERC20BaseModuleStorage storage $ = _getERC20BaseModuleStorage();
        return $._symbol;
    }


    /* ============  Custom functions ============ */
    /* ========  State Functions ======= */
    /**
     *  @inheritdoc IERC3643ERC20Base
     *  @dev 
     */
    function setName(string calldata name_) public virtual override(IERC3643ERC20Base) onlyRole(DEFAULT_ADMIN_ROLE) {
        ERC20BaseModuleStorage storage $ = _getERC20BaseModuleStorage();
        $._name = name_;
        emit Name(name_, name_);
    }

    /**
     * @inheritdoc IERC3643ERC20Base
     */
    function setSymbol(string calldata symbol_) public virtual override(IERC3643ERC20Base) onlyRole(DEFAULT_ADMIN_ROLE) {
        ERC20BaseModuleStorage storage $ = _getERC20BaseModuleStorage();
        $._symbol = symbol_;
        emit Symbol(symbol_, symbol_);
    }
    /* ======== View functions ======= */
    /**
    * @inheritdoc IERC20BatchBalance
    */
    function batchBalanceOf(address[] calldata addresses) public view virtual override(IERC20BatchBalance) returns(uint256[] memory balances , uint256 totalSupply_) {
        balances = new uint256[](addresses.length);
        for(uint256 i = 0; i < addresses.length; ++i){
            balances[i] = ERC20Upgradeable.balanceOf(addresses[i]);
        }
        totalSupply_ = ERC20Upgradeable.totalSupply();
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/


    /* ============ ERC-7201 ============ */
    function _getERC20BaseModuleStorage() private pure returns (ERC20BaseModuleStorage storage $) {
        assembly {
            $.slot := ERC20BaseModuleStorageLocation
        }
    }
}


// File contracts/modules/internal/ERC20BurnModuleInternal.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */

/**
 * @title ERC20Burn module Internal.
 * @dev 
 *
 * Contains all burn functions, inherits from ERC-20
 */
abstract contract ERC20BurnModuleInternal is ERC20Upgradeable {
    /// @notice Reverts when the `accounts` array provided for a batch burn operation is empty.
    error CMTAT_BurnModule_EmptyAccounts();
    /// @notice Reverts when the `accounts` and `values` arrays provided for batch burning have mismatched lengths.
    /// @dev Both arrays must contain the same number of elements.
    error CMTAT_BurnModule_AccountsValueslengthMismatch();

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
    * @dev internal function to burn in batch
    */
    function _batchBurn(
        address[] calldata accounts,
        uint256[] calldata values
    ) internal virtual {
        require(accounts.length != 0, CMTAT_BurnModule_EmptyAccounts());
        // We do not check that values is not empty since
        // this require will throw an error in this case.
        require(bool(accounts.length == values.length), CMTAT_BurnModule_AccountsValueslengthMismatch());
        for (uint256 i = 0; i < accounts.length; ++i ) {
             _burnOverride(accounts[i], values[i]);
        }
    }

    /**
    * @dev Internal function to burn
    * Can be override to perform supplementary check on burn action
    */
    function _burnOverride(
        address account,
        uint256 value
    ) internal virtual {
        ERC20Upgradeable._burn(account, value);
    }


}


// File contracts/modules/wrapper/core/ERC20BurnModule.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */

/* ==== Module === */

/* ==== Technical === */

/* ==== Tokenization === */


/**
 * @title ERC20Burn module.
 * @dev 
 *
 * Contains all burn functions, inherits from ERC-20
 */
abstract contract ERC20BurnModule is  ERC20BurnModuleInternal, AccessControlUpgradeable, IBurnBatchERC20, IERC3643Burn, IERC7551Burn {
    /* ============ State Variables ============ */
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev
     * @inheritdoc IERC7551Burn
     * @custom:access-control
     * - the caller must have the `BURNER_ROLE`.
     */
    function burn(
        address account,
        uint256 value,
        bytes calldata data
    ) public virtual override(IERC7551Burn) onlyRole(BURNER_ROLE) {
        _burn(account, value, data);
    }

    /**
     * @inheritdoc IERC3643Burn
     * @custom:access-control
     * - the caller must have the `BURNER_ROLE`.
     */
    function burn(
        address account,
        uint256 value
    ) public virtual override(IERC3643Burn) onlyRole(BURNER_ROLE) {
       _burn(account, value,"");
    }

    /**
     *
     * @inheritdoc IBurnBatchERC20
     * @custom:access-control
     * - the caller must have the `BURNER_ROLE`.
     */
    function batchBurn(
        address[] calldata accounts,
        uint256[] calldata values,
        bytes memory data
    ) public virtual override(IBurnBatchERC20) onlyRole(BURNER_ROLE) {
        _batchBurn(accounts, values);
        emit BatchBurn(_msgSender(),accounts, values, data );
    }

    /**
     *
     * @inheritdoc IERC3643Burn
     * @custom:access-control
     * - the caller must have the `BURNER_ROLE`.
     */
    function batchBurn(
        address[] calldata accounts,
        uint256[] calldata values
    ) public virtual override (IERC3643Burn) onlyRole(BURNER_ROLE) {
        _batchBurn(accounts, values);
        emit BatchBurn(_msgSender(),accounts, values, "" );
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _burn(
        address account,
        uint256 value,
        bytes memory data
    ) internal virtual {
        _burnOverride(account, value);
        emit Burn(_msgSender(), account, value, data);
    }
}


// File contracts/modules/internal/ERC20MintModuleInternal.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */

/**
 * @title ERC20Mint module.
 * @dev 
 *
 * Contains all mint functions, inherits from ERC-20
 */
abstract contract ERC20MintModuleInternal is ERC20Upgradeable {
    /// @notice Reverts when the `accounts` array provided for a mint batch operation is empty.
    error CMTAT_MintModule_EmptyAccounts();
    /// @notice Reverts when the `accounts` and `values` arrays provided for batch minting have mismatched lengths.
    /// @dev Both arrays must have the same number of elements.
    error CMTAT_MintModule_AccountsValueslengthMismatch();
    /// @notice Reverts when the `tos` array provided for a batch transfer is empty.
    error CMTAT_MintModule_EmptyTos();
    /// @notice Reverts when the `tos` and `values` arrays provided for batch transfer have mismatched lengths.
    /// @dev Both arrays must contain the same number of elements.
    error CMTAT_MintModule_TosValueslengthMismatch();


    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _batchMint(
        address[] calldata accounts,
        uint256[] calldata values
    ) internal virtual {
        require(accounts.length > 0, CMTAT_MintModule_EmptyAccounts());
        // We do not check that values is not empty since
        // this require will throw an error in this case.
        require(bool(accounts.length == values.length), CMTAT_MintModule_AccountsValueslengthMismatch());
        for (uint256 i = 0; i < accounts.length; ++i ) {
            _mintOverride(accounts[i], values[i]);
        }
    }

    function _batchTransfer(
        address[] calldata tos,
        uint256[] calldata values
    ) internal virtual returns (bool success_) {
        require(tos.length > 0, CMTAT_MintModule_EmptyTos());
        address sender = _msgSender();
        // We do not check that values is not empty since
        // this require will throw an error in this case.
        require(bool(tos.length == values.length), CMTAT_MintModule_TosValueslengthMismatch());
        for (uint256 i = 0; i < tos.length; ++i) {
            _minterTransferOverride(sender, tos[i], values[i]);
        }
        // not really useful
        // Here only to keep the same behaviour as transfer
        return true;
    }

    /**
    *  @dev Can be override to emit event
    */
    function _mintOverride(address account, uint256 value) internal virtual {
        ERC20Upgradeable._mint(account, value);
    }

    function _minterTransferOverride(address from, address to,uint256 value) internal virtual{
            // We call directly the internal OpenZeppelin function _transfer
            // The reason is that the public function adds only the owner address recovery
            ERC20Upgradeable._transfer(from, to, value);
     }
}


// File contracts/modules/wrapper/core/ERC20MintModule.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */

/* ==== Module === */

/* ==== Technical === */

/* ==== Tokenization === */


/**
 * @title ERC20Mint module.
 * @dev 
 *
 * Contains all mint functions, inherits from ERC-20
 */
abstract contract ERC20MintModule is  ERC20MintModuleInternal, AccessControlUpgradeable, IERC3643Mint, IERC3643BatchTransfer, IERC7551Mint, IMintBatchERC20Event {

    /* ============ State Variables ============ */
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @inheritdoc IERC7551Mint
     * @custom:devimpl
     * Requirements:
     * - `account` cannot be the zero address (check made by _mint).
     * @custom:access-control
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address account, uint256 value, bytes calldata data) public virtual override(IERC7551Mint) onlyRole(MINTER_ROLE) {
        _mint(account, value, data);
    }

    /**
     * @inheritdoc IERC3643Mint
     * @dev

     * Emits a {Mint} event.
     * Emits a {Transfer} event with `from` set to the zero address (emits inside _mint).
     *
     * Requirements:
     * - `account` cannot be the zero address (check made by _mint).
     * @custom:access-control
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address account, uint256 value) public virtual override(IERC3643Mint) onlyRole(MINTER_ROLE) {
       _mint(account, value, "");
    }

    /**
     *
     * @inheritdoc IERC3643Mint
     * @custom:devimpl
     * Requirement 
     * - `accounts` cannot contain a zero address (check made by _mint).
     * @custom:access-control
     * - the caller must have the `MINTER_ROLE`.
     */
    function batchMint(
        address[] calldata accounts,
        uint256[] calldata values
    ) public virtual override(IERC3643Mint) onlyRole(MINTER_ROLE) {
       _batchMint(accounts, values);
        emit BatchMint(_msgSender(), accounts, values);
    }
    
    /**
     * @inheritdoc IERC3643BatchTransfer
     * @custom:access-control
     * - the caller must have the `MINTER_ROLE`.
     */
   function batchTransfer(
        address[] calldata tos,
        uint256[] calldata values
    ) public virtual override(IERC3643BatchTransfer) onlyRole(MINTER_ROLE) returns (bool success_) {
        return _batchTransfer(tos, values);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _mint(address account, uint256 value, bytes memory data) internal virtual {
        _mintOverride(account, value);
        emit Mint(_msgSender(), account, value, data);
      }

}


// File contracts/interfaces/tokenization/ICMTAT.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
* The issuer must be able to “deactivate” the smart contract, to prevent execution of transactions on
* the distributed ledger.
* Contrary to the “burn” function, the “deactivateContract” function
* affects all tokens in issuance, and not only some of them. 
* 
* a) This function is necessary to allow the issuer to carry out certain corporate actions 
* (e.g. share splits, reverse splits or mergers), which 
* require that all existing tokens are either canceled or immobilized and decoupled from the shares
* (i.e. the tokens no longer represent shares).
* 
* b) The “deactivateContract” function can also be used if the issuer decides that it no longer wishes
* to have its shares issued in the form of ledger-based securities
* 
* The “deactivateContract” function does not delete the smart contract’s 
* storage and code, i.e. tokens are not burned by the function, however it permanently and
* irreversibly deactivates the smart contract (unless a proxy is used). 
* 
*/
interface ICMTATDeactivate {
     /**
     * @notice Emitted when the contract is permanently deactivated.
     * @param account The address that performed the deactivation.
     */
    event Deactivated(address account);

     /* 
     * @notice Permanently deactivates the contract.
     * @dev 
     * This action is irreversible — once executed, the contract cannot be reactivated.
     * Requirements:
     * - The contract MUST be paused before deactivation is allowed.
     * Emits a {Deactivated} event.
     * WARNING: Use with caution. This action permanently disables core contract functionality.
     */
    function deactivateContract() external;

     /**
     * @notice Returns whether the contract has been permanently deactivated.
     * @return isDeactivated A boolean indicating the deactivation status.
     * @dev Returns `true` if `deactivateContract()` has been successfully called.
     */
    function deactivated() external view returns (bool isDeactivated) ;
}



/** 
* @title ICMTATBase - Core Tokenization Metadata Interface as part of CMTAT specification
* @notice Defines base properties and metadata structure for a tokenized asset.
* @dev Includes token ID, terms (using IERC1643-compliant document), and a general information field.
*/
interface ICMTATBase {
    /* ============ Struct ============ */
     /*
     * @dev A reference to (e.g. in the form of an Internet address) or a hash of the tokenization terms
     */ 
     struct Terms {
 	    string name;
 	    IERC1643.Document doc;
    }
    /* ============ Events ============ */
    /**
    * @notice Emitted when the general information field is updated.
    * @param newInformation The newly assigned metadata or descriptive text.
    */
    event Information(
        string newInformation
    );
    /**
     * @notice Emitted when new tokenization terms are set.
     * @param newTerm The new Terms structure containing name and document reference.
     */
    event Term(Terms newTerm);

    /**
     * @notice Emitted when the token ID is set or updated.
     * @param newTokenIdIndexed The token ID (indexed for filtering).
     * @param newTokenId The full token ID string.
     */
    event TokenId(string indexed newTokenIdIndexed, string newTokenId);

    /* ============ View Functions ============ */

    /*
    * @notice return tokenization tokenId
    */
    function tokenId() external view returns (string memory tokenId_);
    /*
    * @notice returns tokenization terms
    */
    function terms() external view returns (Terms memory terms_);

    /*
    * @notice returns information field
    */
    function information() external view returns (string memory information_);


    /* ============ Write Functions ============ */
    /**
     * @notice Sets a new tokenization token ID.
     * @param tokenId_ The token ID string to assign to the tokenized asset.
     */
    function setTokenId(
        string calldata tokenId_
    ) external ;

    /**
     * @notice Sets new tokenization terms using a document reference.
     * @param terms_ The `DocumentInfo` structure referencing the terms document (name + URI + hash).
     */
    function setTerms(IERC1643CMTAT.DocumentInfo calldata terms_) external;

    /**
     * @notice Sets or updates the general information field.
     * @param information_ A string describing token attributes, usage, or metadata URI.
     */
    function setInformation(
        string calldata information_
    ) external;
}

interface ICMTATCreditEvents {
     /**
     * @notice Returns credit events
     */
    function creditEvents() external view returns(CreditEvents memory creditEvents_);

    struct CreditEvents {
        bool flagDefault;
        bool flagRedeemed;
        string rating;
    }
}
/**
* @notice interface to represent debt tokens
*/
interface ICMTATDebt {
    struct DebtInformation {
        DebtIdentifier debtIdentifier;
        DebtInstrument debtInstrument;
    }
    /**
    * @dev Information on the issuer and other persons involved
    */
    struct DebtIdentifier {
        string issuerName;
        string issuerDescription;
        string guarantor;
        string debtHolder;
    }
    /**
    * dev Information on the Instruments
    */
    struct DebtInstrument {
        // uint256
        uint256 interestRate;
        uint256 parValue;
        uint256 minimumDenomination;
        // string
        string issuanceDate;
        string maturityDate;
        string couponPaymentFrequency;
        /*
        * Interest schedule format (if any). The purpose of the interest schedule is to set, in the parameters of the smart
        *   contract, the dates on which the interest payments accrue.
        *    - Format A: start date/end date/period
        *   - Format B: start date/end date/day of period (e.g. quarter or year)
        *    - Format C: date 1/date 2/date 3/….
        */
        string interestScheduleFormat;
        /*
        * - Format A: period (indicating the period between the accrual date for the interest payment and the date on
        *   which the payment is scheduled to be made)
        * - Format B: specific date
        */
        string interestPaymentDate;
        string dayCountConvention;
        string businessDayConvention;
        string currency; 
        // address
        address currencyContract;
    }
    /**
     * @notice Returns debt information
     */
    function debt() external view returns(DebtInformation memory debtInformation_);
}


// File contracts/modules/wrapper/core/PauseModule.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */


/* ==== Tokenization === */



/**
 * @title Pause Module
 * @dev 
 * Put in pause or deactivate the contract
 * The issuer must be able to “pause” the smart contract, 
 * to prevent execution of transactions on the distributed ledger until the issuer puts an end to the pause. 
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 */
abstract contract PauseModule is PausableUpgradeable, AccessControlUpgradeable, IERC3643Pause, IERC7551Pause, ICMTATDeactivate {
    error CMTAT_PauseModule_ContractIsDeactivated();
    /* ============ State Variables ============ */
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.PauseModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant PauseModuleStorageLocation = 0xab1527b6135145d8da1edcbd6b7b270624e17f2b41c74a8c746ff388ad454700;
    /* ==== ERC-7201 State Variables === */
    struct PauseModuleStorage {
        bool _isDeactivated;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ State restricted functions ============ */
    /**
     * @inheritdoc IERC3643Pause
     * @custom:access-control
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public virtual override(IERC3643Pause, IERC7551Pause) onlyRole(PAUSER_ROLE) {
        PausableUpgradeable._pause();
    }

    /**
     * @inheritdoc IERC3643Pause
     * @custom:access-control
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public virtual override(IERC3643Pause, IERC7551Pause) onlyRole(PAUSER_ROLE) {
        PauseModuleStorage storage $ = _getPauseModuleStorage();
        require(!$._isDeactivated, CMTAT_PauseModule_ContractIsDeactivated());
        PausableUpgradeable._unpause();
    }

    /**
    * @inheritdoc ICMTATDeactivate
    * @custom:access-control
    * - the caller must have the `DEFAULT_ADMIN_ROLE`.
    * @custom:devimpl
    * With a proxy architecture, it is still possible to rollback by deploying a new implementation which sets the variable to false.
    */
    function deactivateContract()
        public virtual override(ICMTATDeactivate)
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        // Contract must be in pause state
        PausableUpgradeable._requirePaused();
        PauseModuleStorage storage $ = _getPauseModuleStorage();
        $._isDeactivated = true;
       emit Deactivated(_msgSender());
    }

    /* ============ View functions ============ */
    /**
    * @inheritdoc IERC3643Pause
    */
    function paused() public virtual view override(IERC3643Pause, IERC7551Pause, PausableUpgradeable)  returns (bool){
        return PausableUpgradeable.paused();
   }

    /**
    * @inheritdoc ICMTATDeactivate
    */
    function deactivated() public view virtual override(ICMTATDeactivate) returns (bool){
        PauseModuleStorage storage $ = _getPauseModuleStorage();
        return $._isDeactivated;
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/


    /* ============ ERC-7201 ============ */
    function _getPauseModuleStorage() private pure returns (PauseModuleStorage storage $) {
        assembly {
            $.slot := PauseModuleStorageLocation
        }
    }
}


// File contracts/modules/wrapper/controllers/ValidationModule.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */


/**
 * @title Validation module
 * @dev 
 *
 * Useful for to restrict and validate transfers
 */
abstract contract ValidationModule is
    PauseModule,
    EnforcementModule
{
    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ View functions ============ */
    /**
    * @dev check if the contract is deactivated or the address is frozen
    * check relevant for mint and burn operations
    */ 
    function _canMintBurnByModule(
        address target
    ) internal view virtual returns (bool) {
        if(PauseModule.deactivated() || EnforcementModule.isFrozen(target)){
            // can not mint or burn if the contract is deactivated
            // cannot burn if target is frozen (used forcedTransfer instead if available)
            // cannot mint if target is frozen
            return false;
        }
        return true;
    }

    /**
    * @dev calls Pause and Enforcement module
    */
    function _canTransferGenericByModule(
        address spender,
        address from,
        address to
    ) internal view virtual returns (bool) {
        // Mint
        if(from == address(0)){
            return _canMintBurnByModule(to);
        } // burn
        else if(to == address(0)){
            return _canMintBurnByModule(from);
        } // Normal transfer
        else if (EnforcementModule.isFrozen(spender) 
        || EnforcementModule.isFrozen(from) 
        || EnforcementModule.isFrozen(to) 
        || PauseModule.paused())  {
            return false;
        } else {
             return true;
        }
    }
}


// File contracts/modules/wrapper/core/ValidationModuleCore.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */

/* ==== Tokenization === */


/**
 * @dev Validation module Core
 *
 * Useful for to restrict and validate transfers
 */
abstract contract ValidationModuleCore is
    ValidationModule,
    IERC7551Compliance
{
    /* ============ View functions ============ */
    function canTransfer(
        address from,
        address to,
        uint256 value
    ) public view virtual override(IERC3643ComplianceRead) returns (bool) {
        return _canTransferByModule(address(0), from, to, value);
    }

    function canTransferFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) public view virtual override(IERC7551Compliance) returns (bool) {
        return _canTransferByModule(spender, from, to, value);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
    * @dev function used by canTransfer and operateOnTransfer
    */
    function _canTransferByModule(
        address spender,
        address from,
        address to,
        uint256 /*value*/
    ) internal view virtual returns (bool) {
        return ValidationModule._canTransferGenericByModule(spender, from, to);
    }
}


// File contracts/modules/wrapper/security/AccessControlModule.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */

abstract contract AccessControlModule is AccessControlUpgradeable {
    error CMTAT_AccessControlModule_AddressZeroNotAllowed();

    /* ============  Initializer Function ============ */
    /**
     * @dev
     *
     * - The grant to the admin role is done by AccessControlDefaultAdminRules
     * - The control of the zero address is done by AccessControlDefaultAdminRules
     *
     */
    function __AccessControlModule_init_unchained(address admin)
    internal onlyInitializing {
        if(admin == address(0)){
            revert CMTAT_AccessControlModule_AddressZeroNotAllowed();
        }
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }


    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /** 
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(
        bytes32 role,
        address account
    ) public view virtual override(AccessControlUpgradeable) returns (bool) {
        // The Default Admin has all roles
        if (AccessControlUpgradeable.hasRole(DEFAULT_ADMIN_ROLE, account)) {
            return true;
        } else {
            return AccessControlUpgradeable.hasRole(role, account);
        }
    }
}


// File contracts/modules/0_CMTATBaseCore.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */


/* ==== Wrapper === */
// ERC20



// Other



// Security

/* ==== Interface and other library === */





/**
* @dev CMTAT with core modules
*/
abstract contract CMTATBaseCore is
    // OpenZeppelin
    Initializable,
    ContextUpgradeable,
    BaseModule,
    // Core
    ERC20MintModule,
    ERC20BurnModule,
    ValidationModuleCore,
    ERC20BaseModule,
    IForcedBurnERC20,
    IBurnMintERC20,
    IERC7551ERC20EnforcementEvent,
    AccessControlModule
{  
    error CMTAT_BurnEnforcement_AddressIsNotFrozen(); 
    /*//////////////////////////////////////////////////////////////
                         INITIALIZER FUNCTION
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice
     * initialize the proxy contract
     * The calls to this function will revert if the contract was deployed without a proxy
     * @param admin address of the admin of contract (Access Control)
     * @param ERC20Attributes_ ERC20 name, symbol and decimals
     */
    function initialize(
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_
    ) public virtual initializer {
        __CMTAT_init(
            admin,
            ERC20Attributes_
        );
    }


    /**
     * @dev calls the different initialize functions from the different modules
     */
    function __CMTAT_init(
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_
    ) internal virtual onlyInitializing {
        /* OpenZeppelin library */
        // OZ init_unchained functions are called firstly due to inheritance
        __Context_init_unchained();

        // AccessControlUpgradeable inherits from ERC165Upgradeable
        __ERC165_init_unchained();

        // Openzeppelin
        __CMTAT_openzeppelin_init_unchained();

        /* Wrapper modules */
        __CMTAT_modules_init_unchained(admin, ERC20Attributes_);
    }

    /*
    * @dev OpenZeppelin
    */
    function __CMTAT_openzeppelin_init_unchained() internal virtual onlyInitializing {
         // AccessControlModule inherits from AccessControlUpgradeable
        __AccessControl_init_unchained();
        __Pausable_init_unchained();
    }


    /*
    * @dev CMTAT wrapper modules
    */
    function __CMTAT_modules_init_unchained(address admin, ICMTATConstructor.ERC20Attributes memory ERC20Attributes_ ) internal virtual onlyInitializing {
        // AccessControlModule_init_unchained is called firstly due to inheritance
        __AccessControlModule_init_unchained(admin);
        __ERC20BaseModule_init_unchained(ERC20Attributes_.decimalsIrrevocable, ERC20Attributes_.name, ERC20Attributes_.symbol);
    }


    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/


    /*//////////////////////////////////////////////////////////////
                Override ERC20Upgradeable, ERC20BaseModule
    //////////////////////////////////////////////////////////////*/

    /* ============  View Functions ============ */

    /**
    * @inheritdoc ERC20BaseModule
    */
    function decimals()
        public
        view
        virtual
        override(ERC20Upgradeable, ERC20BaseModule)
        returns (uint8)
    {
        return ERC20BaseModule.decimals();
    }


    /*
    * @inheritdoc ERC20BaseModule
    */
    function name() public virtual override(ERC20Upgradeable, ERC20BaseModule) view returns (string memory) {
        return ERC20BaseModule.name();
    }

    /*
    * @inheritdoc ERC20BaseModule
    */
    function symbol() public virtual override(ERC20Upgradeable, ERC20BaseModule) view returns (string memory) {
        return ERC20BaseModule.symbol();
    }

    /* ============  State Functions ============ */
    /*
    * @inheritdoc ERC20Upgradeable
    */
    function transfer(address to, uint256 value) public virtual override returns (bool) {
        address from = _msgSender();
        require(ValidationModuleCore.canTransfer(from, to, value), Errors.CMTAT_InvalidTransfer(from, to, value) );
        ERC20Upgradeable._transfer(from, to, value);
        return true;
    }
    /*
    * @inheritdoc ERC20BaseModule
    */
    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        public
        virtual
        override(ERC20Upgradeable, ERC20BaseModule)
        returns (bool)
    {
        require(ValidationModuleCore.canTransferFrom(_msgSender(),from, to, value), Errors.CMTAT_InvalidTransfer(from, to, value) );
        return ERC20BaseModule.transferFrom(from, to, value);
    }

    /*//////////////////////////////////////////////////////////////
                Functions requiring several modules
    //////////////////////////////////////////////////////////////*/

    /**
    * @inheritdoc IBurnMintERC20
    * @dev 
    * - The access control is managed by the functions burn (ERC20BurnModule) and mint (ERC20MintModule)
    * - Input validation is also managed by the functions burn and mint
    * - You can mint more tokens than burnt
    * @custom:access-control
    * - See {burn} and {mint}
    */
    function burnAndMint(address from, address to, uint256 amountToBurn, uint256 amountToMint, bytes calldata data) public virtual override(IBurnMintERC20) {
        ERC20BurnModule.burn(from, amountToBurn, data);
        ERC20MintModule.mint(to, amountToMint, data);
    }

    /**
    * @inheritdoc IForcedBurnERC20
    * @custom:access-control
    * - The caller must have the `DEFAULT_ADMIN_ROLE`.
    */
    function forcedBurn(
        address account,
        uint256 value,
        bytes memory data
    ) public virtual override(IForcedBurnERC20) onlyRole(DEFAULT_ADMIN_ROLE) {
        require(EnforcementModule.isFrozen(account), CMTAT_BurnEnforcement_AddressIsNotFrozen());
        // Skip ERC20BurnModule
        ERC20Upgradeable._burn(account, value);
        emit Enforcement(_msgSender(), account, value, data);
    }

    function hasRole(
        bytes32 role,
        address account
    ) public view virtual override(AccessControlUpgradeable, AccessControlModule) returns (bool) {
        return AccessControlModule.hasRole(role, account);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/


    function _mintOverride(address account, uint256 value) internal virtual override(ERC20MintModuleInternal) {
        require(ValidationModule._canMintBurnByModule(account), Errors.CMTAT_InvalidTransfer(address(0), account, value) );
        ERC20MintModuleInternal._mintOverride(account, value);
    }


    function _burnOverride(address account, uint256 value) internal virtual override(ERC20BurnModuleInternal) {
        require(ValidationModule._canMintBurnByModule(account), Errors.CMTAT_InvalidTransfer(account, address(0), value) );
        ERC20BurnModuleInternal._burnOverride(account, value);
    }

    /**
    * @dev Check if a minter transfer is valid
    */
    function _minterTransferOverride(address from, address to, uint256 value) internal virtual override(ERC20MintModuleInternal) {
        require(ValidationModuleCore.canTransfer(from, to, value), Errors.CMTAT_InvalidTransfer(from, to, value) );
        ERC20MintModuleInternal._minterTransferOverride(from, to, value);
    }
}


// File contracts/deployment/light/CMTATStandaloneLight.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.20;


/**
* @title CMTAT version for a standalone deployment (without proxy)
*/
contract CMTATStandaloneLight is CMTATBaseCore {
    /**
     * @notice Contract version for standalone light deployment
     * @param admin address of the admin of contract (Access Control)
     * @param ERC20Attributes_ ERC20 name, symbol and decimals
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_
    ) {
        // Initialize the contract to avoid front-running
        // Warning : do not initialize the proxy
        initialize(
            admin,
            ERC20Attributes_
        );
    }
}
