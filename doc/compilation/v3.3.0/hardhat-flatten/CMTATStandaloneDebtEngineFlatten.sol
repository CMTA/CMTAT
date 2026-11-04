// Sources flattened with hardhat v2.29.1 https://hardhat.org

// SPDX-License-Identifier: MIT AND MPL-2.0

// File @openzeppelin/contracts/proxy/utils/Initializable.sol@v5.7.0

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


// File @openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol@v5.7.0

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


// File @openzeppelin/contracts/utils/introspection/IERC165.sol@v5.7.0

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


// File @openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol@v5.7.0

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


// File @openzeppelin/contracts/access/IAccessControl.sol@v5.7.0

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


// File @openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol@v5.7.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.7.0) (access/AccessControl.sol)

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
    /// @inheritdoc ERC165Upgradeable
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
     * Emits a {RoleRevoked} event if the calling account had `role` and this call successfully revoked it.
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


// File @openzeppelin/contracts/interfaces/draft-IERC6093.sol@v5.7.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.5.0) (interfaces/draft-IERC6093.sol)

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
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in ERC-721.
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


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v5.7.0

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


// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol@v5.7.0

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


// File @openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol@v5.7.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.5.0) (token/ERC20/ERC20.sol)

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
     * `_spendAllowance` during the `transferFrom` operation sets the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the `transferFrom` operation can force the flag to
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


// File @openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol@v5.7.0

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


// File @openzeppelin/contracts/interfaces/IERC165.sol@v5.7.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC165.sol)

pragma solidity >=0.4.16;


// File contracts/interfaces/tokenization/draft-IERC1404.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

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
     * @param from The address sending tokens.
     * @param to The address receiving tokens.
     * @param value amount of tokens to transfer
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
     * @param restrictionCode The restriction code to translate into a message.
     * @return The human-readable message corresponding to `restrictionCode`.
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
     * @param spender The address initiating the delegated transfer.
     * @param from The address sending tokens.
     * @param to The address receiving tokens.
     * @param value amount of tokens to transfer
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


// File contracts/interfaces/technical/IERC5679.sol

// Original license: SPDX_License_Identifier: MPL-2.0
pragma solidity ^0.8.24;

interface IERC5679Mint {
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
interface IERC5679Burn {
     /**
     * @notice Burns a specific number of tokens from the given account by transferring it to address(0)
     * @dev 
     * - The account's balance is decreased by the specified amount.
     * - Emits a `Burn` event and a standard `Transfer` event with `to` set to `address(0)`.
     * - If the account balance (including frozen tokens) is less than the burn amount, the transaction MUST revert.
     * - If the token contract supports {IERC7551Pause}, paused transfers MUST NOT prevent this burn operation.
     * - The `data` parameter MAY be used to provide additional context (e.g., audit trail or documentation).
     * @param account The address whose tokens will be burned.
     * @param value The number of tokens to remove from circulation.
     * @param data Arbitrary additional data to document the burn.
     */
    function burn(address account, uint256 value, bytes calldata data) external;
}

// The EIP-165 identifier of this interface is 0xd0017968
interface IERC5679 is IERC5679Mint, IERC5679Burn, IERC165{}


// File contracts/interfaces/tokenization/draft-IERC7943.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

/**
* @notice Enforcement Interface for ERC-20 based implementations common with ERC-3643 interface.
* 
*/
interface IERC7943FungibleEnforcement {
    /* ============ View Functions ============ */
    /** 
    * @notice Checks the frozen status/amount.
    * @param account The address of the account.
    * @dev 
    * ERC-7943 specification: 
    *   It could return an amount higher than the account's balance.
    * ERC-3643 compatibility
    *   The frozen amount is always less than or equal to the total balance of the account.
    * @return amount The amount of tokens currently frozen for `account`.
    */
    function getFrozenTokens(address account) external view returns (uint256 amount);
    
    /* ============ State Functions ============ */
    /** 
    * @notice Takes tokens from one address and transfers them to another.
    * @dev 
    * Requires specific authorization. Used for regulatory compliance or recovery scenarios.
    * It MAY bypass the canTransfer checks. 
    *   If this happens, it MUST unfreeze the assets first 
    *   and emit a Frozen event before the underlying base token transfer event reflecting the change. 
    *   Having the unfrozen amount changed before the actual transfer is critical 
    *   for tokens that might be susceptible to reentrancy attacks doing external checks on recipients 
    *   as it is the case for ERC-721 and ERC-1155 tokens.
    * Compatibility with ERC-3643 (not part of IERC7943 interface):
    *      If IERC364320Enforcement is implemented:
    *      Require that the total value should not exceed available balance.
    *      In case the `from` address has not enough free tokens (unfrozen tokens)
    *      but has a total balance higher or equal to the `amount`
    *      the amount of frozen tokens is reduced in order to have enough free tokens
    *      to proceed the transfer, in such a case, the remaining balance on the `from`
    *      account is 100% composed of frozen tokens post-transfer.
    *      Emits a `TokensUnfrozen` event if `value` is higher than the free balance of `from`
    *      Emits a `Transfer` event
    * @param from The address from which `amount` is taken.
    * @param to The address that receives `amount`.
    * @param amount The amount to force transfer.
    * @return result True if the transfer executed correctly, false otherwise.
    */
    function forcedTransfer(address from, address to, uint256 amount) external returns(bool result);
}

interface IERC7943FungibleEnforcementSpecific {
    /** 
    * @notice Changes the frozen status of `amount` tokens belonging to `account`.
    * This overwrites the current value, similar to an `approve` function.
    * @dev Requires specific authorization. Frozen tokens cannot be transferred by the account.
    * @param account The address of the account whose tokens are to be frozen.
    * @param amount The amount of tokens to freeze. It can be greater than account balance.
    * @return result True if the freezing executed correctly, false otherwise.
    */
    function setFrozenTokens(address account, uint256 amount) external returns(bool result);
}
interface IERC7943FungibleEnforcementEventAndError{
    /**
     * @notice Error reverted when a transfer is attempted from `account` with an `amount` less than or equal to its balance, but greater than its unfrozen balance.
     * @param account The address holding the tokens.
     * @param amount The amount being transferred.
     * @param unfrozen The amount of tokens that are unfrozen and available to transfer.
     */
    error ERC7943InsufficientUnfrozenBalance(address account, uint256 amount, uint256 unfrozen);
    
    /** 
    * @notice Emitted when `setFrozenTokens` is called, changing the frozen `amount` of tokens for `account`.
    * @param account The address of the account whose tokens are being frozen.
    * @param amount The amount of tokens frozen after the change.
    */
    event Frozen(address indexed account, uint256 amount);

    /** @notice Emitted when tokens are taken from one address and transferred to another.
    * @param from The address from which tokens were taken.
    * @param to The address to which seized tokens were transferred.
    * @param amount The amount seized.
    */
    event ForcedTransfer(address indexed from, address indexed to, uint256 amount);
}

/**
* @notice Send/Receive Error Interface for ERC-20 based implementations.
*
*/
interface IERC7943FungibleSendReceiveError {
    /**
    * @notice Error reverted when an account is not allowed to send tokens.
    * @param account The address of the account which is not allowed to send.
    */
    error ERC7943CannotSend(address account);

    /**
    * @notice Error reverted when an account is not allowed to receive tokens.
    * @param account The address of the account which is not allowed to receive.
    */
    error ERC7943CannotReceive(address account);
}

/**
* @notice Transfer Error Interface for ERC-20 based implementations.
*
*/
interface IERC7943FungibleTransferError {
    /**
    * @notice Error reverted when a transfer is not allowed according to internal rules.
    * @param from The address from which tokens are being sent.
    * @param to The address to which tokens are being sent.
    * @param amount The amount sent.
    */
    error ERC7943CannotTransfer(address from, address to, uint256 amount);
}

interface IERC7943FungibleSendReceiveCheck {
    /// @notice Checks if a specific account is allowed to send tokens according to token rules.
    /// @dev This is often used for allowlist/KYC/KYB/AML checks.
    /// @param account The address to check.
    /// @return allowed True if the account is allowed to send, false otherwise.
    function canSend(address account) external view returns (bool allowed);

    /// @notice Checks if a specific account is allowed to receive tokens according to token rules.
    /// @dev This is often used for allowlist/KYC/KYB/AML checks.
    /// @param account The address to check.
    /// @return allowed True if the account is allowed to receive, false otherwise.
    function canReceive(address account) external view returns (bool allowed);
}


// File contracts/interfaces/tokenization/IERC3643Partial.sol

// Original license: SPDX_License_Identifier: MPL-2.0

/**
* Note:
* Parameter names may differ slightly from the original ERC3643 spec 
* to align with OpenZeppelin v5.3.0 naming conventions 
* (e.g., `amount` → `value`).
*/ 

pragma solidity ^0.8.24;

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
interface IERC3643Version {
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
interface IERC3643ERC20Enforcement is IERC7943FungibleEnforcement {
    /**
     * @dev Emitted when a certain amount of tokens is frozen on a wallet.
     * This event is emitted by `freezePartialTokens` and `batchFreezePartialTokens`.
     * @param account The wallet address impacted by the freezing status.
     * @param value The amount of tokens that is frozen.
     */
    event TokensFrozen(address indexed account, uint256 value);

    /**
     * @dev Emitted when a certain amount of tokens is unfrozen on a wallet.
     * This event is emitted by `unfreezePartialTokens` and `batchUnfreezePartialTokens`.
     * @param account The wallet address impacted by the freezing status.
     * @param value The amount of tokens that is unfrozen.
     */
    event TokensUnfrozen(address indexed account, uint256 value);
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
     * Emits a {Transfer} event with `from` set to `address(0)`.
     * Not part of ERC-3643: emits also a {Mint} event
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
     *   - Emits a {Transfer} event with `from` set to the zero address.
     * Not part of ERC-3643: emits also a {BatchMint} event
     *- Requires that `accounts` and `values` arrays have the same length.
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
     * - Not part of ERC-3643: emits also a {Burn} event
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
     *  Not part of ERC-3643: emits also a {BatchBurn} event
     *- This operation is gas-intensive and may fail if the number of accounts (`accounts.length`) is too large, causing an "out of gas" error.
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
     * @param from The address sending tokens.
     * @param to The address receiving tokens.
     * @param value The amount of tokens to transfer.
     * @return isValid True if the transfer is valid, false otherwise.
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


pragma solidity ^0.8.24;


/**
 * @title IERC7551Mint
 * @dev Interface for token minting operations. 
 */
interface IERC7551Mint is IERC5679Mint {
     /**
     * @notice Emitted when new tokens are minted and assigned to an account.
     * @param minter The address that initiated the mint operation.
     * @param account The address receiving the newly minted tokens.
     * @param value The amount of tokens created.
     * @param data Optional metadata associated with the mint (e.g., reason, reference ID).
     */
    event Mint(address indexed minter, address indexed account, uint256 value, bytes data);
}
/**
* @title interface for burn operation
*/
interface IERC7551Burn is IERC5679Burn {
     /**
     * @notice Emitted when tokens are burned from an account.
     * @param burner The address that initiated the burn.
     * @param account The address from which tokens were burned.
     * @param value The amount of tokens burned.
     * @param data Additional data related to the burn.
     */
    event Burn(address indexed burner, address indexed account, uint256 value, bytes data);
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
     * @notice Emitted when a forced transfer is executed.
     * @param operator The address that initiated the forced transfer.
     * @param from The address from which tokens are debited.
     * @param to The address to which tokens are credited.
     * @param value The amount of tokens transferred.
     * @param data Optional metadata associated with the action.
     */
    event ForcedTransfer(address indexed operator, address indexed from, address indexed to, uint256 value, bytes data);
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
    * @notice Emitted when the terms are updated.
    * @param hash_ The new hash value
    * @param uri_ The new string uri
    */
    event Terms(bytes32 hash_, string uri_);
    /**
    * @notice Emitted when the metadata string is updated.
    * @param newMetaData The new metadata value (e.g. a URL or reference hash).
    */
    event MetaData(string newMetaData);
    /**
     * @notice Returns the hash of the "Terms" document.
     * @return hash_ The `bytes32` hash of the terms document.
     */
    function termsHash() external view returns (bytes32 hash_);

    /**
     * @notice Sets the terms hash and URI.
     * @param hash_ The new hash of the document.
     * @param uri_ The corresponding URI.
     */
    function setTerms(bytes32 hash_, string calldata uri_) external;

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

pragma solidity ^0.8.24;




/*
* @title IRuleEngine - Minimal interface to define a RuleEngine
*/
interface IRuleEngine is IERC7551Compliance, IERC3643IComplianceContract, IERC165 {
    /**
     *  @notice
     *  Function called whenever tokens are transferred from one wallet to another, minted or burned,
     *  when the token knows the account that initiated the operation (`spender`).
     *  @dev
     *  Must revert if the transfer is invalid
     *  Same name as ERC-3643 but with one supplementary argument `spender`
     *  This function can be used to update state variables of the RuleEngine contract
     *  This function can be called ONLY by the token contract bound to the RuleEngine
     *
     *  Which overload the token calls (since CMTAT v3.3.0):
     *  - this 4-argument overload for `transferFrom` (`spender` = approved spender) and for every
     *    operation initiated by an operator, with the operator as `spender`: mint (`from == address(0)`),
     *    burn (`to == address(0)`), including `burnFrom`, self-burn and cross-chain mint/burn, and the
     *    minter `batchTransfer`;
     *  - the 3-argument ERC-3643 overload `transferred(from, to, value)`, inherited from
     *    {IERC3643IComplianceContract}, only for a direct `transfer`.
     *  Up to CMTAT v3.2.0, mint, burn and the minter transfer used the 3-argument overload.
     *
     *  WARNING - zero-value calls are permissionless. ERC-20 requires transfers of `0` to be
     *  treated as normal transfers, and OpenZeppelin's `_spendAllowance` consumes no allowance
     *  when `value == 0`. Any address can therefore call `transferFrom(victim, anyone, 0)` on the
     *  token and reach this callback for an arbitrary `from`, with itself as `spender`, without
     *  ever having been approved. The token deliberately does not suppress the notification,
     *  because doing so would make its compliance notifications inconsistent with its own
     *  ERC-20 transfer semantics.
     *
     *  Implementations MUST therefore treat `value == 0` as carrying no economic meaning: any
     *  stateful rule (cooldown, holding period, quota, tax bucket, counter, holder tracking, ...)
     *  MUST be a no-op for a zero value, otherwise an attacker can desynchronize policy state
     *  from balances, or keep a holder permanently restricted, at no cost. The same applies to
     *  the 3-argument ERC-3643 overload, which a zero-value `transfer(to, 0)` reaches the same way.
     *
     *  @param spender spender address (sender)
     *  @param from token holder address
     *  @param to receiver address
     *  @param value value of tokens involved in the transfer; MAY be `0` — see the warning above
     */
    function transferred(address spender, address from, address to, uint256 value) external;
}

/**
* @title IRuleEngineERC1404 -  RuleEngine interface with support of ERC-1404
*/
interface IRuleEngineERC1404 is IERC1404Extend, IRuleEngine {
    // Add support of IERC1404
    // No additionnal function needed
}


// File contracts/interfaces/tokenization/draft-IERC1643CMTAT.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;
interface IERC1643CMTAT {
    struct DocumentInfo {
        string name;
        string uri;
        bytes32 documentHash;
 }
}


// File contracts/interfaces/technical/ICMTATConstructor.sol

// Original license: SPDX_License_Identifier: MPL-2.0
pragma solidity ^0.8.24;


/**
* @notice interface to represent arguments used for CMTAT constructor / initialize
*/
interface ICMTATConstructor {
    struct Engine {
        IRuleEngine ruleEngine;
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


// File contracts/interfaces/engine/ISnapshotEngine.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

/*
* @dev minimum interface to define a SnapshotEngine
*/
interface ISnapshotEngine {
   /**
    * @notice Records balance and total supply snapshots before any token transfer occurs.
    * @dev This function should be called inside the {_update} hook so that
    * snapshots are updated prior to any state changes from {_mint}, {_burn}, or {_transfer}.
    * It ensures historical balances and total supply remain accurate for snapshot queries.
    * To avoid re-entrancy risk, you can store the different values (balance, totalSupply) in a local variable and
    * perform the call to the snapshotEngine after the {_update} hook by using the local variable
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


// File contracts/interfaces/modules/ISnapshotEngineModule.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

/* ==== Engine === */

/**
 * @title ISnapshotEngineModule
 * @notice Minimal interface for integrating a snapshot engine module.
 * @dev Provides methods to set and retrieve a snapshot engine used for capturing and referencing token states.
 */
interface ISnapshotEngineModule {
    /* ============ Events ============ */
    /**
     * @notice Emitted when a new snapshot engine is set.
     * @param newSnapshotEngine The address of the newly assigned snapshot engine contract.
     */

    event SnapshotEngine(ISnapshotEngine indexed newSnapshotEngine);
    /* ============ Error ============ */
    /**
     * @dev Reverts if the new snapshot engine is the same as the current one.
     */
    error CMTAT_SnapshotModule_SameValue();
    /* ============ Functions ============ */
    /**
     * @notice Sets the address of the snapshot engine contract.
     * @dev The snapshot engine is responsible for recording historical balances and supply snapshots.
     * Emits a {SnapshotEngine} event.
     * Reverts with {CMTAT_SnapshotModule_SameValue} if the new engine is the same as the current one.
     * @param snapshotEngine_ The new snapshot engine contract address to set.
     */
    function setSnapshotEngine(
        ISnapshotEngine snapshotEngine_
    ) external;
    /**
     * @notice Returns the currently set snapshot engine.
     * @return The address of the active snapshot engine contract.
     */
    function  snapshotEngine() external view returns (ISnapshotEngine);
}


// File contracts/modules/wrapper/extensions/SnapshotEngineModule.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

/* ==== OpenZeppelin === */

/* ==== Engine === */

/**
 * @title SnapshotEngine module 
 * @dev 
 *
 * Add on-chain snapshot through a SnapshotEngine (external contract) 
 */
abstract contract SnapshotEngineModule is Initializable, ISnapshotEngineModule {
    /* ============ State Variables ============ */
    bytes32 public constant SNAPSHOOTER_ROLE = keccak256("SNAPSHOOTER_ROLE");

    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.SnapshotEngineModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant SnapshotEngineModuleStorageLocation = 0x1387b97dfab601d3023cb57858a6be29329babb05c85597ddbe4926c1193a900;
    /* ==== ERC-7201 State Variables === */
    struct SnapshotEngineModuleStorage {
        ISnapshotEngine _snapshotEngine;
    }

    /* ============ Modifier ============ */
    modifier onlySnapshooter() {
        _authorizeSnapshots();
        _;
    }

    /* ============  Initializer Function ============ */
    /**
     * @dev
     *
     * - The grant to the admin role is done by AccessControlDefaultAdminRules
     * - The control of the zero address is done by AccessControlDefaultAdminRules
     * Warning: not used in the different deployment version to reduce contract code size and simplify code
     * If not used, the function will not be included in the final bytecode if compiled with the optimizer enabled
     */
    function __SnapshotEngineModule_init_unchained(ISnapshotEngine snapshotEngine_)
    internal virtual onlyInitializing {
        if (address(snapshotEngine_) != address (0)) {
            SnapshotEngineModuleStorage storage $ = _getSnapshotEngineModuleStorage();
            _setSnapshotEngine($, snapshotEngine_);
        }
    }


    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /* ============  State Restricted Functions ============ */
    /**
    * @inheritdoc ISnapshotEngineModule
    * @custom:access-control
    * - The caller must have the `SNAPSHOOTER_ROLE`.
    */
    function setSnapshotEngine(
        ISnapshotEngine snapshotEngine_
    ) public virtual override(ISnapshotEngineModule) onlySnapshooter  {
        SnapshotEngineModuleStorage storage $ = _getSnapshotEngineModuleStorage();
        require(address($._snapshotEngine) != address(snapshotEngine_), CMTAT_SnapshotModule_SameValue());
        _setSnapshotEngine($, snapshotEngine_);
    }

    
    /* ============ View functions ============ */

    /**
    * @inheritdoc ISnapshotEngineModule
    */
    function snapshotEngine() public view virtual override(ISnapshotEngineModule) returns (ISnapshotEngine) {
        SnapshotEngineModuleStorage storage $ = _getSnapshotEngineModuleStorage();
        return $._snapshotEngine;
    }
    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _setSnapshotEngine(
        SnapshotEngineModuleStorage storage $, ISnapshotEngine snapshotEngine_
    ) internal virtual {
        $._snapshotEngine = snapshotEngine_;
        emit SnapshotEngine(snapshotEngine_);
    }

    /* ============ Access Control ============ */
    function _authorizeSnapshots() internal virtual;
    /* ============ ERC-7201 ============ */
    function _getSnapshotEngineModuleStorage() private pure returns (SnapshotEngineModuleStorage storage $) {
        assembly {
            $.slot := SnapshotEngineModuleStorageLocation
        }
    }


}


// File contracts/modules/0_CMTATBaseSnapshot.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

/* ==== OpenZeppelin === */

/* ==== Wrapper === */

/* ==== Interface === */

/**
* @title Snapshot engine mixin
* @dev Pure mixin: provides _update logic with snapshot engine integration.
* Access control for setSnapshotEngine (_authorizeSnapshots) is left abstract
* and must be implemented by the inheriting contract.
*/
abstract contract CMTATBaseSnapshot is ERC20Upgradeable, SnapshotEngineModule {
    function _update(address from, address to, uint256 amount) internal virtual override(ERC20Upgradeable) {
        ISnapshotEngine snapshotEngineLocal = snapshotEngine();
        if (address(snapshotEngineLocal) != address(0)) {
            uint256 fromBalanceBefore = balanceOf(from);
            uint256 toBalanceBefore = balanceOf(to);
            uint256 totalSupplyBefore = totalSupply();
            ERC20Upgradeable._update(from, to, amount);
            snapshotEngineLocal.operateOnTransfer(from, to, fromBalanceBefore, toBalanceBefore, totalSupplyBefore);
        } else {
            ERC20Upgradeable._update(from, to, amount);
        }
    }
}


// File contracts/interfaces/technical/IMintBurnToken.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;


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
* @param data Optional data forwarded to the burn and mint hooks.
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
    /** ============ Events ============ */
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
     * - The `data` parameter is batch-level metadata for the `BatchBurn` event.
     * - It is not forwarded to each individual burn item.
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
   /** ============ Events ============ */
    /**
     * @notice Emitted when a spender burns tokens on behalf of an account, reducing the spender's allowance.
     * @param burner The address that initiated the burn.
     * @param account The owner address from which tokens were burned.
     * @param spender The address authorized to burn tokens on behalf of the owner.
     * @param value The amount of tokens burned.
     */
    event BurnFrom(address indexed burner, address indexed account, address indexed spender, uint256 value);

    /** ============ Functions ============ */
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
    * @dev This function is restricted to authorized roles.
    */
    function burn(uint256 value) external;
}


// File contracts/interfaces/technical/IERC20Allowance.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

/**
 * @title IERC20Allowance
 * @notice Interface for emitting spend-related events in ERC-20 based tokens.
 */
interface IERC20Allowance {
   /* ============ Events ============ */
    /**
     * @notice Emitted when a `spender` uses a `value` amount of an `account`'s allowance.
     * @dev
     * - Similar in intent to the ERC-20 `Approval` event, but signals *consumption* of an
     *   allowance rather than its granting.
     * - Emitted by the allowance-consuming entry points: `transferFrom` (ERC20BaseModule),
     *   `burnFrom` (ERC20CrossChainModule), and `forcedTransfer` (ERC20EnforcementModule) when the
     *   latter reduces a finite owner→recipient allowance.
     * - WARNING - this event does NOT, by itself, imply that the on-chain allowance decreased.
     *   It is emitted on *every* successful allowance-consuming `transferFrom` / `burnFrom`,
     *   including when the allowance is infinite (`type(uint256).max`), in which case OpenZeppelin
     *   leaves the allowance unchanged. `value` is the amount used, not the size of any reduction.
     * - For `forcedTransfer`, `Spend` is emitted only when the allowance is finite and non-zero
     *   (the case where it is actually reduced), and `value` is the amount taken from it (capped by
     *   the allowance). `forcedTransfer` does not emit `Approval` for that reduction.
     * - To reconstruct the current allowance, read `allowance(owner, spender)` — never accumulate
     *   `Spend` (or `Approval`) events.
     * - Event ordering differs between the emit sites: `transferFrom` emits `Transfer` then
     *   `Spend`; `burnFrom` emits `Spend` then `Transfer` then `BurnFrom`. See
     *   [doc/technical/allowance-spend-event.md](../../../doc/technical/allowance-spend-event.md).
     * @param account The owner of the tokens whose allowance is being spent.
     * @param spender The address authorized to spend the tokens.
     * @param value The amount of allowance used (not necessarily the amount by which it decreased).
     */
    event Spend(address indexed account, address indexed spender, uint256 value);
}


// File contracts/modules/wrapper/core/ERC20BaseModule.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

/* ==== OpenZeppelin === */

/* ==== Technical === */


/**
 * @title ERC20Base module
 * @dev
 *
 * Contains ERC-20 base functions and extension
 * Inherits from ERC-20
 * The mutable name/symbol attributes are managed by {TokenAttributeModule}
 */
abstract contract ERC20BaseModule is ERC20Upgradeable, IERC20Allowance, IERC20BatchBalance{
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.ERC20BaseModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC20BaseModuleStorageLocation = 0x9bd8d607565c0370ae5f91651ca67fd26d4438022bf72037316600e29e6a3a00;
    /* ==== ERC-7201 State Variables === */
    struct ERC20BaseModuleStorage {
        uint8 _decimals;
    }

    /* ============  Initializer Function ============ */
    /**
     * @dev Initializers: Sets the value for decimals.
     *
     * this value is immutable: it can only be set once during
     * construction/initialization.
     */
    function __ERC20BaseModule_init_unchained(
        uint8 decimals_
    ) internal virtual onlyInitializing {
        ERC20BaseModuleStorage storage $ = _getERC20BaseModuleStorage();
        $._decimals = decimals_;
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
            // emit Spend does not necessarily imply an allowance reduction
            // This is the case if the allowance is set to uint256.max
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

pragma solidity ^0.8.24;

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
    * @param accounts The accounts to burn tokens from.
    * @param values The amounts of tokens to burn, aligned with `accounts`.
    */
    function _batchBurn(
        address[] calldata accounts,
        uint256[] calldata values
    ) internal virtual {
        require(accounts.length != 0, CMTAT_BurnModule_EmptyAccounts());
        // We do not check that values is not empty since
        // this require will throw an error in this case.
        require(accounts.length == values.length, CMTAT_BurnModule_AccountsValueslengthMismatch());
        for (uint256 i = 0; i < accounts.length; ++i ) {
             _burnOverride(accounts[i], values[i]);
        }
    }

    /**
    * @dev Internal function to burn
    * Can be override to perform supplementary check on burn action
    * @param account The account to burn tokens from.
    * @param value The amount of tokens to burn.
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

pragma solidity ^0.8.24;

/* ==== Module === */

/* ==== Technical === */

/* ==== Tokenization === */


/**
 * @title ERC20Burn module.
 * @dev 
 *
 * Contains all burn functions, inherits from ERC-20
 */
abstract contract ERC20BurnModule is ERC20BurnModuleInternal, IBurnBatchERC20, IERC3643Burn, IERC7551Burn {
    /* ============ State Variables ============ */
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");


    /* ============ Modifier ============ */
    /// @dev Modifier to restrict access to the burner functions
    modifier onlyBurner() {
        _authorizeBurn();
        _;
    }

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
    ) public virtual override(IERC5679Burn) onlyBurner{
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
    ) public virtual override(IERC3643Burn) onlyBurner  {
       _burn(account, value,"");
    }

    /**
     *
     * @inheritdoc IBurnBatchERC20
     * @dev `data` is batch-level metadata emitted in {BatchBurn} only.
     * It is not forwarded to each internal burn item.
     * @custom:access-control
     * - the caller must have the `BURNER_ROLE`.
     */
    function batchBurn(
        address[] calldata accounts,
        uint256[] calldata values,
        bytes memory data
    ) public virtual override(IBurnBatchERC20) onlyBurner  {
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
    ) public virtual override (IERC3643Burn) onlyBurner {
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

    /* ============ Access Control ============ */
    function _authorizeBurn() internal virtual;
}


// File contracts/modules/internal/ERC20MintModuleInternal.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

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
        require(accounts.length == values.length, CMTAT_MintModule_AccountsValueslengthMismatch());
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
        require(tos.length == values.length, CMTAT_MintModule_TosValueslengthMismatch());
        for (uint256 i = 0; i < tos.length; ++i) {
            _minterTransferOverride(sender, tos[i], values[i]);
        }
        // not really useful
        // Here only to keep the same behaviour as transfer
        return true;
    }

    /**
    *  @dev Can be override to emit event
    *  @param account The account to mint tokens to.
    *  @param value The amount of tokens to mint.
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

pragma solidity ^0.8.24;

/* ==== Module === */

/* ==== Technical === */

/* ==== Tokenization === */


/**
 * @title ERC20Mint module.
 * @dev 
 *
 * Contains all mint functions, inherits from ERC-20
 */
abstract contract ERC20MintModule is  ERC20MintModuleInternal, IERC3643Mint, IERC3643BatchTransfer, IERC7551Mint, IMintBatchERC20Event {

    /* ============ State Variables ============ */
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");


    /* ============ Modifier ============ */
    /// @dev Modifier to restrict access to the burner functions
    modifier onlyMinter() {
        _authorizeMint();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @inheritdoc IERC5679Mint
     * @custom:devimpl
     * Requirements:
     * - `account` cannot be the zero address (check made by _mint).
     * @custom:access-control
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address account, uint256 value, bytes calldata data) public virtual override(IERC5679Mint) onlyMinter {
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
    function mint(address account, uint256 value) public virtual override(IERC3643Mint) onlyMinter {
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
    ) public virtual override(IERC3643Mint) onlyMinter{
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
    ) public virtual override(IERC3643BatchTransfer) onlyMinter returns (bool success_) {
        return _batchTransfer(tos, values);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _mint(address account, uint256 value, bytes memory data) internal virtual {
        _mintOverride(account, value);
        emit Mint(_msgSender(), account, value, data);
    }
    /* ============ Access Control ============ */
    function _authorizeMint() internal virtual;
}


// File contracts/modules/wrapper/core/TokenAttributeModule.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

/* ==== OpenZeppelin === */

/* ==== Tokenization === */

/**
 * @title TokenAttribute module
 * @dev
 *
 * Manages the mutable token attributes (name and symbol) independently of the
 * underlying token standard (ERC-20, ERC-7984, ...).
 *
 * The attributes are stored in this module's own ERC-7201 namespaced storage, so
 * a contract that also inherits a token standard (e.g. `ERC20Upgradeable`) only
 * has to override that standard's `name()` / `symbol()` to delegate here. This
 * keeps the metadata management reusable by non ERC-20 (e.g. confidential) tokens.
 */
abstract contract TokenAttributeModule is Initializable, IERC3643ERC20Base {
    /* ============ Events ============ */
    event Name(string indexed newNameIndexed, string newName);
    event Symbol(string indexed newSymbolIndexed, string newSymbol);

    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.TokenAttributeModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant TokenAttributeModuleStorageLocation = 0xc541cfc06cfa9bb7e38e614bc9457bd7310b58a2a620e4f19164873143c76d00;
    /* ==== ERC-7201 State Variables === */
    struct TokenAttributeModuleStorage {
        // We don't use the underlying token standard's name/symbol because we can not modify them
        string _name;
        string _symbol;
    }

    /* ============ Modifier ============ */
    modifier onlyTokenAttributeManager() {
        _authorizeTokenAttributeManagement();
        _;
    }

    /* ============  Initializer Function ============ */
    /**
     * @dev Initializers: sets the token name and symbol.
     */
    function __TokenAttributeModule_init_unchained(
        string memory name_,
        string memory symbol_
    ) internal virtual onlyInitializing {
        TokenAttributeModuleStorage storage $ = _getTokenAttributeModuleStorage();
        $._name = name_;
        $._symbol = symbol_;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ======== View functions ======= */
    /**
     * @notice Returns the name of the token.
     * @return The token name.
     */
    function name() public view virtual returns (string memory) {
        TokenAttributeModuleStorage storage $ = _getTokenAttributeModuleStorage();
        return $._name;
    }

    /**
     * @notice Returns the symbol of the token, usually a shorter version of the name.
     * @return The token symbol.
     */
    function symbol() public view virtual returns (string memory) {
        TokenAttributeModuleStorage storage $ = _getTokenAttributeModuleStorage();
        return $._symbol;
    }

    /* ======== State functions ======= */
    /**
     *  @inheritdoc IERC3643ERC20Base
     *  @dev
     *  WARNING - on deployment variants that also support ERC-2612 (`permit`), renaming the token does **not**
     *  change the EIP-712 domain separator. The domain name is captured at initialization by OpenZeppelin's
     *  `EIP712Upgradeable` and, per its own documentation, "cannot be changed except through a smart contract
     *  upgrade"; `DOMAIN_SEPARATOR()` therefore keeps using the original name after {setName}.
     *
     *  Existing and future permits remain valid: signers must simply build the EIP-712 domain from the ERC-5267
     *  {eip712Domain} function (or from `DOMAIN_SEPARATOR()`), which reports the name actually in use — never
     *  from {name}. A signature produced with the post-rename {name} is rejected with `ERC2612InvalidSigner`.
     */
    function setName(string calldata name_) public virtual override(IERC3643ERC20Base) onlyTokenAttributeManager {
        TokenAttributeModuleStorage storage $ = _getTokenAttributeModuleStorage();
        $._name = name_;
        emit Name(name_, name_);
    }

    /**
     * @inheritdoc IERC3643ERC20Base
     */
    function setSymbol(string calldata symbol_) public virtual override(IERC3643ERC20Base) onlyTokenAttributeManager {
        TokenAttributeModuleStorage storage $ = _getTokenAttributeModuleStorage();
        $._symbol = symbol_;
        emit Symbol(symbol_, symbol_);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ Access Control ============ */
    function _authorizeTokenAttributeManagement() internal virtual;

    /* ============ ERC-7201 ============ */
    function _getTokenAttributeModuleStorage() private pure returns (TokenAttributeModuleStorage storage $) {
        assembly {
            $.slot := TokenAttributeModuleStorageLocation
        }
    }
}


// File contracts/modules/wrapper/core/VersionModule.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

/* ==== Tokenization === */

/**
 * @title Version module
 * @dev 
 *
 * Retrieve the current contract version
 */
abstract contract VersionModule is IERC3643Version {
    /* ============ State Variables ============ */
    /** 
    * @dev 
    * Get the current version of the smart contract
    */
    string private constant VERSION = "3.3.0";
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
    * @inheritdoc IERC3643Version
    */
    function version() public view virtual override(IERC3643Version) returns (string memory version_) {
       return VERSION;
    }
}


// File contracts/modules/internal/ERC20EnforcementModuleInternal.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

/* ==== OpenZeppelin === */

/* ==== Technical === */

/* ==== Tokenization === */

/**
 * @title ERC20Enforcement module internal.
 * @dev 
 *
 * Contains specific ERC-20 enforcement actions
 */
abstract contract ERC20EnforcementModuleInternal is ERC20Upgradeable, IERC7943FungibleEnforcementEventAndError {
    // no argument to reduce contract code size
    error CMTAT_ERC20EnforcementModule_ZeroAddressNotAllowed();
    error CMTAT_ERC20EnforcementModule_ValueExceedsAvailableBalance();
    error CMTAT_ERC20EnforcementModule_ValueExceedsFrozenBalance(); 
    error CMTAT_ERC20EnforcementModule_ValueEqualCurrentFrozenTokens();
    error CMTAT_ERC20EnforcementModule_SelfTransferNotAllowed();
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.ERC20EnforcementModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC20EnforcementModuleStorageLocation = 0x9d8059a24cb596f1948a937c2c163cf14465c2a24abfd3cd009eec4ac4c39800;

    /* ==== ERC-7201 State Variables === */
    struct ERC20EnforcementModuleStorage {
        mapping(address account => uint256 frozenTokens)  _frozenTokens;
    }
    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _setFrozenTokens(address account, uint256 value) internal virtual returns(bool) {
        // The zero address holds no balance, so a non-zero frozen amount on it would make
        // _checkActiveBalance(address(0), value) fail for every value > 0 and revert the common
        // mint path (mint, batchMint, crosschainMint, the mint leg of burnAndMint).
        // Same guard as _freezePartialTokens / _unfreezePartialTokens.
        if (account == address(0)) {
            revert CMTAT_ERC20EnforcementModule_ZeroAddressNotAllowed();
        }
        ERC20EnforcementModuleStorage storage $ = _getEnforcementModuleStorage();
        uint256 frozenTokensLocal = $._frozenTokens[account];
        // Unfreeze path
        if(value < frozenTokensLocal) {
             uint256 difference = frozenTokensLocal - value;
             $ ._frozenTokens[account] =  value ;
             _unfreezeTokensEmitEvents(account,difference,  value);
        } else if(value > frozenTokensLocal) {
            // No underflow possible due to previous check
            uint256 difference = value - frozenTokensLocal;
            $._frozenTokens[account] = value;
            _freezeTokensEmitEvents(account, difference, value);
        } else { // Less probable path at the end
            revert CMTAT_ERC20EnforcementModule_ValueEqualCurrentFrozenTokens();
        }
        return true;
    }

    function _freezePartialTokens(address account, uint256 value) internal virtual{
       if (account == address(0)) {
            revert CMTAT_ERC20EnforcementModule_ZeroAddressNotAllowed();
        }
       ERC20EnforcementModuleStorage storage $ = _getEnforcementModuleStorage();
        // Retrieve current value
        uint256 balance = ERC20Upgradeable.balanceOf(account);
        uint256 frozenTokensLocal = $._frozenTokens[account] + value;
        // Check
        require(balance >= frozenTokensLocal, CMTAT_ERC20EnforcementModule_ValueExceedsAvailableBalance());
        // Update frozenTokens
        $._frozenTokens[account] = frozenTokensLocal;
        _freezeTokensEmitEvents(account, value, frozenTokensLocal);
    }

    function _unfreezePartialTokens(address account, uint256 value) internal virtual{
        if (account == address(0)) {
            revert CMTAT_ERC20EnforcementModule_ZeroAddressNotAllowed();
        }
        ERC20EnforcementModuleStorage storage $ = _getEnforcementModuleStorage();
        require($._frozenTokens[account] >= value, CMTAT_ERC20EnforcementModule_ValueExceedsFrozenBalance());
        // Update frozenBalance
        uint256 frozenTokensLocal  = $._frozenTokens[account] - value;
        $._frozenTokens[account] = frozenTokensLocal ;
        _unfreezeTokensEmitEvents(account, value,  frozenTokensLocal);
    }

    /**
    * @dev unfreeze tokens during a forced transfer/burn
    */
    function _unfreezeTokens(address account, uint256 value) internal virtual{
        uint256 balance = ERC20Upgradeable.balanceOf(account);
        if(value > balance){
           revert CMTAT_ERC20EnforcementModule_ValueExceedsAvailableBalance();
        } 
        ERC20EnforcementModuleStorage storage $ = _getEnforcementModuleStorage();
        uint256 frozenTokensLocal = $._frozenTokens[account];
        // default value is 0 for uninitialized variable
        uint256 activeBalance;
        // Frozen amounts can be > balance through setFrozenTokens.
        if (frozenTokensLocal < balance) {
            activeBalance = balance - frozenTokensLocal;
        }
        if (value > activeBalance) {
            uint256 tokensToUnfreeze = value - activeBalance;
            frozenTokensLocal =  frozenTokensLocal - tokensToUnfreeze;
            $._frozenTokens[account] = frozenTokensLocal;
            _unfreezeTokensEmitEvents(account, tokensToUnfreeze,  frozenTokensLocal);
        }
    }

    /**
    * @dev
    * Moves tokens through the ERC-20 `_update` primitive directly, without the pause/deactivation
    * validation applied to holder transfers and standard issuance. This is intentional: forced
    * transfer/burn is the enforcer's regulatory tool and, per ERC-8343, a named privileged operation
    * that remains available **after deactivation** (e.g. to sweep a frozen or migrated position).
    */
    function _forcedTransfer(address from, address to, uint256 value) internal virtual {
        // A self forced transfer moves no token, but _unfreezeTokens would still release the frozen ones
        require(from != to, CMTAT_ERC20EnforcementModule_SelfTransferNotAllowed());
        _unfreezeTokens(from, value);
        if(to == address(0)){
            ERC20Upgradeable._burn(from, value);
        } else{
            // Spend allowance
            // See https://ethereum-magicians.org/t/erc-3643-the-t-rex-token-standard/6844/11
            uint256 currentAllowance = allowance(from, to);
            if (currentAllowance > 0 && currentAllowance < type(uint256).max) {
                // Amount actually taken from the from->to allowance (capped by the allowance)
                uint256 spentAllowance = currentAllowance < value ? currentAllowance : value;
                unchecked {
                    ERC20Upgradeable._approve(from, to, currentAllowance - spentAllowance, false);
                }
                // Emit Spend so the allowance consumption is observable, consistent with
                // transferFrom / burnFrom. `_approve(..., false)` above still suppresses Approval.
                emit IERC20Allowance.Spend(from, to, spentAllowance);
            }
            ERC20Upgradeable._transfer(from, to, value);
        }
        emit ForcedTransfer(from, to, value);
    }

    function _freezeTokensEmitEvents(address account, uint256 /* difference */, uint256 frozenTokens) internal virtual {
        emit IERC7943FungibleEnforcementEventAndError.Frozen(account, frozenTokens);
    }

    function _unfreezeTokensEmitEvents(address account, uint256 /* difference */, uint256 frozenTokens) internal virtual {
        emit IERC7943FungibleEnforcementEventAndError.Frozen(account, frozenTokens );
    }

    /* ============ View functions ============ */
    function _checkActiveBalanceAndRevert(address from, uint256 value) internal virtual view {
        bool isValid;
        uint256 activeBalance;
        (isValid, activeBalance) = _checkActiveBalance(from, value);
        require(isValid, ERC7943InsufficientUnfrozenBalance(from, value,  activeBalance) );
    }

    /**
    * @dev we only check the balance if frozenTokens > 0
    * @return isValid True if `from` has enough unfrozen balance to move `value`.
    * @return activeBalance The unfrozen (active) balance available for `from`.
    */
    function _checkActiveBalance(address from, uint256 value) internal virtual view returns(bool isValid, uint256 activeBalance){
        uint256 frozenTokensLocal = _getFrozenTokens(from);
        if(frozenTokensLocal > 0 ){
            uint256 balance = ERC20Upgradeable.balanceOf(from);
            // Frozen amounts can be > balance through setFrozenTokens.
            if (frozenTokensLocal >= balance) {
                if (value == 0) {
                    return (true, 0);
                }
                return (false, 0);
            }
            activeBalance = balance - frozenTokensLocal;
            if(value > activeBalance) {
                   return (false, activeBalance);
            }
        } 
        // We don't check the balance if frozenTokens == 0
        // In case of insufficient balance for write call, the transaction (transfer, burn) will revert with an ERC-6093 custom errors
        return (true, activeBalance);
    }

    function _getFrozenTokens(address account) internal view virtual returns (uint256) {
        ERC20EnforcementModuleStorage storage $ = _getEnforcementModuleStorage();
        return $._frozenTokens[account];
     }

    function _getActiveBalanceOf(address account) internal view  returns (uint256){
        ERC20EnforcementModuleStorage storage $ = _getEnforcementModuleStorage();
        uint256 balance = ERC20Upgradeable.balanceOf(account);
        uint256 frozenTokens = $._frozenTokens[account];
        // Frozen amounts can be > balance through setFrozenTokens.
        if (frozenTokens >= balance) {
            return 0;
        }
        return balance - frozenTokens;
     }

    /* ============ ERC-7201 ============ */
    function _getEnforcementModuleStorage() private pure returns (ERC20EnforcementModuleStorage storage $) {
        assembly {
            $.slot := ERC20EnforcementModuleStorageLocation
        }
    }
}


// File contracts/modules/wrapper/extensions/ERC20EnforcementModule.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

/* ==== Module === */

/* ==== Tokenization === */


/**
 * @title ERC20Enforcement module.
 * @dev
 *
 * ERC-20 Enforcement related functions (freeze tokens, forced transfer).
 * Implements ERC-3643 and ERC-7943 enforcement interfaces.
 * For ERC-7551 enforcement (bytes data overloads), see ERC20EnforcementERC7551Module.
 */
abstract contract ERC20EnforcementModule is ERC20EnforcementModuleInternal, IERC3643ERC20Enforcement, IERC7943FungibleEnforcementSpecific {
    /* ============ State Variables ============ */
    bytes32 public constant ERC20ENFORCER_ROLE = keccak256("ERC20ENFORCER_ROLE");

    /* ============ Modifier ============ */
    /// @dev Modifier to restrict access to specific enforcer functions
    modifier onlyERC20Enforcer() {
        _authorizeERC20Enforcer();
        _;
    }

    /// @dev Modifier to restrict access to forced transfer functions
    modifier onlyForcedTransferManager() {
        _authorizeForcedTransfer();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IERC7943FungibleEnforcement
     */
    function getFrozenTokens(address account) public view virtual override(IERC7943FungibleEnforcement) returns (uint256 frozenBalance_) {
        return _getFrozenTokens(account);
    }

    /* ============  ERC-20 Enforcement ============ */
    /**
     * @inheritdoc IERC7943FungibleEnforcement
     * @custom:access-control
     * - Protected by `onlyForcedTransferManager`.
     */
    function forcedTransfer(address from, address to, uint256 value)
    public virtual override(IERC7943FungibleEnforcement) onlyForcedTransferManager returns (bool) {
        _forcedTransfer(from, to, value);
        return true;
    }

    /**
     * @inheritdoc IERC3643ERC20Enforcement
     * @custom:access-control
     * - Protected by `onlyERC20Enforcer`.
     */
    function freezePartialTokens(address account, uint256 value)
    public virtual override(IERC3643ERC20Enforcement) onlyERC20Enforcer {
        _freezePartialTokens(account, value);
    }

    /**
     * @inheritdoc IERC3643ERC20Enforcement
     * @custom:access-control
     * - Protected by `onlyERC20Enforcer`.
     */
    function unfreezePartialTokens(address account, uint256 value)
    public virtual override(IERC3643ERC20Enforcement) onlyERC20Enforcer {
        _unfreezePartialTokens(account, value);
    }

    /**
     * @inheritdoc IERC7943FungibleEnforcementSpecific
     * @custom:access-control
     * - Protected by `onlyERC20Enforcer`.
     */
    function setFrozenTokens(address account, uint256 value)
    public virtual override(IERC7943FungibleEnforcementSpecific) onlyERC20Enforcer
    returns (bool result) {
        return _setFrozenTokens(account, value);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ Events ============ */
    function _freezeTokensEmitEvents(address account, uint256 difference, uint256 frozenTokens) internal virtual override {
        super._freezeTokensEmitEvents(account, difference, frozenTokens);
        emit IERC3643ERC20Enforcement.TokensFrozen(account, difference);
    }

    function _unfreezeTokensEmitEvents(address account, uint256 difference, uint256 frozenTokens) internal virtual override {
        super._unfreezeTokensEmitEvents(account, difference, frozenTokens);
        emit IERC3643ERC20Enforcement.TokensUnfrozen(account, difference);
    }

    /* ============ Access Control ============ */
    function _authorizeERC20Enforcer() internal virtual;
    function _authorizeForcedTransfer() internal virtual;
}


// File contracts/interfaces/tokenization/draft-IERC1643.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

/**
* @title IERC1643 Document Management 
* @dev Part of the ERC1400 Security Token Standards
* Contrary to the original specification, use a struct Document to represent a Document
*/
interface IERC1643 {
    /// @dev Reverted when removing a document whose name is not registered.
    error ERC1643MissingDocument();
    /// @dev Reverted when setting a document with the zero name.
    error ERC1643InvalidName();

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
     * @dev Returns the three fields as flat values, matching the ERC-1643 ABI. A missing
     * document yields empty values and does not revert.
     * @param name The unique name used to identify the document.
     * @return uri The URI of the off-chain document.
     * @return documentHash The hash of the document content.
     * @return lastModified The timestamp of the last on-chain modification.
     */
    function getDocument(bytes32 name) external view returns (string memory uri, bytes32 documentHash, uint256 lastModified);
    /**
     * @notice Returns the list of all document names registered in the contract.
     * @return documentNames_ An array of strings representing all document identifiers.
     */
    function getAllDocuments() external view returns (bytes32[] memory documentNames_);

    function setDocument(bytes32 name, string calldata uri, bytes32 documentHash) external;

    function removeDocument(bytes32 name) external;

    event DocumentUpdated(bytes32 indexed name, string uri, bytes32 documentHash);

    event DocumentRemoved(bytes32 indexed name, string uri, bytes32 documentHash);
}


// File contracts/interfaces/tokenization/ICMTAT.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;


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
     struct CMTATTerms {
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
    event Terms(CMTATTerms newTerm);

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
    function terms() external view returns (CMTATTerms memory terms_);

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
     * @return creditEvents_ The current credit-event flags for the token.
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
     * @return debtInformation_ The current debt information for the token.
     */
    function debt() external view returns(DebtInformation memory debtInformation_);
}


// File contracts/modules/wrapper/extensions/ExtraInformationModule.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

/* ==== Openzeppelin === */

/* ==== Tokenization === */


/**
 * @title ExtraInformation module.
 * @dev 
 *
 * Add supplementary information on-chain (terms, tokenId, generic information)
 */
abstract contract ExtraInformationModule is Initializable, ICMTATBase {
     bytes32 public constant EXTRA_INFORMATION_ROLE = keccak256("EXTRA_INFORMATION_ROLE");
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.ExtraInformationModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ExtraInformationModuleStorageLocation = 0xd2d5d34c4a4dea00599692d3257c0aebc5e0359176118cd2364ab9b008c2d100;

    /* ==== ERC-7201 State Variables === */
    struct ExtraInformationModuleStorage {
            string _tokenId;
            CMTATTerms _terms;
            string _information;
    }

    /* ============ Modifier ============ */
    modifier onlyExtraInfoManager() {
        _authorizeExtraInfoManagement();
        _;
    }
    /* ============  Initializer Function ============ */
    /**
     * @dev Sets the values for {tokenId}, {terms_} and {information}.
     *
     */
    function __ExtraInformationModule_init_unchained(
        string memory tokenId_,
        IERC1643CMTAT.DocumentInfo memory terms_,
        string memory information_
    ) internal virtual onlyInitializing {
        ExtraInformationModuleStorage storage $ = _getExtraInformationModuleStorage();
        // tokenId
        _setTokenId($, tokenId_);
        // Terms
        _setTerms($, terms_);
        // Information
        _setInformation($, information_);
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /* ============  Restricted Functions ============ */
    
    /** 
    * @dev the tokenId will be changed even if the new value is the same as the current one
    * @custom:access-control
    * - the caller must have the `EXTRA_INFORMATION_ROLE`.
    */
    function setTokenId(
        string calldata tokenId_
    ) public virtual override(ICMTATBase) onlyExtraInfoManager {
        ExtraInformationModuleStorage storage $ = _getExtraInformationModuleStorage();
        _setTokenId($, tokenId_);
    }

    /** 
    * @inheritdoc ICMTATBase
    * @dev The terms will be changed even if the new value is the same as the current one
    * @custom:access-control
    * - the caller must have the `EXTRA_INFORMATION_ROLE`.
    */
    function setTerms(IERC1643CMTAT.DocumentInfo calldata terms_) public virtual override(ICMTATBase) onlyExtraInfoManager{
		_setTerms(terms_);
    }

    /** 
    * @inheritdoc ICMTATBase
    * @dev The information will be changed even if the new value is the same as the current one
    * @custom:access-control
    * - the caller must have the `EXTRA_INFORMATION_ROLE`.
    */
    
    function setInformation(
        string calldata information_
    ) public virtual onlyExtraInfoManager {
        ExtraInformationModuleStorage storage $ = _getExtraInformationModuleStorage();
        _setInformation($, information_);
    }

    /* ============ View functions ============ */
    /**
    * @inheritdoc ICMTATBase
    */
    function tokenId() public view  virtual override(ICMTATBase) returns (string memory tokenId_) {
        ExtraInformationModuleStorage storage $ = _getExtraInformationModuleStorage();
        return $._tokenId;
    }

    /**
    * @inheritdoc ICMTATBase
    */
    function terms() public view virtual override(ICMTATBase)  returns (CMTATTerms memory terms_) {
        ExtraInformationModuleStorage storage $ = _getExtraInformationModuleStorage();
        return $._terms;
    }
    
    /**
    * @inheritdoc ICMTATBase
    */
    function information() public view virtual override(ICMTATBase) returns (string memory information_) {
        ExtraInformationModuleStorage storage $ = _getExtraInformationModuleStorage();
        return $._information;
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _setTerms(IERC1643CMTAT.DocumentInfo memory terms_) internal{
		ExtraInformationModuleStorage storage $ = _getExtraInformationModuleStorage();
        _setTerms($, terms_);
    }

    /**
    * @dev Update the terms document (uri + hash) while leaving the document name untouched.
    *
    * Used by the ERC-7551 `setTerms(bytes32,string)` overload, whose signature carries no name:
    * forwarding an empty one through {_setTerms} would silently erase a name previously set via
    * {setTerms(IERC1643CMTAT.DocumentInfo)}.
    */
    function _setTermsDocument(bytes32 documentHash_, string memory uri_) internal virtual {
        ExtraInformationModuleStorage storage $ = _getExtraInformationModuleStorage();
        $._terms.doc.documentHash = documentHash_;
        $._terms.doc.uri = uri_;
        $._terms.doc.lastModified = block.timestamp;
        // Event
        emit Terms($._terms);
    }

    function _setTokenId(
        ExtraInformationModuleStorage storage $, string memory tokenId_
    ) internal virtual  {
        $._tokenId = tokenId_;
        emit TokenId(tokenId_, tokenId_);
    }

    function _setTerms(ExtraInformationModuleStorage storage $, IERC1643CMTAT.DocumentInfo memory terms_) internal virtual {
		// Terms/Document name
        $._terms.name = terms_.name;
        // Document
        $._terms.doc.documentHash  = terms_.documentHash;
        $._terms.doc.uri = terms_.uri;
        $._terms.doc.lastModified = block.timestamp;
		// Event
        emit Terms($._terms);
    }

    function _setInformation(ExtraInformationModuleStorage storage $, string memory information_) internal virtual {
        $._information  = information_;
        emit Information(information_);
    }

    /* ============ Access Control ============ */
    function  _authorizeExtraInfoManagement() internal virtual;

    /* ============ ERC-7201 ============ */
    function _getExtraInformationModuleStorage() private pure returns (ExtraInformationModuleStorage storage $) {
        assembly {
            $.slot := ExtraInformationModuleStorageLocation
        }
    }
}


// File contracts/modules/0_CMTATBaseCommon.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;


/* ==== Wrapper === */
// Core



// Extensions


// options


 /* ==== Interface and other library === */


abstract contract CMTATBaseCommon is
    // Core
    VersionModule,
    ERC20MintModule,
    ERC20BurnModule,
    ERC20BaseModule,
    TokenAttributeModule,
    // Extension
    ERC20EnforcementModule,
    ExtraInformationModule,
    // Interfaces
    IBurnMintERC20,
    IERC5679
{  


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


    /**
    * @inheritdoc TokenAttributeModule
    */
    function name() public view virtual override(ERC20Upgradeable, TokenAttributeModule)  returns (string memory) {
        return TokenAttributeModule.name();
    }

    /**
    * @inheritdoc TokenAttributeModule
    */
    function symbol() public view virtual override(ERC20Upgradeable, TokenAttributeModule) returns (string memory) {
        return TokenAttributeModule.symbol();
    }


    /* ============  State Functions ============ */
    function transfer(address to, uint256 value) public virtual override(ERC20Upgradeable) returns (bool) {
         address from = _msgSender();
        _checkTransferred(address(0), from, to, value);
        ERC20Upgradeable._transfer(from, to, value);
        return true;
    }
    /**
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
        _checkTransferred(_msgSender(), from, to, value);
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
    */
    function burnAndMint(address from, address to, uint256 amountToBurn, uint256 amountToMint, bytes calldata data) 
    public virtual override(IBurnMintERC20) {
        ERC20BurnModule.burn(from, amountToBurn, data);
        ERC20MintModule.mint(to, amountToMint, data);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _checkTransferred(address /*spender*/, address from, address /* to */, uint256 value) internal virtual {
        ERC20EnforcementModuleInternal._checkActiveBalanceAndRevert(from, value);
    } 
    /* ==== Mint and Burn Operations ==== */
    
    /**
    * @dev
    * Mint path
    * Check if the mint is valid
    * @inheritdoc ERC20MintModuleInternal
    */
    function _mintOverride(address account, uint256 value) internal virtual override(ERC20MintModuleInternal) {
        _checkTransferred(_msgSender(), address(0), account, value);
        ERC20MintModuleInternal._mintOverride(account, value);
    }

    /**
    * @dev
    * Burn path
    * Check if the burn is valid
    * @inheritdoc ERC20BurnModuleInternal
    */
    function _burnOverride(address account, uint256 value) internal virtual override(ERC20BurnModuleInternal) {
        _checkTransferred(_msgSender(),  account, address(0), value);
        ERC20BurnModuleInternal._burnOverride(account, value);
    }

    /**
    * @dev
    * Minter-initiated transfer path
    * Check if a minter transfer is valid
    * @inheritdoc ERC20MintModuleInternal
    */
    function _minterTransferOverride(address from, address to, uint256 value) internal virtual override(ERC20MintModuleInternal) {
        _checkTransferred(_msgSender(), from, to, value);
        ERC20MintModuleInternal._minterTransferOverride(from, to, value);
    }
}


// File contracts/library/ERC1404ExtendInterfaceId.sol

// Original license: SPDX_License_Identifier: MPL-2.0
pragma solidity ^0.8.24;

library ERC1404ExtendInterfaceId {
      /**
       * @dev ERC-165 interface id of IERC1404Extend.
       * Includes inherited IERC1404 functions:
       * - detectTransferRestriction(address,address,uint256)
       * - messageForTransferRestriction(uint8)
       * Plus IERC1404Extend function:
       * - detectTransferRestrictionFrom(address,address,address,uint256)
       *
       * Computed value: 0x78a8de7d
       */
      bytes4 public constant ERC1404EXTEND_INTERFACE_ID = 0x78a8de7d;
}


// File contracts/interfaces/tokenization/draft-IERC8343.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

/**
* @title IERC8343 - Contract Deactivation
* @notice Interface for permanently deactivating a token contract and exposing its
* deactivation status on-chain. Follows the proposed ERC-8343 (draft, not yet merged).
*
* @dev The issuer must be able to "deactivate" the smart contract, to prevent execution of
* transactions on the distributed ledger.
* Contrary to the "burn" function, the "deactivateContract" function
* affects all tokens in issuance, and not only some of them.
*
* a) This function is necessary to allow the issuer to carry out certain corporate actions
* (e.g. share splits, reverse splits or mergers), which
* require that all existing tokens are either canceled or immobilized and decoupled from the shares
* (i.e. the tokens no longer represent shares).
*
* b) The "deactivateContract" function can also be used if the issuer decides that it no longer wishes
* to have its shares issued in the form of ledger-based securities.
*
* The "deactivateContract" function does not delete the smart contract's
* storage and code, i.e. tokens are not burned by the function, however it permanently and
* irreversibly deactivates the smart contract (unless a proxy is used).
*
* @dev The ERC-8343 interface identifier is `0xe9cd80b0`, the exclusive-or of the selectors of
* `deactivateContract()` and `deactivated()`. This interface deliberately does NOT inherit
* `IERC165`, so that `type(IERC8343).interfaceId` equals `0xe9cd80b0`; adding `is IERC165` would
* fold `supportsInterface`'s selector into the id and change it. ERC-165 support is advertised
* separately by the implementing contract.
*/
interface IERC8343 {
     /**
     * @notice Emitted when the contract is permanently deactivated.
     * @param account The address that performed the deactivation.
     */
    event Deactivated(address indexed account);

    /**
     * @notice Error raised when deactivation is attempted after deactivation is already final.
     */
    error AlreadyDeactivated();

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
    function deactivated() external view returns (bool isDeactivated);
}


// File contracts/modules/wrapper/extensions/DocumentERC1643Module.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;


/**
 * @title DocumentERC1643 module
 * @dev In-contract ERC-1643 document management.
 */
abstract contract DocumentERC1643Module is Initializable, IERC1643 {
    bytes32 public constant DOCUMENT_ROLE = keccak256("DOCUMENT_ROLE");
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.DocumentERC1643Module")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant DocumentERC1643ModuleStorageLocation = 0x24fbb1cf6345ced60d5278ef6f68f4f7576fd9068704b4c8f1eec8f0bbd8a200;

    struct DocumentERC1643ModuleStorage {
        mapping(bytes32 => Document) _documents;
        mapping(bytes32 => uint256) _documentKey;
        bytes32[] _documentNames;
    }

    modifier onlyDocumentManager() {
        _authorizeDocumentManagement();
        _;
    }

    function getDocument(bytes32 name) public view virtual override returns (string memory uri, bytes32 documentHash, uint256 lastModified) {
        Document storage document = _getDocumentERC1643ModuleStorage()._documents[name];
        return (document.uri, document.documentHash, document.lastModified);
    }

    function getAllDocuments() public view virtual override returns (bytes32[] memory documentNames_) {
        return _getDocumentERC1643ModuleStorage()._documentNames;
    }

    function setDocument(bytes32 name, string calldata uri, bytes32 documentHash) public virtual override onlyDocumentManager {
        require(name != bytes32(0), ERC1643InvalidName());
        DocumentERC1643ModuleStorage storage $ = _getDocumentERC1643ModuleStorage();
        Document storage document = $._documents[name];
        document.uri = uri;
        document.documentHash = documentHash;
        document.lastModified = block.timestamp;

        if ($._documentKey[name] == 0) {
            $._documentNames.push(name);
            $._documentKey[name] = $._documentNames.length;
        }

        emit DocumentUpdated(name, uri, documentHash);
    }

    function removeDocument(bytes32 name) public virtual override onlyDocumentManager {
        DocumentERC1643ModuleStorage storage $ = _getDocumentERC1643ModuleStorage();
        uint256 key = $._documentKey[name];
        require(key != 0, ERC1643MissingDocument());

        Document memory document = $._documents[name];
        uint256 index = key - 1;
        uint256 lastIndex = $._documentNames.length - 1;

        if (index != lastIndex) {
            bytes32 movedName = $._documentNames[lastIndex];
            $._documentNames[index] = movedName;
            $._documentKey[movedName] = key;
        }

        $._documentNames.pop();
        delete $._documents[name];
        delete $._documentKey[name];

        emit DocumentRemoved(name, document.uri, document.documentHash);
    }

    function _authorizeDocumentManagement() internal virtual;

    function _getDocumentERC1643ModuleStorage() private pure returns (DocumentERC1643ModuleStorage storage $) {
        assembly {
            $.slot := DocumentERC1643ModuleStorageLocation
        }
    }
}


// File contracts/modules/1_CMTATBaseDocument.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

/**
 * @title Level-1 base with document management
 */
abstract contract CMTATBaseDocument is DocumentERC1643Module {}


// File contracts/modules/wrapper/security/AccessControlModule.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

/* ==== OpenZeppelin === */

abstract contract AccessControlModule is AccessControlUpgradeable {
    error CMTAT_AccessControlModule_AddressZeroNotAllowed();

    /* ============  Initializer Function ============ */
    /**
    * @notice Internal initializer that sets the provided address as the default admin.
    * @dev
    *  - MUST be called only during initialization (`onlyInitializing`).
    *  - Reverts if `admin` is the zero address.
    *  - Grants `DEFAULT_ADMIN_ROLE` to `admin`.  
    *    The return value of `_grantRole` is intentionally ignored, as it returns `false`
    *    only when the role was already assigned.
    *
    * @param admin The address that will receive the `DEFAULT_ADMIN_ROLE`.
    */
    function __AccessControlModule_init_unchained(address admin)
    internal onlyInitializing {
        if(admin == address(0)){
            revert CMTAT_AccessControlModule_AddressZeroNotAllowed();
        }
        // we don't check the return value
        // _grantRole attempts to grant `role` to `account` and returns a boolean indicating if `role` was granted.
        // return false only if the admin has already the role
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Returns `true` if `account` has been granted `role`.
     * @return True if `account` holds `role` (the default admin implicitly holds every role).
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


// File contracts/modules/2_CMTATBaseAccessControl.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

/* ==== OpenZeppelin === */

/* ==== Wrapper === */
// Security

// Core


// Extensions





// options

 /* ==== Interface and other library === */



abstract contract CMTATBaseAccessControl is
    AccessControlModule,
    CMTATBaseCommon,
    CMTATBaseDocument
{  

    /*//////////////////////////////////////////////////////////////
                         INITIALIZER FUNCTION
    //////////////////////////////////////////////////////////////*/
    function __CMTAT_commonModules_init_unchained(address admin, ICMTATConstructor.ERC20Attributes memory ERC20Attributes_, ICMTATConstructor.ExtraInformationAttributes memory ExtraInformationModuleAttributes_) internal virtual onlyInitializing {
        // AccessControlModule_init_unchained is called firstly due to inheritance
        __AccessControlModule_init_unchained(admin);
        // Core
        __ERC20BaseModule_init_unchained(ERC20Attributes_.decimalsIrrevocable);
        __TokenAttributeModule_init_unchained(ERC20Attributes_.name, ERC20Attributes_.symbol);
        /* Extensions */
        __ExtraInformationModule_init_unchained(ExtraInformationModuleAttributes_.tokenId, ExtraInformationModuleAttributes_.terms, ExtraInformationModuleAttributes_.information);
    }
    
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @inheritdoc AccessControlUpgradeable
     * @dev 
     * We can not use type(IERC5679).interfaceId instead of 0xd0017968
     * because IERC5679 inherits from two interfaces (IERC5679Burn and Mint)
     * 0x3edbb4c4 is the interfaceId of ERC-7943
     * type(IERC8343).interfaceId (0xe9cd80b0) is the proposed ERC-8343 (draft) contract deactivation interface
     * type(IERC1643).interfaceId (0xecfecec8) is the ERC-1643 document management interface
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlUpgradeable, IERC165) returns (bool) {
        return interfaceId == 0xd0017968 || interfaceId == 0x3edbb4c4 || interfaceId == type(IERC8343).interfaceId || interfaceId == type(IERC1643).interfaceId || AccessControlUpgradeable.supportsInterface(interfaceId);
    }


    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ==== Access Control Functions ==== */

    /** 
    * @custom:access-control
    * - the caller must have the `DEFAULT_ADMIN_ROLE`.
    */
    function _authorizeTokenAttributeManagement() internal virtual override(TokenAttributeModule) onlyRole(DEFAULT_ADMIN_ROLE){}

    /** 
    * @custom:access-control
    * - the caller must have the `MINTER_ROLE`.
    */
    function _authorizeMint() internal virtual override(ERC20MintModule) onlyRole(MINTER_ROLE){}

    /** 
    * @custom:access-control
    * - The caller must have the `BURNER_ROLE`.
    */
    function _authorizeBurn() internal virtual override(ERC20BurnModule) onlyRole(BURNER_ROLE){}

    /** 
    * @custom:access-control
    * - the caller must have the `DOCUMENT_ROLE`.
    */
    function _authorizeDocumentManagement() internal virtual override(DocumentERC1643Module) onlyRole(DOCUMENT_ROLE){}

    /** 
    * @custom:access-control
    * - the caller must have the `EXTRA_INFORMATION_ROLE`.
    */
    function  _authorizeExtraInfoManagement() internal virtual override(ExtraInformationModule) onlyRole(EXTRA_INFORMATION_ROLE){}

    /** 
    * @custom:access-control
    * - the caller must have the `ERC20ENFORCER_ROLE`.
    */
    function _authorizeERC20Enforcer() internal virtual override(ERC20EnforcementModule) onlyRole(ERC20ENFORCER_ROLE){}

    /** 
    * @custom:access-control
    * - the caller must have the `DEFAULT_ADMIN_ROLE`.
    */
    function _authorizeForcedTransfer() internal virtual override(ERC20EnforcementModule) onlyRole(DEFAULT_ADMIN_ROLE){}

}


// File contracts/modules/internal/common/EnforcementModuleLibrary.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

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
        require(accounts.length == status.length, CMTAT_Enforcement_AccountsValueslengthMismatch());
    }
}


// File contracts/modules/internal/EnforcementModuleInternal.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

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
    error CMTAT_Enforcement_ZeroAddressNotAllowed();
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
        if (account == address(0)) {
            revert CMTAT_Enforcement_ZeroAddressNotAllowed();
        }
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
     * @return _isListed True if the account is listed (frozen), false otherwise.
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

pragma solidity ^0.8.24;

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
    IERC3643Enforcement,
    IERC3643EnforcementEvent
{
    /* ============ State Variables ============ */
    bytes32 public constant ENFORCER_ROLE = keccak256("ENFORCER_ROLE");


    /* ============ Modifier ============ */
    /// @dev Modifier to restrict access to the address-freeze functions (via `_authorizeFreeze`, ENFORCER_ROLE)
    modifier onlyEnforcer() {
        _authorizeFreeze();
        _;
    }


    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ State restricted functions ============ */
    /**
    * @inheritdoc IERC3643Enforcement
    * @custom:access-control
    * - the caller must have the `ENFORCER_ROLE`.
    */
    function setAddressFrozen(address account, bool freeze) public virtual override(IERC3643Enforcement) onlyEnforcer{
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
    ) public virtual onlyEnforcer  {
         _addAddressToTheList(account, freeze, data);
    }

    /**
    * @inheritdoc IERC3643Enforcement
    * @custom:access-control
    * - the caller must have the `ENFORCER_ROLE`.
    */
    function batchSetAddressFrozen(
        address[] calldata accounts, bool[] calldata freezes
    ) public virtual override(IERC3643Enforcement) onlyEnforcer {
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

    /* ============ Access Control ============ */
    function _authorizeFreeze() internal virtual;
}


// File contracts/modules/wrapper/core/PauseModule.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

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
abstract contract PauseModule is PausableUpgradeable, IERC3643Pause, IERC7551Pause, IERC8343 {
    error CMTAT_PauseModule_ContractIsDeactivated();
    error EnforcedDeactivation();
    /* ============ State Variables ============ */
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.PauseModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant PauseModuleStorageLocation = 0xab1527b6135145d8da1edcbd6b7b270624e17f2b41c74a8c746ff388ad454700;
    /* ==== ERC-7201 State Variables === */
    struct PauseModuleStorage {
        bool _isDeactivated;
    }

    /* ============ Modifier ============ */
    /// @dev Modifier to restrict access to the burner functions
    modifier onlyPauseManager() {
        _authorizePause();
        _;
    }

    modifier onlyDeactivateContractManager() {
        _authorizeDeactivate();
        _;
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
    function pause() public virtual override(IERC3643Pause, IERC7551Pause) onlyPauseManager{
        PausableUpgradeable._pause();
    }

    /**
     * @inheritdoc IERC3643Pause
     * @custom:access-control
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public virtual override(IERC3643Pause, IERC7551Pause) onlyPauseManager{
        PauseModuleStorage storage $ = _getPauseModuleStorage();
        require(!$._isDeactivated, CMTAT_PauseModule_ContractIsDeactivated());
        PausableUpgradeable._unpause();
    }

    /**
    * @inheritdoc IERC8343
    * @custom:access-control
    * - the caller must have the `DEFAULT_ADMIN_ROLE`.
    * @custom:devimpl
    * With a proxy architecture, it is still possible to rollback by deploying a new implementation which sets the variable to false.
    */
    function deactivateContract()
        public virtual override(IERC8343)
        onlyDeactivateContractManager
    {
        // Contract must be in pause state
        PausableUpgradeable._requirePaused();
        PauseModuleStorage storage $ = _getPauseModuleStorage();
        if ($._isDeactivated) {
            revert AlreadyDeactivated();
        }
        $._isDeactivated = true;
       emit Deactivated(_msgSender());
    }

    /* ============ View functions ============ */
    /**
    * @inheritdoc IERC3643Pause
    */
    function paused() public virtual view override(IERC3643Pause, IERC7551Pause, PausableUpgradeable) returns (bool){
        return PausableUpgradeable.paused();
   }

    /**
    * @inheritdoc IERC8343
    */
    function deactivated() public view virtual override(IERC8343) returns (bool){
        PauseModuleStorage storage $ = _getPauseModuleStorage();
        return $._isDeactivated;
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ Access Control ============ */
    function _authorizePause() internal virtual;
    function _authorizeDeactivate() internal virtual;

    function _requireNotDeactivated() internal view virtual {
        if (deactivated()) {
            revert EnforcedDeactivation();
        }
    }

    /* ============ ERC-7201 ============ */
    function _getPauseModuleStorage() private pure returns (PauseModuleStorage storage $) {
        assembly {
            $.slot := PauseModuleStorageLocation
        }
    }
}


// File contracts/modules/internal/ValidationModuleRuleEngineInternal.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

/* ==== OpenZeppelin === */


/* ==== Engine === */

/*
 * @dev Set a ruleEngine for the ValidationModule
 *
 * Useful to restrict and validate transfers
 */
abstract contract ValidationModuleRuleEngineInternal is
    Initializable,
    ContextUpgradeable
{
    /* ============ Events ============ */
    /**
    * @notice Emitted when a new RuleEngine contract is set.
    * @param newRuleEngine The address of the RuleEngine that was configured.
    */
    event RuleEngine(IRuleEngine indexed newRuleEngine);
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.ValidationModuleRuleEngineInternal")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ValidationModuleRuleEngineStorageLocation = 0x77c8cc897d160e7bf5b10921804e357da17ae27460d4a6b5d9b27ffddf159d00;
    /* ==== ERC-7201 State Variables === */
    struct ValidationModuleRuleEngineStorage {
        IRuleEngine _ruleEngine;
    }

    /* ============  Initializer Function ============ */
    function __ValidationRuleEngine_init_unchained(
        IRuleEngine ruleEngine_
    ) internal onlyInitializing {
        if (address(ruleEngine_) != address(0)) {
            _setRuleEngine(ruleEngine_);
        }
    }


    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    /**
    * @notice Returns the current RuleEngine contract used for validation.
    * @return ruleEngine_ The address of the active RuleEngine.
    */
    function ruleEngine() public view returns(IRuleEngine){
        ValidationModuleRuleEngineStorage storage $ = _getValidationModuleRuleEngineStorage();
        return $._ruleEngine;
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /*
    * @dev set a RuleEngine
    * @param ruleEngine_ 
    * The call will be reverted if the new value of ruleEngine is the same as the current one
    */
    function _setRuleEngine(
        IRuleEngine ruleEngine_
    )  internal virtual {
        ValidationModuleRuleEngineStorage storage $ = _getValidationModuleRuleEngineStorage();
        $._ruleEngine = ruleEngine_;
        emit RuleEngine(ruleEngine_);
    }

    /* ============ ERC-7201 ============ */
    function _getValidationModuleRuleEngineStorage() private pure returns (ValidationModuleRuleEngineStorage storage $) {
        assembly {
            $.slot := ValidationModuleRuleEngineStorageLocation
        }
    }
}


// File contracts/modules/wrapper/controllers/ValidationModule.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

/* ==== Module === */



/**
 * @title Validation module
 * @dev 
 *
 * Useful for to restrict and validate transfers
 */
abstract contract ValidationModule is
    PauseModule,
    EnforcementModule,
    IERC7943FungibleSendReceiveError,
    IERC7943FungibleSendReceiveCheck
{

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /// @inheritdoc IERC7943FungibleSendReceiveCheck
    function canSend(address account) public view virtual override(IERC7943FungibleSendReceiveCheck) returns (bool allowed) {
        return _canSend(account);
    }

    /// @inheritdoc IERC7943FungibleSendReceiveCheck
    function canReceive(address account) public view virtual override(IERC7943FungibleSendReceiveCheck) returns (bool allowed) {
        return _canReceive(account);
    }
    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ View functions ============ */
    /**
    * @dev
    * Entrypoint to check mint/burn/standard transfer
    * @param spender The address initiating the transfer (address(0) for a direct transfer).
    * @param from The address tokens move from (address(0) for a mint).
    * @param to The address tokens move to (address(0) for a burn).
    * @return True if the mint/burn/transfer is allowed by the pause and enforcement modules.
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
        } // Standard transfer
        else {
            return _canTransferStandardByModule(spender, from, to);
        }
    }

    function _canTransferGenericByModuleAndRevert(
        address spender,
        address from,
        address to
    ) internal view virtual {
        // Mint
        if(from == address(0)){
             _canMintByModuleAndRevert(to);
        } // burn
        else if(to == address(0)){
            _canBurnByModuleAndRevert(from);
        } // Standard transfer
        else {
             _canTransferStandardByModuleAndRevert(spender, from, to);
        }
    }

    /**
    * @dev check if the contract is deactivated or the address is frozen
    * check relevant for mint and burn operations
    * Use forcedTransfer (or forcedBurn) to burn tokens from a frozen address
    * @return True if the mint/burn is allowed (contract not deactivated and `target` not frozen).
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
    * @dev Reverts if mint is not allowed for `to`.
    * Checks deactivation and frozen status of the recipient.
    * @param to The recipient whose mint is being validated.
    */
    function _canMintByModuleAndRevert(
        address to
    ) internal view virtual {
        _requireNotDeactivated();
        if(EnforcementModule.isFrozen(to)){
            revert ERC7943CannotReceive(to);
        }
    }

    /**
    * @dev Reverts if burn is not allowed for `from`.
    * Checks deactivation and frozen status of the token holder.
    * @param from The holder whose burn is being validated.
    */
    function _canBurnByModuleAndRevert(
        address from
    ) internal view virtual {
        _requireNotDeactivated();
        if(EnforcementModule.isFrozen(from)){
            revert ERC7943CannotSend(from);
        }
    }

    /**
    * @dev calls Pause and Enforcement module
    * check relevant for standard transfer
    * We don't check deactivated() because the contract must be in the pause state to be deactivated
    * @param spender The address initiating the transfer.
    * @param from The address tokens move from.
    * @param to The address tokens move to.
    * @return True if any of `spender`, `from` or `to` is frozen.
    */
    function _canTransferisFrozen(
        address spender,
        address from,
        address to
    ) internal view virtual returns (bool) {
        if (EnforcementModule.isFrozen(spender) 
        || EnforcementModule.isFrozen(from) 
        || EnforcementModule.isFrozen(to) ){
            return true;
        } else {
             return false;
        }
    }

    function _canTransferisFrozenAndRevert(
        address spender,
        address from,
        address to
    ) internal view virtual {
        if (EnforcementModule.isFrozen(spender)){
            revert ERC7943CannotSend(spender);
        } else if (EnforcementModule.isFrozen(from)) {
            revert ERC7943CannotSend(from);
        } else if(EnforcementModule.isFrozen(to) ){
            revert ERC7943CannotReceive(to);
        }
    }

  function _canTransferStandardByModule(
        address spender,
        address from,
        address to
    ) internal view virtual returns (bool) {
        if (_canTransferisFrozen(spender, from, to)
        || PauseModule.paused())  {
            return false;
        } else {
             return true;
        }
    }

    function _canTransferStandardByModuleAndRevert(
        address spender,
        address from,
        address to
    ) internal view virtual{
        /**
         * We don't check the deactivate status because
         * the contract will be in the pause state if deactivated
         * This removes a supplementary check and reduces runtime gas cost
         */
        _requireNotPaused();
        _canTransferisFrozenAndRevert(spender, from, to);
    }


    /**
    * @dev Returns true if `account` is allowed to send tokens.
    * Base check: account must not be frozen.
    * Override in subclasses to add allowlist or other checks.
    * @param account The account being checked.
    * @return allowed True if `account` is allowed to send tokens.
    */
    function _canSend(address account) internal view virtual returns (bool allowed) {
        return !EnforcementModule.isFrozen(account);
    }

    /**
    * @dev Returns true if `account` is allowed to receive tokens.
    * Base check: account must not be frozen.
    * Override in subclasses to add allowlist or other checks.
    * @param account The account being checked.
    * @return allowed True if `account` is allowed to receive tokens.
    */
    function _canReceive(address account) internal view virtual returns (bool allowed) {
        return !EnforcementModule.isFrozen(account);
    }
}


// File contracts/modules/wrapper/core/ValidationModuleCore.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

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
    * @param spender The address initiating the transfer.
    * @param from The address tokens move from.
    * @param to The address tokens move to.
    * @return True if the transfer is allowed by the validation module.
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


// File contracts/modules/wrapper/extensions/ValidationModule/ValidationModuleAllowance.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

/* ==== ValidationModule === */

/**
 * @dev Validation module for allowance authorization (`approve` and `permit`).
 *
 * It validates the allowance domain (`owner` + `spender`) instead of
 * transfer semantics (`spender` + `from` + `to`).
 */
abstract contract ValidationModuleAllowance is ValidationModuleCore {
    /**
     * @dev Reverts when allowance authorization cannot be performed.
     *
     * Requirements (for `value > 0`):
     * - contract must not be paused.
     * - `owner` must be allowed to send (`canSend` returns true).
     * - `spender` must be allowed to send (`canSend` returns true).
     *
     * Setting an allowance to zero is a **revocation**, never a new grant: it can only
     * reduce what a spender may move. It is therefore always authorized, including while
     * the contract is paused or when `owner`/`spender` is frozen or off the allowlist.
     * Blocking it would leave a holder unable to sever ties with a compromised or
     * sanctioned spender for the whole duration of the restriction, and would make the
     * zero-first allowance mitigation documented on `approve` unusable exactly when it
     * matters. No value can move while the restriction holds, since `transferFrom` is
     * gated by the same checks.
     *
     * @param owner The account granting (or revoking) the allowance.
     * @param spender The account being granted (or revoked).
     * @param value The new allowance value; `0` means revocation.
     */
    function _canAuthorizeAllowanceByModuleAndRevert(
        address owner,
        address spender,
        uint256 value
    ) internal view virtual {
        // A revocation is always allowed
        if (value == 0) {
            return;
        }
        _requireNotPaused();
        if (!_canSend(owner)) {
            revert ERC7943CannotSend(owner);
        }
        if (!_canSend(spender)) {
            revert ERC7943CannotSend(spender);
        }
    }
}


// File contracts/modules/wrapper/extensions/ValidationModule/ValidationModuleRuleEngine.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;


/* ==== Engine === */

/* ==== ValidationModule === */



/**
 * @dev Validation module with RuleEngine
 *
 * Useful for to restrict and validate transfers
 */
abstract contract ValidationModuleRuleEngine is
    ValidationModuleAllowance,
    ValidationModuleRuleEngineInternal
{
    /**
    * @notice Reverts if attempting to set the RuleEngine to its current value.
    */
    error CMTAT_ValidationModule_SameValue();


    /* ============ Modifier ============ */
    modifier onlyRuleEngineManager() {
        _authorizeRuleEngineManagement();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /* ============ State functions ============ */
    /**
    * @notice Updates the RuleEngine used for validation/compliance transfer logic.
    * @dev Reverts with `CMTAT_ValidationModule_SameValue` if the new RuleEngine is the same as the current one.
    * Requirements:
    * - Caller must have `DEFAULT_ADMIN_ROLE`.
    * Emits a {RuleEngine} event.
    * @param ruleEngine_ The new RuleEngine contract to set.
    * @custom:access-control
    * - The caller must have the `DEFAULT_ADMIN_ROLE`.
    */
    function setRuleEngine(
        IRuleEngine ruleEngine_
    ) public virtual onlyRuleEngineManager {
         require(address(ruleEngine_) != address(ruleEngine()), CMTAT_ValidationModule_SameValue());
        _setRuleEngine(ruleEngine_);
    }
    /* ============ View functions ============ */
    /**
    * @inheritdoc ValidationModuleCore
    * @dev call the ruleEngine if set
    */
    function canTransfer(
        address from,
        address to,
        uint256 value
    ) public view virtual override(ValidationModuleCore) returns (bool) {
       return _canTransfer(from, to, value);
    }

    /**
    * @inheritdoc ValidationModuleCore
    * @dev call the ruleEngine if set
    */
    function canTransferFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) public view virtual override(ValidationModuleCore) returns (bool) {
        return _canTransferFrom(spender, from, to, value);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ View functions ============ */
    function _canTransfer(
        address from,
        address to,
        uint256 value)
    internal view virtual returns (bool) {
       if (!ValidationModuleCore.canTransfer(from, to, value)) {
            return false;
        } else {
            return _canTransferWithRuleEngine(from, to, value);
        }
    }

    function _canTransferFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) internal view virtual returns (bool) {
        if (!ValidationModuleCore.canTransferFrom(spender, from, to, value)) {
            return false;
        } else {
            return _canTransferFromWithRuleEngine(spender, from, to, value);
        }
    }

    function _canTransferFromWithRuleEngine(
        address spender,
        address from,
        address to,
        uint256 value
    ) internal view virtual returns (bool) {
        IRuleEngine ruleEngine_ = ruleEngine();
        if (address(ruleEngine_) != address(0)) {
            return ruleEngine_.canTransferFrom(spender, from, to, value);
        } else{
            return true;
        }
    }
    function _canTransferWithRuleEngine(
        address from,
        address to,
        uint256 value
    ) internal view virtual returns (bool) {
        IRuleEngine ruleEngine_ = ruleEngine();
        if (address(ruleEngine_) != address(0)) {
            return ruleEngine_.canTransfer(from, to, value);
        } else{
            return true;
        }
    }

    /* ============ Access Control ============ */
    function _authorizeRuleEngineManagement() internal virtual;

    /* ============ State functions ============ */
    /**
    * @dev
    * @custom:security The RuleEngine callback is the only point at which a transfer hands control
    * to an external contract, and it happens *before* the ERC-20 balances move: the active-balance
    * (frozen) check in {CMTATBaseCommon-_checkTransferred} has already run against the pre-transfer
    * state and is not re-evaluated afterwards. A RuleEngine that reenters the token during
    * `transferred(...)` — because it is malicious, compromised, or because one of its rules calls
    * untrusted code — is therefore validated twice against the same snapshot, and the outer and
    * inner transfers can together move more than the holder's unfrozen balance, breaking the
    * `frozenTokens <= balanceOf` invariant.
    *
    * The external call is isolated in {_callRuleEngineTransferred}, which is `virtual` so that a
    * deployment variant can wrap it in a reentrancy guard by inheriting OpenZeppelin's
    * `ReentrancyGuardTransient` and overriding {_callRuleEngineTransferred} with `nonReentrant`
    * (see e.g. `contracts/deployment/CMTATStandardStandalone.sol`).
    *
    * WARNING - the guard is **not** enabled on every variant. It costs ~195 bytes of deployed
    * bytecode, and several variants are within a few hundred bytes of the EIP-170 24 KiB limit, so
    * enabling it there would make them undeployable. Variants without the guard rely on the standard
    * CMTAT trust assumption: the RuleEngine is set by `DEFAULT_ADMIN_ROLE`, is fully trusted, and
    * MUST NOT hand control to untrusted code during `transferred(...)`. See the module documentation
    * for the per-variant table.
    *
    * The guard is entered only when a RuleEngine is set, so a deployment with no engine pays
    * nothing, and it is released when the callback returns, so sequential hooks (batch operations,
    * `burnAndMint`) are unaffected.
    */
    function _transferred(address spender, address from, address to, uint256 value) internal virtual{
        _canTransferGenericByModuleAndRevert(spender, from, to);
        IRuleEngine ruleEngine_ = ruleEngine();
        if (address(ruleEngine_) != address(0)){
            _callRuleEngineTransferred(ruleEngine_, spender, from, to, value);
        }
    }

    /**
    * @dev Performs the RuleEngine `transferred` call.
    *
    * Declared `virtual` so a deployment variant can wrap it in a reentrancy guard by overriding it
    * with `nonReentrant` (inheriting OpenZeppelin's `ReentrancyGuardTransient`). The base
    * implementation is **unguarded**: see the security note on {_transferred} for which variants
    * enable the guard and why it is not enabled everywhere.
    */
    function _callRuleEngineTransferred(
        IRuleEngine ruleEngine_,
        address spender,
        address from,
        address to,
        uint256 value
    ) internal virtual {
        if(spender != address(0)){
            ruleEngine_.transferred(spender, from, to, value);
        } else {
            ruleEngine_.transferred(from, to, value);
        }
    }
}


// File contracts/modules/3_CMTATBaseRuleEngine.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

/* ==== OpenZeppelin === */

/* ==== Wrapper === */
// Core



// Extensions

// Controllers

 /* ==== Interface and other library === */


abstract contract CMTATBaseRuleEngine is
    CMTATBaseAccessControl,
    ValidationModuleRuleEngine,
    IERC7943FungibleTransferError
{
    /*//////////////////////////////////////////////////////////////
                         INITIALIZER FUNCTION
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice
     * initialize the proxy contract
     * The calls to this function will revert if the contract was deployed without a proxy
     * @param admin address of the admin of contract (Access Control)
     * @param ERC20Attributes_ ERC20 name, symbol and decimals
     * @param extraInformationAttributes_ tokenId, terms, information
     * @param engines_ external contract
     * @dev
     * If you override the public function initialize,
     * call inside directly the internal function, not the public one which is protected by the initializer modifier
     */
    function initialize(
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        ICMTATConstructor.ExtraInformationAttributes memory extraInformationAttributes_,
        ICMTATConstructor.Engine memory engines_ 
    ) public virtual initializer {
        _initialize(
            admin,
            ERC20Attributes_,
            extraInformationAttributes_,
            engines_
        );
    }

    /**
    * @dev don't call the initializer modifer
    */
    function _initialize(
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        ICMTATConstructor.ExtraInformationAttributes memory extraInformationAttributes_,
        ICMTATConstructor.Engine memory engines_ 
    ) internal virtual onlyInitializing{
        __CMTAT_init(
            admin,
            ERC20Attributes_,
            extraInformationAttributes_,
            engines_
        );
    }

    /**
     * @dev calls the different initialize functions from the different modules
     */
    function __CMTAT_init(
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        ICMTATConstructor.ExtraInformationAttributes memory ExtraInformationAttributes_,
        ICMTATConstructor.Engine memory engines_ 
    ) internal virtual onlyInitializing {
        /* OpenZeppelin library */
        // OZ init_unchained functions are called firstly due to inheritance
        __Context_init_unchained();

        // AccessControlUpgradeable inherits from ERC165Upgradeable
        __ERC165_init_unchained();

        // Openzeppelin
        __CMTAT_openzeppelin_init_unchained(ERC20Attributes_);
        /* Internal Modules */
       __CMTAT_internal_init_unchained(engines_);

        /* Wrapper modules */
        __CMTAT_modules_init_unchained(admin, ERC20Attributes_, ExtraInformationAttributes_);
    }

    /*
    * @dev OpenZeppelin
    */
    function __CMTAT_openzeppelin_init_unchained(ICMTATConstructor.ERC20Attributes memory ERC20Attributes_) internal virtual onlyInitializing {
         // AuthorizationModule inherits from AccessControlUpgradeable
        __AccessControl_init_unchained();
        __Pausable_init_unchained();
        // Note that the Openzeppelin functions name() and symbol() are overriden in ERC20BaseModule
        __ERC20_init_unchained(ERC20Attributes_.name, ERC20Attributes_.symbol);
    }

    /*
    * @dev CMTAT internal module
    */
    function __CMTAT_internal_init_unchained(ICMTATConstructor.Engine memory engines_) internal virtual onlyInitializing {
        __ValidationRuleEngine_init_unchained(engines_.ruleEngine);  
    }

    /*
    * @dev CMTAT wrapper modules
    */
    function __CMTAT_modules_init_unchained(address admin, ICMTATConstructor.ERC20Attributes memory ERC20Attributes_, ICMTATConstructor.ExtraInformationAttributes memory extraInformationAttributes_) internal virtual onlyInitializing {
        __CMTAT_commonModules_init_unchained(admin,ERC20Attributes_, extraInformationAttributes_);
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
    * @dev revert if the contract is in pause state, unless `value` is zero:
    * setting an allowance to zero is a revocation and stays available while paused
    * or while the owner/spender is frozen or off the allowlist.
    * @inheritdoc ERC20Upgradeable
    */
    function approve(address spender, uint256 value) public virtual override(ERC20Upgradeable) returns (bool) {
        // The pause check lives in _canAuthorizeAllowanceByModuleAndRevert, which lets a
        // revocation (value == 0) through. A `whenNotPaused` modifier here would block it.
        _canAuthorizeAllowanceByModuleAndRevert(_msgSender(), spender, value);
        return ERC20Upgradeable.approve(spender, value);
    }
    /**
    * @inheritdoc ValidationModuleRuleEngine
    */
    function canTransfer(
        address from,
        address to,
        uint256 value
    ) public virtual override (ValidationModuleRuleEngine) view returns (bool) {
        (bool isValid, ) = ERC20EnforcementModuleInternal._checkActiveBalance(from, value);
        if(!isValid){
            return false;
        } else {
            return ValidationModuleRuleEngine.canTransfer(from, to, value);
        }
    }

    /**
    * @inheritdoc ValidationModuleRuleEngine
    */
   function canTransferFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) public virtual override (ValidationModuleRuleEngine) view returns (bool) {
        (bool isValid,) = ERC20EnforcementModuleInternal._checkActiveBalance(from, value);
        if(!isValid){
            return false;
        } else {
            return ValidationModuleRuleEngine.canTransferFrom(spender, from, to, value);
        }
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ==== Access Control ==== */
    function _authorizePause() internal virtual override(PauseModule) onlyRole(PAUSER_ROLE){}
    function _authorizeDeactivate() internal virtual override(PauseModule) onlyRole(DEFAULT_ADMIN_ROLE){}

    function _authorizeFreeze() internal virtual override(EnforcementModule) onlyRole(ENFORCER_ROLE){}

    function _authorizeRuleEngineManagement() internal virtual override(ValidationModuleRuleEngine) onlyRole(DEFAULT_ADMIN_ROLE){}

    /* ==== Transfer/mint/burn restriction ==== */
    function _checkTransferred(address spender, address from, address to, uint256 value) internal virtual override(CMTATBaseCommon) {
        CMTATBaseCommon._checkTransferred(spender, from, to, value);
        ValidationModuleRuleEngine._transferred(spender, from, to, value);
    } 
}


// File contracts/modules/wrapper/extensions/ValidationModule/ValidationModuleERC1404.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;


/* ==== Tokenization === */



/**
 * @dev Validation module (ERC-1404)
 *
 * Useful for to restrict and validate transfers
 * Required a RuleEngine implementing the interface IRuleEngineERC1404
 *
 * @custom:scope {detectTransferRestriction} and {detectTransferRestrictionFrom} describe the
 * **holder transfer path only** — `transfer` and `transferFrom`. They do **not** govern the
 * mint and burn entry points, and the `address(0)` encoding of the ERC-1404 rework draft
 * (`from == address(0)` for a mint, `to == address(0)` for a burn) is **not** supported here:
 * a query built that way is answered as if it were a holder transfer, so it can report a
 * restriction the mint/burn path does not enforce (typically {PauseModule-paused}).
 *
 * The reason is structural, not an oversight. CMTAT exposes several entry points per
 * supply-changing operation and the **pause rule differs between them**:
 * - mint: `mint` / `batchMint` (`MINTER_ROLE`) are allowed while paused, `crosschainMint`
 *   (token bridge) is not;
 * - burn: `burn(address,uint256[,bytes])` / `batchBurn` (`BURNER_ROLE`) are allowed while paused,
 *   `burnFrom` (`BURNER_FROM_ROLE`), `burn(uint256)` (`BURNER_SELF_ROLE`) and `crosschainBurn`
 *   are not.
 *
 * `(from, to, value)` — and `(spender, from, to, value)` — carry no entry-point discriminator, and
 * the operator address does not identify one either (the same address may hold several burn roles),
 * so no single return value can describe every mint or every burn. Rather than designate a predictor
 * that would be right for one entry point and wrong for another, this module designates **none**.
 *
 * To predict a mint or a burn, use the module's own predicates instead — {canTransfer} /
 * {canTransferFrom}, which branch on the `address(0)` encoding through
 * {ValidationModule-_canTransferGenericByModule}, the same helper the enforcement path uses — and
 * the role/pause requirements documented per entry point.
 */
abstract contract ValidationModuleERC1404 is
   ValidationModuleRuleEngine, IERC1404Extend
{
    /* ============ State Variables ============ */
    string constant TEXT_TRANSFER_OK = "NoRestriction";
    string constant TEXT_UNKNOWN_CODE = "UnknownCode";

    /* EnforcementModule */
    string internal constant TEXT_TRANSFER_REJECTED_FROM_FROZEN =
        "AddrFromIsFrozen";

    string internal constant TEXT_TRANSFER_REJECTED_TO_FROZEN =
        "AddrToIsFrozen";

    string internal constant TEXT_TRANSFER_REJECTED_SPENDER_FROZEN =
        "AddrSpenderIsFrozen";

    /* PauseModule */
    string internal constant TEXT_TRANSFER_REJECTED_PAUSED =
        "EnforcedPause";

    /* Contract deactivated */
    string internal constant TEXT_TRANSFER_REJECTED_DEACTIVATED =
        "ContractDeactivated";

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice returns the human readable explanation 
     * corresponding to the error code returned by detectTransferRestriction
     * @param restrictionCode The error code returned by detectTransferRestriction
     * @return message The human readable explanation corresponding to the error code returned by detectTransferRestriction
     * @dev see {ERC-1404}
     */
    function messageForTransferRestriction(
        uint8 restrictionCode
    ) public virtual view override(IERC1404) returns (string memory message) {
          IRuleEngineERC1404 ruleEngine_ = IRuleEngineERC1404(address(ruleEngine()));
        if (restrictionCode == uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_OK)) {
            return TEXT_TRANSFER_OK;
        } else if (
            restrictionCode ==
            uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_PAUSED)
        ) {
            return TEXT_TRANSFER_REJECTED_PAUSED;
        } else if (
            restrictionCode ==
            uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_DEACTIVATED)
        ) {
            return TEXT_TRANSFER_REJECTED_DEACTIVATED;
        } else if (
            restrictionCode ==
            uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_FROM_FROZEN)
        ) {
            return TEXT_TRANSFER_REJECTED_FROM_FROZEN;
        } else if (
            restrictionCode ==
            uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_TO_FROZEN)
        ) {
            return TEXT_TRANSFER_REJECTED_TO_FROZEN;
        }  else if (
            restrictionCode ==
            uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_SPENDER_FROZEN)
        ) {
            return TEXT_TRANSFER_REJECTED_SPENDER_FROZEN;
        } else if (address(ruleEngine_) != address(0)) {
            return ruleEngine_.messageForTransferRestriction(restrictionCode);
        } else {
            return TEXT_UNKNOWN_CODE;
        }
    }
    
    /**
     * @notice check if value token can be transferred from `from` to `to`
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     * @return code of the rejection reason
     * @dev see {ERC-1404}
     * @dev Scope: `transfer` / `transferFrom` only. Passing `address(0)` as `from` or `to` to query
     * a mint or a burn is **not** supported — see the scope note on this contract; use
     * {canTransfer} / {canTransferFrom} for those operations.
     */
    function detectTransferRestriction(
        address from,
        address to,
        uint256 value
    ) public virtual view override(IERC1404) returns (uint8 code) {
         IRuleEngineERC1404 ruleEngine_ = IRuleEngineERC1404(address(ruleEngine()));
         uint8 codeReturn = _detectTransferRestriction(from, to, value);
         if(codeReturn != uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_OK) ){
            return codeReturn;
         } else if (address(ruleEngine_) != address(0)) {
            return ruleEngine_.detectTransferRestriction(from, to, value);
        } else{
            return uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_OK);
        }
    }

    /**
     * @notice check if `spender` can transfer `value` token from `from` to `to`
     * @param spender address The address initiating the delegated transfer
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     * @return code of the rejection reason
     * @dev see {ERC-1404} (rework draft, spender-aware extension)
     * @dev Scope: `transferFrom` only. The `spender` argument is the delegated-transfer initiator,
     * **not** a mint/burn operator: passing an operator with `from`/`to` set to `address(0)` to
     * predict a mint or a burn is not supported — see the scope note on this contract.
     * The `spender == from` case is deliberately evaluated through this path (no short-circuit to
     * {detectTransferRestriction}), because a frozen initiator blocks `transferFrom` even when it
     * owns the tokens.
     */
    function detectTransferRestrictionFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) public virtual view override(IERC1404Extend) returns (uint8 code) {
        IRuleEngineERC1404 ruleEngine_ = IRuleEngineERC1404(address(ruleEngine()));
        if (isFrozen(spender)) {
            return uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_SPENDER_FROZEN);
        } else {
            uint8 codeReturn = _detectTransferRestriction(from, to, value);
            if (codeReturn != uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_OK) ){
                return codeReturn;
            } else if (address(ruleEngine_) != address(0)) {
                return ruleEngine_.detectTransferRestrictionFrom(spender, from, to, value);
            } else { 
                return uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_OK);
            }
        } 
    }

     /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
    * @dev override this function to add further restriction
    * @return code The restriction code (0 = no restriction).
    */
    function _detectTransferRestriction(
        address from,
        address to,
        uint256 /* value */
    ) internal virtual view  returns (uint8 code) {
        if (deactivated()){
            return uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_DEACTIVATED);
        } else if (paused()) {
            return uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_PAUSED);
        } else if (isFrozen(from)) {
            return uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_FROM_FROZEN);
        } else if (isFrozen(to)) {
            return uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_TO_FROZEN);
        } 
        else {
            return uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_OK);
        }
    }
}


// File contracts/modules/4_CMTATBaseERC1404.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;


/* ==== Wrapper === */
// re-exported to keep {CMTATBaseERC20CrossChain} importing ERC20Upgradeable through this file

// Controllers



abstract contract CMTATBaseERC1404 is
    CMTATBaseRuleEngine,
    ValidationModuleERC1404
{
    /**
    * @dev ERC20EnforcementModule error text
    */
    string internal constant TEXT_TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE =
        "AddrFrom:insufficientActiveBalance";
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
    * @inheritdoc ValidationModuleERC1404
    */
    function messageForTransferRestriction(
        uint8 restrictionCode
    )  public view virtual override(ValidationModuleERC1404)  returns (string memory message) {
        if(restrictionCode == uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE)){
            return TEXT_TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE;
        } else {
            return ValidationModuleERC1404.messageForTransferRestriction(restrictionCode);
        }

    }

    /**
    * @inheritdoc ValidationModuleRuleEngine
    */
    function canTransfer(
        address from,
        address to,
        uint256 value
    ) public virtual override (CMTATBaseRuleEngine, ValidationModuleRuleEngine) view returns (bool) {
        return CMTATBaseRuleEngine.canTransfer(from, to, value);
    }

    /**
    * @inheritdoc ValidationModuleRuleEngine
    */
    function canTransferFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) public virtual override (CMTATBaseRuleEngine, ValidationModuleRuleEngine) view returns (bool) {
        return CMTATBaseRuleEngine.canTransferFrom(spender, from, to, value);
    }

    /**
    * @notice ERC-165 interface detection
    * @dev advertises support for both the canonical ERC-1404 interface
    * (`IERC1404`, id `0xab84a5c8`) and its CMTAT extension
    * (`IERC1404Extend`, id `0x78a8de7d`).
    * @dev The extension id is taken from {ERC1404ExtendInterfaceId} because
    * Solidity's `type(IERC1404Extend).interfaceId` excludes inherited
    * functions and would therefore only cover `detectTransferRestrictionFrom`.
    * @inheritdoc CMTATBaseAccessControl
    */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(CMTATBaseAccessControl) returns (bool) {
        return
            interfaceId == type(IERC1404).interfaceId ||
            interfaceId == ERC1404ExtendInterfaceId.ERC1404EXTEND_INTERFACE_ID ||
            super.supportsInterface(interfaceId);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
    * @dev Delegates the frozen-balance check to {ERC20EnforcementModuleInternal-_checkActiveBalance},
    * the same predicate the transfer path enforces, so the predicted restriction and the actual
    * transfer outcome cannot drift. In particular a zero-value transfer, which `_checkActiveBalance`
    * treats as always valid, is reported as unrestricted here as well.
    * @return code The restriction code (0 = no restriction).
    */
    function _detectTransferRestriction(
        address from,
        address to,
        uint256 value
    ) internal virtual override( ValidationModuleERC1404) view  returns (uint8 code) {
        (bool isValid, ) = _checkActiveBalance(from, value);
        if (!isValid) {
            return uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE);
        }
        return ValidationModuleERC1404._detectTransferRestriction(from, to, value);
    }
}


// File contracts/interfaces/technical/IGetCCIPAdmin.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.24;

interface IGetCCIPAdmin {
  event CCIPAdminTransferred(address indexed previousAdmin, address indexed newAdmin);
  
  /**
  * @notice Returns the admin of the token.
  * @dev This method is named to never conflict with existing methods.
  * @return The address of the token's CCIP admin.
  */
  function getCCIPAdmin() external view returns (address);
}


// File contracts/modules/wrapper/options/CCIPModule.sol

// Original license: SPDX_License_Identifier: MIT

pragma solidity ^0.8.24;

/**
 * @title Chainlink CCIP specific functions
 * @dev 
 *
 * Implement CCIP specific functions to make CMTAT compatible with Chainlink CCIP (CCT standard)
 * 
 */
abstract contract CCIPModule is IGetCCIPAdmin {
    /* ============ Error ============ */
    error CMTAT_CCIPModule_SameValue();
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.CCIPModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant CCIPModuleStorageLocation = 0x364fbfd89c0eee55bbc8dd10b1a9bf3e04fba9f3ee606f4c79a82f9941ad7a00;
 
    /* ==== ERC-7201 State Variables === */
    struct CCIPModuleStorage {
        /** 
        * @dev the CCIPAdmin can be used to register with the CCIP token admin registry, but has no other special powers,
        * and can only be transferred by calling setCCIPAdmin.
        */
        address  s_ccipAdmin;
    }

    /* ============ Modifier ============ */
    /// @dev Modifier to restrict access to the function setCCIPAdmin
    modifier onlyCCIPSetAdmin() {
        _authorizeCCIPSetAdmin();
        _;
    }

  /**
  * @notice Transfers the CCIPAdmin role to a new address
  * @dev only auhorised addresses (onlyCCIPSetAdmin) can call this function, NOT the current ccipAdmin, and 1-step ownership transfer is used.
  * @param newAdmin The address to transfer the CCIPAdmin role to. Setting to address(0) is a valid way to revoke
  * the role
  */ 
  function setCCIPAdmin(address newAdmin) public virtual onlyCCIPSetAdmin{
    CCIPModuleStorage storage $ = _getCCIPModuleStorage();
    address currentAdmin = $.s_ccipAdmin;
    require(newAdmin != currentAdmin, CMTAT_CCIPModule_SameValue());

    $.s_ccipAdmin = newAdmin;

    emit CCIPAdminTransferred(currentAdmin, newAdmin);
  }

  /**
  * Returns the current CCIPAdmin
  * @return The current CCIP admin address.
  */
  function getCCIPAdmin() public view virtual returns (address) {
    CCIPModuleStorage storage $ = _getCCIPModuleStorage();
    return $.s_ccipAdmin;
  }

  /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
  //////////////////////////////////////////////////////////////*/
  /* ==== Access Control ==== */
  function _authorizeCCIPSetAdmin() internal virtual;

  /* ============ ERC-7201 ============ */
  function _getCCIPModuleStorage() internal pure returns (CCIPModuleStorage storage $) {
        assembly {
            $.slot := CCIPModuleStorageLocation
        }
    }
}


// File contracts/interfaces/technical/IERC7802.sol

// Original license: SPDX_License_Identifier: MIT
// From https://github.com/ethereum-optimism/optimism/blob/op-node/v1.13.2/packages/contracts-bedrock/interfaces/L2/IERC7802.sol
pragma solidity ^0.8.24;

interface IERC7802 is IERC165 {
    /** 
    * @notice Mint tokens through a crosschain transfer.
    * @param to     Address to mint tokens to.
    * @param value Amount of tokens to mint.
    */
    function crosschainMint(address to, uint256 value) external;

    /**
    * @notice Burn tokens through a crosschain transfer.
    * @param from  Address to burn tokens from.
    * @param value Amount of tokens to burn.
    */
    function crosschainBurn(address from, uint256 value) external;
    /** 
    * @notice Emitted when a crosschain transfer mints tokens.
    * @param to       Address of the account tokens are being minted for.
    * @param value   Amount of tokens minted.
    * @param sender   Address of the account that finilized the crosschain transfer.
    */
    event CrosschainMint(address indexed to, uint256 value, address indexed sender);

    /**
    * @notice Emitted when a crosschain transfer burns tokens.
    * @param from     Address of the account tokens are being burned from.
    * @param value Amount of tokens burned.
    * @param sender   Address of the account that initiated the crosschain transfer.
    */
    event CrosschainBurn(address indexed from, uint256 value, address indexed sender);
}


// File contracts/modules/wrapper/options/ERC20CrossChainModule.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;
/* ==== OpenZeppelin === */

/* ==== Module === */

/* ==== Interfaces === */





/**
 * @title ERC20CrossChainModule (ERC-7802)
 * @dev 
 *
 * Contains all mint and burn functions, inherits from ERC-20
 * Implements ERC-7802 for cross-chain burn and mint
 */
abstract contract ERC20CrossChainModule is ERC20MintModule, ERC20BurnModule, ERC165Upgradeable, IERC7802, IBurnFromERC20 {
    /* ============ State Variables ============ */
    bytes32 public constant BURNER_FROM_ROLE = keccak256("BURNER_FROM_ROLE");
    bytes32 public constant BURNER_SELF_ROLE = keccak256("BURNER_SELF_ROLE");
    bytes32 public constant CROSS_CHAIN_ROLE = keccak256("CROSS_CHAIN_ROLE");

    /* ============ Modifier ============ */
    /// @dev Modifier to restrict access to the token bridge.
    /// Source: OpenZeppelin v5.4.0 - draft-ERC20Bridgeable.sol
    modifier onlyTokenBridge() {
        // Token bridge should never be impersonated using a relayer/forwarder. Using msg.sender is preferable to
        // _msgSender() for security reasons.
        //
        // DEPLOYMENT CONSTRAINT - this is the only role gate in CMTAT that authorizes the raw msg.sender, so a
        // bridge MUST call crosschainMint/crosschainBurn directly; a call relayed through the ERC-2771 forwarder
        // reverts, because the forwarder is the raw caller. CROSS_CHAIN_ROLE MUST NOT be granted to that
        // forwarder to work around it: every relayed call would then pass this gate, letting any user mint an
        // arbitrary amount to any address. See doc/technical/cross-chain-bridge-integration.md
        _checkTokenBridge(msg.sender);
        _;
    }

        /// @dev Modifier to restrict access to the burner functions
    modifier onlyBurnerFrom() {
        _authorizeBurnFrom();
        _;
    }

    /// @dev Modifier to restrict access to the burner functions
    modifier onlySelfBurn() {
        _authorizeSelfBurn();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
    * @inheritdoc IERC7802
    * @dev
    * Don't emit the same event as configured in the ERC20MintModule
    * @custom:access-control
    * Protected by the modifier onlyTokenBridge.
    */
    function crosschainMint(address to, uint256 value) public virtual override(IERC7802) onlyTokenBridge {
        _mintOverride(to, value);
        emit CrosschainMint(to, value,_msgSender());
    }

    /**
    * @inheritdoc IERC7802
    * @dev
    * Don't emit the same event as configured in the ERC20BurnModule
    * Don't require allowance to follow Optimism Superchain ERC20 and OpenZeppelin implementation
    * @custom:access-control
    * - Protected by the modifier onlyTokenBridge.
    */
    function crosschainBurn(address from, uint256 value) public virtual override(IERC7802) onlyTokenBridge{
        _burnOverride(from, value);
        emit CrosschainBurn(from, value, _msgSender());
    }

    /**
     * @inheritdoc IBurnFromERC20
     * @custom:access-control
     * - Protected by the modifier onlyBurnerFrom.
     */
    function burnFrom(address account, uint256 value)
        public virtual override(IBurnFromERC20) onlyBurnerFrom
    {
        address sender =  _msgSender();
        _burnFrom(sender, account, value); 
    }

    /**
    * @inheritdoc IBurnFromERC20
    * @custom:access-control
    * - Protected by the modifier onlySelfBurn (BURNER_SELF_ROLE).
    */
    function burn(
        uint256 value
    ) public virtual override(IBurnFromERC20) onlySelfBurn{
        address sender = _msgSender();
        _burnFromOperator(sender, sender, value);
    }

    /* ============ View functions ============ */
    function supportsInterface(bytes4 _interfaceId) public view virtual override(ERC165Upgradeable, IERC165) returns (bool) {
        return _interfaceId == type(IERC7802).interfaceId || ERC165Upgradeable.supportsInterface(_interfaceId);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _burnFrom(address sender, address account, uint256 value) internal virtual{
        // Allowance check and spend
        ERC20Upgradeable._spendAllowance(account, sender, value );
        // Specific event for the spend operation, same as transferFrom (ERC20BaseModule)
        // Importing the event through inheritance will result in the following error: "Linearization of inheritance graph impossible"
        emit IERC20Allowance.Spend(account, sender, value);
        _burnFromOperator(sender, account, value);
    }

    function _burnFromOperator(address sender, address account, uint256 value) internal virtual {
        _burnOverride(account, value);
        emit BurnFrom(sender, account, sender, value);
    }

    /* ==== Access Control ==== */
    /**
     * @dev Checks if the caller is a trusted token bridge. MUST revert otherwise.
     *
     * Source: OpenZeppelin v5.4.0 - draft-ERC20Bridgeable.sol
     */
    function _checkTokenBridge(address caller) internal virtual;

    function _authorizeBurnFrom() internal virtual;

    function _authorizeSelfBurn() internal virtual;
}


// File contracts/modules/5_CMTATBaseERC20CrossChain.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;
/* ==== OpenZeppelin === */

/* ==== Module === */






/**
 * @title Add support of ERC20CrossChainModule
 */
abstract contract CMTATBaseERC20CrossChain is ERC20CrossChainModule, CCIPModule, CMTATBaseERC1404  {
     /* ============  State Functions ============ */
        /**
    * @dev revert if the contract is in pause state, unless `value` is zero:
    * setting an allowance to zero is a revocation and stays available while paused
    * or while the owner/spender is frozen or off the allowlist.
    * @inheritdoc ERC20Upgradeable
    */
    function approve(address spender, uint256 value) public virtual override(ERC20Upgradeable, CMTATBaseRuleEngine) returns (bool) {
        return CMTATBaseRuleEngine.approve(spender, value);
    }
    function transfer(address to, uint256 value) public virtual override(ERC20Upgradeable, CMTATBaseCommon) returns (bool) {
         return CMTATBaseCommon.transfer(to, value);
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
        override(ERC20Upgradeable, CMTATBaseCommon)
        returns (bool)
    {
        return CMTATBaseCommon.transferFrom(from, to, value);
    }

    /* ============ View functions ============ */
  
    /**
    * @inheritdoc CMTATBaseCommon
    */
    function decimals()
        public
        view
        virtual
        override(ERC20Upgradeable, CMTATBaseCommon)
        returns (uint8)
    {
        return CMTATBaseCommon.decimals();
    }


    /**
    * @inheritdoc CMTATBaseCommon
    */
    function name() public view virtual override(ERC20Upgradeable, CMTATBaseCommon)  returns (string memory) {
        return CMTATBaseCommon.name();
    }

    /**
    * @inheritdoc CMTATBaseCommon
    */
    function symbol() public view virtual override(ERC20Upgradeable, CMTATBaseCommon) returns (string memory) {
        return CMTATBaseCommon.symbol();
    }

    function supportsInterface(bytes4 _interfaceId) public view virtual override(CMTATBaseERC1404, ERC20CrossChainModule) returns (bool) {
        return  ERC20CrossChainModule.supportsInterface(_interfaceId)|| CMTATBaseERC1404.supportsInterface( _interfaceId);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ==== Mint and Burn Operations ==== */
    /**
    * @dev Check if the mint is valid
    * @inheritdoc ERC20MintModuleInternal
    */
    function _mintOverride(address account, uint256 value) internal virtual override(CMTATBaseCommon, ERC20MintModuleInternal) {
       // _checkTransferred is called by _mintOverride
        CMTATBaseCommon._mintOverride(account, value);
    }

    /**
    * @dev Check if the burn is valid
    * @inheritdoc ERC20BurnModuleInternal
    */
    function _burnOverride(address account, uint256 value) internal virtual override(CMTATBaseCommon, ERC20BurnModuleInternal) {
        // _checkTransferred is called by _burnOverride
        CMTATBaseCommon._burnOverride(account, value);
    }

    /**
    * @dev Check if a minter transfer is valid
    * @inheritdoc ERC20MintModuleInternal
    */
    function _minterTransferOverride(address from, address to, uint256 value) internal virtual override(CMTATBaseCommon, ERC20MintModuleInternal) {
        // _checkTransferred is called by _minterTransferOverride
        CMTATBaseCommon._minterTransferOverride(from, to, value);
    }

    /* ==== Access Control ==== */

    /** 
    * @custom:access-control
    * - the caller must have the `DEFAULT_ADMIN_ROLE`.
    */
    function _authorizeCCIPSetAdmin() internal virtual override(CCIPModule) onlyRole(DEFAULT_ADMIN_ROLE) {}

    /** 
    * @dev 
    * A cross-chain bridge could call the OpenZeppelin function `renounceRole` to lose their privileges (CROSS_CHAIN_ROLE)
    * While it is not intended,this has no other effect than depriving the bridge of burn/mint tokens
    * An attacker could use this to disrupt minting/burning if they can get the bridge to execute calls. 
    * However, in this case, the bridge should still be considered compromised and not used again.
    * @custom:access-control
    * - the caller must have the `CROSS_CHAIN_ROLE`.
    */
    function _checkTokenBridge(address caller) internal virtual override(ERC20CrossChainModule) whenNotPaused {
        AccessControlUpgradeable._checkRole(CROSS_CHAIN_ROLE, caller); 
    }

    /** 
    * @custom:access-control
    * - the caller must have the `BURNER_FROM_ROLE`.
    * - We don't allow token holder to burn their own tokens if they don't have this role.
    */
    function _authorizeBurnFrom() internal virtual override(ERC20CrossChainModule) onlyRole(BURNER_FROM_ROLE) whenNotPaused{}

    /**
    * @custom:access-control
    * - the caller must have the `BURNER_SELF_ROLE`.
    * - We don't allow token holder to burn their own tokens if they don't have this role.
    */
    function _authorizeSelfBurn() internal virtual override(ERC20CrossChainModule) onlyRole(BURNER_SELF_ROLE) whenNotPaused{}

}


// File contracts/interfaces/engine/IDebtEngine.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

/*
* @dev minimum interface to define a DebtEngine
*/
interface IDebtEngine is ICMTATDebt, ICMTATCreditEvents {
    // nothing more
}


// File contracts/interfaces/modules/IDebtEngineModule.sol

// Original license: SPDX_License_Identifier: MPL-2.0


pragma solidity ^0.8.24;
/**
* @notice interface to represent DebtEngineModule (debt information and credit events.)
*/
interface IDebtEngineModule is ICMTATDebt, ICMTATCreditEvents {
        /* ============ Events ============ */
    /**
    * @notice Emitted when a new DebtEngine is set.
    * @dev Indicates that the contract will delegate debt logic to a new external engine.
    * @param newDebtEngine The address of the new debt engine contract.
    */
    event DebtEngine(IDebtEngine indexed newDebtEngine);

     /* ============ Error ============ */
    error CMTAT_DebtEngineModule_SameValue();

       /* ============ Functions ============ */
  function debtEngine() external view returns (IDebtEngine debtEngine_) ;

  function setDebtEngine(
        IDebtEngine debtEngine_
    ) external;
}


// File contracts/modules/wrapper/options/DebtEngineModule.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

/* ==== Engine === */

/* ==== Module === */

/**
 * @title Debt Engine module
 * @dev 
 *
 * Retrieve debt and creditEvents information from a debtEngine (external contract)
 */
abstract contract DebtEngineModule is IDebtEngineModule {
    /* ============ State Variables ============ */
    bytes32 public constant DEBT_ENGINE_ROLE = keccak256("DEBT_ENGINE_ROLE");
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.DebtEngineModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant DebtEngineModuleStorageLocation = 0xcd6e7f8fdfee4389651c62f4d8dd0b8f0f4b97b1582a8419b0c53664203c6d00;
 
    /* ==== ERC-7201 State Variables === */
    struct DebtModuleStorage {
        IDebtEngine _debtEngine;
    }
        /* ============ Modifier ============ */
    modifier onlyDebtEngineManager {
        _authorizeDebtEngineManagement();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/  

    /* ============  State Restricted Functions ============ */
    /**
    * @notice Sets a new external DebtEngine contract to delegate debt logic.
    * @dev Only callable by accounts with the `DEBT_ROLE`.
    * Emits a {DebtEngine} event upon successful update.
    * @param debtEngine_ The address of the new DebtEngine contract.
    * @custom:access-control
    * - the caller must have the `DEBT_ROLE`.
    */
    function setDebtEngine(
        IDebtEngine debtEngine_
    ) public virtual override(IDebtEngineModule) onlyDebtEngineManager {
        DebtModuleStorage storage $ = _getDebtEngineModuleStorage();
        require(address($._debtEngine) != address(debtEngine_), CMTAT_DebtEngineModule_SameValue());
        _setDebtEngine($, debtEngine_);
    }

    /* ============ View functions ============ */
    /**
    * @notice Returns the current credit events information.
    * @dev Delegates to the external DebtEngine if set; otherwise returns the base implementation from DebtModule.
    * @return creditEvents_ The current credit events structure.
    * @inheritdoc ICMTATCreditEvents
    */
    function creditEvents() public view virtual override(ICMTATCreditEvents) returns(CreditEvents memory creditEvents_){
        DebtModuleStorage storage $ = _getDebtEngineModuleStorage();
        if(address($._debtEngine) != address(0)){
            creditEvents_ =  $._debtEngine.creditEvents();
        }
    }

    /**
    * @notice Returns the current debt information.
    * @dev Delegates to the external DebtEngine if set; otherwise returns the base implementation from DebtModule.
    * @return debtInformation_ The current debt data structure.
    * @inheritdoc ICMTATDebt
    */
    function debt() public view virtual override(ICMTATDebt) returns(DebtInformation memory debtInformation_){
        DebtModuleStorage storage $ = _getDebtEngineModuleStorage();
        if(address($._debtEngine) != address(0)){
            debtInformation_ =  $._debtEngine.debt();
        } 
    }

    /**
    * @notice Returns the address of the currently active DebtEngine.
    * @return debtEngine_ The contract address of the debt engine in use.
    */
    function debtEngine() public view virtual override(IDebtEngineModule) returns (IDebtEngine debtEngine_) {
        DebtModuleStorage storage $ = _getDebtEngineModuleStorage();
        return $._debtEngine;
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _setDebtEngine(
        DebtModuleStorage storage $, IDebtEngine debtEngine_
    ) internal {
        $._debtEngine = debtEngine_;
        emit DebtEngine(debtEngine_);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ==== Access Control ==== */
    function _authorizeDebtEngineManagement() internal virtual;
    /* ============ ERC-7201 ============ */
    function _getDebtEngineModuleStorage() internal pure returns (DebtModuleStorage storage $) {
        assembly {
            $.slot := DebtEngineModuleStorageLocation
        }
    }
}


// File contracts/modules/6_CMTATBaseDebtEngine.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

/* ==== OpenZeppelin === */

/* ==== Module === */




/**
* @title Extend CMTAT Base with DebtEngine module and snapshot engine support
*/
abstract contract CMTATBaseDebtEngine is DebtEngineModule, CMTATBaseERC20CrossChain, CMTATBaseSnapshot {

    /*//////////////////////////////////////////////////////////////
                  ERC-20 / CMTATBaseSnapshot disambiguation
    //////////////////////////////////////////////////////////////*/

    function _update(address from, address to, uint256 amount)
        internal virtual override(ERC20Upgradeable, CMTATBaseSnapshot)
    {
        CMTATBaseSnapshot._update(from, to, amount);
    }

    function transfer(address to, uint256 value)
        public virtual override(ERC20Upgradeable, CMTATBaseERC20CrossChain) returns (bool)
    {
        return CMTATBaseERC20CrossChain.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value)
        public virtual override(ERC20Upgradeable, CMTATBaseERC20CrossChain) returns (bool)
    {
        return CMTATBaseERC20CrossChain.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value)
        public virtual override(ERC20Upgradeable, CMTATBaseERC20CrossChain) returns (bool)
    {
        return CMTATBaseERC20CrossChain.approve(spender, value);
    }

    function decimals()
        public view virtual override(ERC20Upgradeable, CMTATBaseERC20CrossChain) returns (uint8)
    {
        return CMTATBaseERC20CrossChain.decimals();
    }

    function name()
        public view virtual override(ERC20Upgradeable, CMTATBaseERC20CrossChain) returns (string memory)
    {
        return CMTATBaseERC20CrossChain.name();
    }

    function symbol()
        public view virtual override(ERC20Upgradeable, CMTATBaseERC20CrossChain) returns (string memory)
    {
        return CMTATBaseERC20CrossChain.symbol();
    }

    /*//////////////////////////////////////////////////////////////
                        Access Control
    //////////////////////////////////////////////////////////////*/

    function _authorizeDebtEngineManagement() internal virtual override(DebtEngineModule) onlyRole(DEBT_ENGINE_ROLE) {}

    function _authorizeSnapshots() internal virtual override(SnapshotEngineModule) onlyRole(SNAPSHOOTER_ROLE) {}
}


// File contracts/deployment/debtEngine/CMTATStandaloneDebtEngine.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;


/**
* @title CMTAT version for a standalone deployment (without proxy)
*/
contract CMTATStandaloneDebtEngine is CMTATBaseDebtEngine {
    /**
     * @notice Contract version for standalone deployment
     * @param admin address of the admin of contract (Access Control)
     * @param ERC20Attributes_ ERC20 name, symbol and decimals
     * @param extraInformationAttributes_ tokenId, terms, information
     * @param engines_ external contract
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        ICMTATConstructor.ExtraInformationAttributes memory extraInformationAttributes_,
        ICMTATConstructor.Engine memory engines_ 
    ) {
        // Initialize the contract to avoid front-running
        initialize(
            admin,
            ERC20Attributes_,
            extraInformationAttributes_,
            engines_ 
        );
    }
}
