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


// File @openzeppelin/contracts/interfaces/IERC5267.sol@v5.7.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC5267.sol)

pragma solidity >=0.4.16;

interface IERC5267 {
    /**
     * @dev MAY be emitted to signal that the domain could have changed.
     */
    event EIP712DomainChanged();

    /**
     * @dev returns the fields and values that describe the domain separator used by this contract for EIP-712
     * signature.
     */
    function eip712Domain()
        external
        view
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        );
}


// File @openzeppelin/contracts/utils/math/SafeCast.sol@v5.7.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.6.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.20;

/**
 * @dev Wrappers over Solidity's uintXX/intXX/bool casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeCast {
    /**
     * @dev Value doesn't fit in a uint of `bits` size.
     */
    error SafeCastOverflowedUintDowncast(uint8 bits, uint256 value);

    /**
     * @dev An int value doesn't fit in a uint of `bits` size.
     */
    error SafeCastOverflowedIntToUint(int256 value);

    /**
     * @dev Value doesn't fit in an int of `bits` size.
     */
    error SafeCastOverflowedIntDowncast(uint8 bits, int256 value);

    /**
     * @dev A uint value doesn't fit in an int of `bits` size.
     */
    error SafeCastOverflowedUintToInt(uint256 value);

    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        if (value > type(uint248).max) {
            revert SafeCastOverflowedUintDowncast(248, value);
        }
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        if (value > type(uint240).max) {
            revert SafeCastOverflowedUintDowncast(240, value);
        }
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        if (value > type(uint232).max) {
            revert SafeCastOverflowedUintDowncast(232, value);
        }
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        if (value > type(uint224).max) {
            revert SafeCastOverflowedUintDowncast(224, value);
        }
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        if (value > type(uint216).max) {
            revert SafeCastOverflowedUintDowncast(216, value);
        }
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        if (value > type(uint208).max) {
            revert SafeCastOverflowedUintDowncast(208, value);
        }
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        if (value > type(uint200).max) {
            revert SafeCastOverflowedUintDowncast(200, value);
        }
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        if (value > type(uint192).max) {
            revert SafeCastOverflowedUintDowncast(192, value);
        }
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        if (value > type(uint184).max) {
            revert SafeCastOverflowedUintDowncast(184, value);
        }
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        if (value > type(uint176).max) {
            revert SafeCastOverflowedUintDowncast(176, value);
        }
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        if (value > type(uint168).max) {
            revert SafeCastOverflowedUintDowncast(168, value);
        }
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        if (value > type(uint160).max) {
            revert SafeCastOverflowedUintDowncast(160, value);
        }
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        if (value > type(uint152).max) {
            revert SafeCastOverflowedUintDowncast(152, value);
        }
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        if (value > type(uint144).max) {
            revert SafeCastOverflowedUintDowncast(144, value);
        }
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        if (value > type(uint136).max) {
            revert SafeCastOverflowedUintDowncast(136, value);
        }
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        if (value > type(uint128).max) {
            revert SafeCastOverflowedUintDowncast(128, value);
        }
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        if (value > type(uint120).max) {
            revert SafeCastOverflowedUintDowncast(120, value);
        }
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        if (value > type(uint112).max) {
            revert SafeCastOverflowedUintDowncast(112, value);
        }
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        if (value > type(uint104).max) {
            revert SafeCastOverflowedUintDowncast(104, value);
        }
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        if (value > type(uint96).max) {
            revert SafeCastOverflowedUintDowncast(96, value);
        }
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        if (value > type(uint88).max) {
            revert SafeCastOverflowedUintDowncast(88, value);
        }
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        if (value > type(uint80).max) {
            revert SafeCastOverflowedUintDowncast(80, value);
        }
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        if (value > type(uint72).max) {
            revert SafeCastOverflowedUintDowncast(72, value);
        }
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        if (value > type(uint64).max) {
            revert SafeCastOverflowedUintDowncast(64, value);
        }
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        if (value > type(uint56).max) {
            revert SafeCastOverflowedUintDowncast(56, value);
        }
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        if (value > type(uint48).max) {
            revert SafeCastOverflowedUintDowncast(48, value);
        }
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        if (value > type(uint40).max) {
            revert SafeCastOverflowedUintDowncast(40, value);
        }
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        if (value > type(uint32).max) {
            revert SafeCastOverflowedUintDowncast(32, value);
        }
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        if (value > type(uint24).max) {
            revert SafeCastOverflowedUintDowncast(24, value);
        }
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        if (value > type(uint16).max) {
            revert SafeCastOverflowedUintDowncast(16, value);
        }
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        if (value > type(uint8).max) {
            revert SafeCastOverflowedUintDowncast(8, value);
        }
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        if (value < 0) {
            revert SafeCastOverflowedIntToUint(value);
        }
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     */
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(248, value);
        }
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     */
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(240, value);
        }
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     */
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(232, value);
        }
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(224, value);
        }
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     */
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(216, value);
        }
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     */
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(208, value);
        }
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     */
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(200, value);
        }
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     */
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(192, value);
        }
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     */
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(184, value);
        }
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     */
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(176, value);
        }
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     */
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(168, value);
        }
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     */
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(160, value);
        }
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     */
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(152, value);
        }
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     */
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(144, value);
        }
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     */
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(136, value);
        }
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(128, value);
        }
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     */
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(120, value);
        }
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     */
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(112, value);
        }
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     */
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(104, value);
        }
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(96, value);
        }
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     */
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(88, value);
        }
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     */
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(80, value);
        }
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     */
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(72, value);
        }
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(64, value);
        }
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     */
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(56, value);
        }
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     */
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(48, value);
        }
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     */
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(40, value);
        }
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(32, value);
        }
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     */
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(24, value);
        }
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(16, value);
        }
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     */
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(8, value);
        }
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        if (value > uint256(type(int256).max)) {
            revert SafeCastOverflowedUintToInt(value);
        }
        return int256(value);
    }

    /**
     * @dev Cast a boolean (false or true) to a uint256 (0 or 1) with no jump.
     */
    function toUint(bool b) internal pure returns (uint256 u) {
        assembly ("memory-safe") {
            u := iszero(iszero(b))
        }
    }
}


// File @openzeppelin/contracts/utils/Panic.sol@v5.7.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/Panic.sol)

pragma solidity ^0.8.20;

/**
 * @dev Helper library for emitting standardized panic codes.
 *
 * ```solidity
 * contract Example {
 *      using Panic for uint256;
 *
 *      // Use any of the declared internal constants
 *      function foo() { Panic.GENERIC.panic(); }
 *
 *      // Alternatively
 *      function foo() { Panic.panic(Panic.GENERIC); }
 * }
 * ```
 *
 * Follows the list from https://github.com/ethereum/solidity/blob/v0.8.24/libsolutil/ErrorCodes.h[libsolutil].
 *
 * _Available since v5.1._
 */
// slither-disable-next-line unused-state
library Panic {
    /// @dev generic / unspecified error
    uint256 internal constant GENERIC = 0x00;
    /// @dev used by the assert() builtin
    uint256 internal constant ASSERT = 0x01;
    /// @dev arithmetic underflow or overflow
    uint256 internal constant UNDER_OVERFLOW = 0x11;
    /// @dev division or modulo by zero
    uint256 internal constant DIVISION_BY_ZERO = 0x12;
    /// @dev enum conversion error
    uint256 internal constant ENUM_CONVERSION_ERROR = 0x21;
    /// @dev invalid encoding in storage
    uint256 internal constant STORAGE_ENCODING_ERROR = 0x22;
    /// @dev empty array pop
    uint256 internal constant EMPTY_ARRAY_POP = 0x31;
    /// @dev array out of bounds access
    uint256 internal constant ARRAY_OUT_OF_BOUNDS = 0x32;
    /// @dev resource error (too large allocation or too large array)
    uint256 internal constant RESOURCE_ERROR = 0x41;
    /// @dev calling invalid internal function
    uint256 internal constant INVALID_INTERNAL_FUNCTION = 0x51;

    /// @dev Reverts with a panic code. Recommended to use with
    /// the internal constants with predefined codes.
    function panic(uint256 code) internal pure {
        assembly ("memory-safe") {
            mstore(0x00, 0x4e487b71)
            mstore(0x20, code)
            revert(0x1c, 0x24)
        }
    }
}


// File @openzeppelin/contracts/utils/math/Math.sol@v5.7.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.6.0) (utils/math/Math.sol)

pragma solidity ^0.8.20;


/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Return the 512-bit addition of two uint256.
     *
     * The result is stored in two 256 variables such that sum = high * 2²⁵⁶ + low.
     */
    function add512(uint256 a, uint256 b) internal pure returns (uint256 high, uint256 low) {
        assembly ("memory-safe") {
            low := add(a, b)
            high := lt(low, a)
        }
    }

    /**
     * @dev Return the 512-bit multiplication of two uint256.
     *
     * The result is stored in two 256 variables such that product = high * 2²⁵⁶ + low.
     */
    function mul512(uint256 a, uint256 b) internal pure returns (uint256 high, uint256 low) {
        // 512-bit multiply [high low] = x * y. Compute the product mod 2²⁵⁶ and mod 2²⁵⁶ - 1, then use
        // the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
        // variables such that product = high * 2²⁵⁶ + low.
        assembly ("memory-safe") {
            let mm := mulmod(a, b, not(0))
            low := mul(a, b)
            high := sub(sub(mm, low), lt(mm, low))
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, with a success flag (no overflow).
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            uint256 c = a + b;
            success = c >= a;
            result = c * SafeCast.toUint(success);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with a success flag (no overflow).
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            uint256 c = a - b;
            success = c <= a;
            result = c * SafeCast.toUint(success);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with a success flag (no overflow).
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            uint256 c = a * b;
            assembly ("memory-safe") {
                // Only true when the multiplication doesn't overflow
                // (c / a == b) || (a == 0)
                success := or(eq(div(c, a), b), iszero(a))
            }
            // equivalent to: success ? c : 0
            result = c * SafeCast.toUint(success);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a success flag (no division by zero).
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            success = b > 0;
            assembly ("memory-safe") {
                // The `DIV` opcode returns zero when the denominator is 0.
                result := div(a, b)
            }
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a success flag (no division by zero).
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            success = b > 0;
            assembly ("memory-safe") {
                // The `MOD` opcode returns zero when the denominator is 0.
                result := mod(a, b)
            }
        }
    }

    /**
     * @dev Unsigned saturating addition, bounds to `2²⁵⁶ - 1` instead of overflowing.
     */
    function saturatingAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        (bool success, uint256 result) = tryAdd(a, b);
        return ternary(success, result, type(uint256).max);
    }

    /**
     * @dev Unsigned saturating subtraction, bounds to zero instead of overflowing.
     */
    function saturatingSub(uint256 a, uint256 b) internal pure returns (uint256) {
        (, uint256 result) = trySub(a, b);
        return result;
    }

    /**
     * @dev Unsigned saturating multiplication, bounds to `2²⁵⁶ - 1` instead of overflowing.
     */
    function saturatingMul(uint256 a, uint256 b) internal pure returns (uint256) {
        (bool success, uint256 result) = tryMul(a, b);
        return ternary(success, result, type(uint256).max);
    }

    /**
     * @dev Branchless ternary evaluation for `condition ? a : b`. Gas costs are constant.
     *
     * IMPORTANT: This function may reduce bytecode size and consume less gas when used standalone.
     * However, the compiler may optimize Solidity ternary operations (i.e. `condition ? a : b`) to only compute
     * one branch when needed, making this function more expensive.
     */
    function ternary(bool condition, uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            // branchless ternary works because:
            // b ^ (a ^ b) == a
            // b ^ 0 == b
            return b ^ ((a ^ b) * SafeCast.toUint(condition));
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return ternary(a > b, a, b);
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return ternary(a < b, a, b);
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            // (a + b) / 2 can overflow.
            return (a & b) + (a ^ b) / 2;
        }
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }

        // The following calculation ensures accurate ceiling division without overflow.
        // Since a is non-zero, (a - 1) / b will not overflow.
        // The largest possible result occurs when (a - 1) / b is type(uint256).max,
        // but the largest value we can obtain is type(uint256).max - 1, which happens
        // when a = type(uint256).max and b = 1.
        unchecked {
            return SafeCast.toUint(a > 0) * ((a - 1) / b + 1);
        }
    }

    /**
     * @dev Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     *
     * Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            (uint256 high, uint256 low) = mul512(x, y);

            // Handle non-overflow cases, 256 by 256 division.
            if (high == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return low / denominator;
            }

            // Make sure the result is less than 2²⁵⁶. Also prevents denominator == 0.
            if (denominator <= high) {
                Panic.panic(ternary(denominator == 0, Panic.DIVISION_BY_ZERO, Panic.UNDER_OVERFLOW));
            }

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [high low].
            uint256 remainder;
            assembly ("memory-safe") {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                high := sub(high, gt(remainder, low))
                low := sub(low, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
            assembly ("memory-safe") {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [high low] by twos.
                low := div(low, twos)

                // Flip twos such that it is 2²⁵⁶ / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from high into low.
            low |= high * twos;

            // Invert denominator mod 2²⁵⁶. Now that denominator is an odd number, it has an inverse modulo 2²⁵⁶ such
            // that denominator * inv ≡ 1 mod 2²⁵⁶. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv ≡ 1 mod 2⁴.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2⁸
            inverse *= 2 - denominator * inverse; // inverse mod 2¹⁶
            inverse *= 2 - denominator * inverse; // inverse mod 2³²
            inverse *= 2 - denominator * inverse; // inverse mod 2⁶⁴
            inverse *= 2 - denominator * inverse; // inverse mod 2¹²⁸
            inverse *= 2 - denominator * inverse; // inverse mod 2²⁵⁶

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2²⁵⁶. Since the preconditions guarantee that the outcome is
            // less than 2²⁵⁶, this is the final result. We don't need to compute the high bits of the result and high
            // is no longer required.
            result = low * inverse;
            return result;
        }
    }

    /**
     * @dev Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        return mulDiv(x, y, denominator) + SafeCast.toUint(unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0);
    }

    /**
     * @dev Calculates floor(x * y >> n) with full precision. Throws if result overflows a uint256.
     */
    function mulShr(uint256 x, uint256 y, uint8 n) internal pure returns (uint256 result) {
        unchecked {
            (uint256 high, uint256 low) = mul512(x, y);
            if (high >= 1 << n) {
                Panic.panic(Panic.UNDER_OVERFLOW);
            }
            return (high << (256 - n)) | (low >> n);
        }
    }

    /**
     * @dev Calculates x * y >> n with full precision, following the selected rounding direction.
     */
    function mulShr(uint256 x, uint256 y, uint8 n, Rounding rounding) internal pure returns (uint256) {
        return mulShr(x, y, n) + SafeCast.toUint(unsignedRoundsUp(rounding) && mulmod(x, y, 1 << n) > 0);
    }

    /**
     * @dev Calculate the modular multiplicative inverse of a number in Z/nZ.
     *
     * If n is a prime, then Z/nZ is a field. In that case all elements are inversible, except 0.
     * If n is not a prime, then Z/nZ is not a field, and some elements might not be inversible.
     *
     * If the input value is not inversible, 0 is returned.
     *
     * NOTE: If you know for sure that n is (big) a prime, it may be cheaper to use Fermat's little theorem and get the
     * inverse using `Math.modExp(a, n - 2, n)`. See {invModPrime}.
     */
    function invMod(uint256 a, uint256 n) internal pure returns (uint256) {
        unchecked {
            if (n == 0) return 0;

            // The inverse modulo is calculated using the Extended Euclidean Algorithm (iterative version)
            // Used to compute integers x and y such that: ax + ny = gcd(a, n).
            // When the gcd is 1, then the inverse of a modulo n exists and it's x.
            // ax + ny = 1
            // ax = 1 + (-y)n
            // ax ≡ 1 (mod n) # x is the inverse of a modulo n

            // If the remainder is 0 the gcd is n right away.
            uint256 remainder = a % n;
            uint256 gcd = n;

            // Therefore the initial coefficients are:
            // ax + ny = gcd(a, n) = n
            // 0a + 1n = n
            int256 x = 0;
            int256 y = 1;

            while (remainder != 0) {
                uint256 quotient = gcd / remainder;

                (gcd, remainder) = (
                    // The old remainder is the next gcd to try.
                    remainder,
                    // Compute the next remainder.
                    // Can't overflow given that (a % gcd) * (gcd // (a % gcd)) <= gcd
                    // where gcd is at most n (capped to type(uint256).max)
                    gcd - remainder * quotient
                );

                (x, y) = (
                    // Increment the coefficient of a.
                    y,
                    // Decrement the coefficient of n.
                    // Can overflow, but the result is casted to uint256 so that the
                    // next value of y is "wrapped around" to a value between 0 and n - 1.
                    x - y * int256(quotient)
                );
            }

            if (gcd != 1) return 0; // No inverse exists.
            return ternary(x < 0, n - uint256(-x), uint256(x)); // Wrap the result if it's negative.
        }
    }

    /**
     * @dev Variant of {invMod}. More efficient, but only works if `p` is known to be a prime greater than `2`.
     *
     * From https://en.wikipedia.org/wiki/Fermat%27s_little_theorem[Fermat's little theorem], we know that if p is
     * prime, then `a**(p-1) ≡ 1 mod p`. As a consequence, we have `a * a**(p-2) ≡ 1 mod p`, which means that
     * `a**(p-2)` is the modular multiplicative inverse of a in Fp.
     *
     * NOTE: this function does NOT check that `p` is a prime greater than `2`.
     */
    function invModPrime(uint256 a, uint256 p) internal view returns (uint256) {
        unchecked {
            return Math.modExp(a, p - 2, p);
        }
    }

    /**
     * @dev Returns the modular exponentiation of the specified base, exponent and modulus (b ** e % m)
     *
     * Requirements:
     * - modulus can't be zero
     * - underlying staticcall to precompile must succeed
     *
     * IMPORTANT: The result is only valid if the underlying call succeeds. When using this function, make
     * sure the chain you're using it on supports the precompiled contract for modular exponentiation
     * at address 0x05 as specified in https://eips.ethereum.org/EIPS/eip-198[EIP-198]. Otherwise,
     * the underlying function will succeed given the lack of a revert, but the result may be incorrectly
     * interpreted as 0.
     */
    function modExp(uint256 b, uint256 e, uint256 m) internal view returns (uint256) {
        (bool success, uint256 result) = tryModExp(b, e, m);
        if (!success) {
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }
        return result;
    }

    /**
     * @dev Returns the modular exponentiation of the specified base, exponent and modulus (b ** e % m).
     * It includes a success flag indicating if the operation succeeded. Operation will be marked as failed if trying
     * to operate modulo 0 or if the underlying precompile reverted.
     *
     * IMPORTANT: The result is only valid if the success flag is true. When using this function, make sure the chain
     * you're using it on supports the precompiled contract for modular exponentiation at address 0x05 as specified in
     * https://eips.ethereum.org/EIPS/eip-198[EIP-198]. Otherwise, the underlying function will succeed given the lack
     * of a revert, but the result may be incorrectly interpreted as 0.
     */
    function tryModExp(uint256 b, uint256 e, uint256 m) internal view returns (bool success, uint256 result) {
        if (m == 0) return (false, 0);
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            // | Offset    | Content    | Content (Hex)                                                      |
            // |-----------|------------|--------------------------------------------------------------------|
            // | 0x00:0x1f | size of b  | 0x0000000000000000000000000000000000000000000000000000000000000020 |
            // | 0x20:0x3f | size of e  | 0x0000000000000000000000000000000000000000000000000000000000000020 |
            // | 0x40:0x5f | size of m  | 0x0000000000000000000000000000000000000000000000000000000000000020 |
            // | 0x60:0x7f | value of b | 0x<.............................................................b> |
            // | 0x80:0x9f | value of e | 0x<.............................................................e> |
            // | 0xa0:0xbf | value of m | 0x<.............................................................m> |
            mstore(ptr, 0x20)
            mstore(add(ptr, 0x20), 0x20)
            mstore(add(ptr, 0x40), 0x20)
            mstore(add(ptr, 0x60), b)
            mstore(add(ptr, 0x80), e)
            mstore(add(ptr, 0xa0), m)

            // Given the result < m, it's guaranteed to fit in 32 bytes,
            // so we can use the memory scratch space located at offset 0.
            success := staticcall(gas(), 0x05, ptr, 0xc0, 0x00, 0x20)
            result := mload(0x00)
        }
    }

    /**
     * @dev Variant of {modExp} that supports inputs of arbitrary length.
     */
    function modExp(bytes memory b, bytes memory e, bytes memory m) internal view returns (bytes memory) {
        (bool success, bytes memory result) = tryModExp(b, e, m);
        if (!success) {
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }
        return result;
    }

    /**
     * @dev Variant of {tryModExp} that supports inputs of arbitrary length.
     */
    function tryModExp(
        bytes memory b,
        bytes memory e,
        bytes memory m
    ) internal view returns (bool success, bytes memory result) {
        if (_zeroBytes(m)) return (false, new bytes(0));

        uint256 mLen = m.length;

        // Encode call args in result and move the free memory pointer
        result = abi.encodePacked(b.length, e.length, mLen, b, e, m);

        assembly ("memory-safe") {
            let dataPtr := add(result, 0x20)
            // Write result on top of args to avoid allocating extra memory.
            success := staticcall(gas(), 0x05, dataPtr, mload(result), dataPtr, mLen)
            // Overwrite the length.
            // result.length > returndatasize() is guaranteed because returndatasize() == m.length
            mstore(result, mLen)
            // Set the memory pointer after the returned data.
            mstore(0x40, add(dataPtr, mLen))
        }
    }

    /**
     * @dev Returns whether the provided byte array is zero.
     */
    function _zeroBytes(bytes memory buffer) private pure returns (bool) {
        uint256 chunk;
        for (uint256 i = 0; i < buffer.length; i += 0x20) {
            // See _unsafeReadBytesOffset from utils/Bytes.sol
            assembly ("memory-safe") {
                chunk := mload(add(add(buffer, 0x20), i))
            }
            if (chunk >> (8 * saturatingSub(i + 0x20, buffer.length)) != 0) {
                return false;
            }
        }
        return true;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * This method is based on Newton's method for computing square roots; the algorithm is restricted to only
     * using integer operations.
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        unchecked {
            // Take care of easy edge cases when a == 0 or a == 1
            if (a <= 1) {
                return a;
            }

            // In this function, we use Newton's method to get a root of `f(x) := x² - a`. It involves building a
            // sequence x_n that converges toward sqrt(a). For each iteration x_n, we also define the error between
            // the current value as `ε_n = | x_n - sqrt(a) |`.
            //
            // For our first estimation, we consider `e` the smallest power of 2 which is bigger than the square root
            // of the target. (i.e. `2**(e-1) ≤ sqrt(a) < 2**e`). We know that `e ≤ 128` because `(2¹²⁸)² = 2²⁵⁶` is
            // bigger than any uint256.
            //
            // By noticing that
            // `2**(e-1) ≤ sqrt(a) < 2**e → (2**(e-1))² ≤ a < (2**e)² → 2**(2*e-2) ≤ a < 2**(2*e)`
            // we can deduce that `e - 1` is `log2(a) / 2`. We can thus compute `x_n = 2**(e-1)` using a method similar
            // to the msb function.
            uint256 aa = a;
            uint256 xn = 1;

            if (aa >= (1 << 128)) {
                aa >>= 128;
                xn <<= 64;
            }
            if (aa >= (1 << 64)) {
                aa >>= 64;
                xn <<= 32;
            }
            if (aa >= (1 << 32)) {
                aa >>= 32;
                xn <<= 16;
            }
            if (aa >= (1 << 16)) {
                aa >>= 16;
                xn <<= 8;
            }
            if (aa >= (1 << 8)) {
                aa >>= 8;
                xn <<= 4;
            }
            if (aa >= (1 << 4)) {
                aa >>= 4;
                xn <<= 2;
            }
            if (aa >= (1 << 2)) {
                xn <<= 1;
            }

            // We now have x_n such that `x_n = 2**(e-1) ≤ sqrt(a) < 2**e = 2 * x_n`. This implies ε_n ≤ 2**(e-1).
            //
            // We can refine our estimation by noticing that the middle of that interval minimizes the error.
            // If we move x_n to equal 2**(e-1) + 2**(e-2), then we reduce the error to ε_n ≤ 2**(e-2).
            // This is going to be our x_0 (and ε_0)
            xn = (3 * xn) >> 1; // ε_0 := | x_0 - sqrt(a) | ≤ 2**(e-2)

            // From here, Newton's method give us:
            // x_{n+1} = (x_n + a / x_n) / 2
            //
            // One should note that:
            // x_{n+1}² - a = ((x_n + a / x_n) / 2)² - a
            //              = ((x_n² + a) / (2 * x_n))² - a
            //              = (x_n⁴ + 2 * a * x_n² + a²) / (4 * x_n²) - a
            //              = (x_n⁴ + 2 * a * x_n² + a² - 4 * a * x_n²) / (4 * x_n²)
            //              = (x_n⁴ - 2 * a * x_n² + a²) / (4 * x_n²)
            //              = (x_n² - a)² / (2 * x_n)²
            //              = ((x_n² - a) / (2 * x_n))²
            //              ≥ 0
            // Which proves that for all n ≥ 1, sqrt(a) ≤ x_n
            //
            // This gives us the proof of quadratic convergence of the sequence:
            // ε_{n+1} = | x_{n+1} - sqrt(a) |
            //         = | (x_n + a / x_n) / 2 - sqrt(a) |
            //         = | (x_n² + a - 2*x_n*sqrt(a)) / (2 * x_n) |
            //         = | (x_n - sqrt(a))² / (2 * x_n) |
            //         = | ε_n² / (2 * x_n) |
            //         = ε_n² / | (2 * x_n) |
            //
            // For the first iteration, we have a special case where x_0 is known:
            // ε_1 = ε_0² / | (2 * x_0) |
            //     ≤ (2**(e-2))² / (2 * (2**(e-1) + 2**(e-2)))
            //     ≤ 2**(2*e-4) / (3 * 2**(e-1))
            //     ≤ 2**(e-3) / 3
            //     ≤ 2**(e-3-log2(3))
            //     ≤ 2**(e-4.5)
            //
            // For the following iterations, we use the fact that, 2**(e-1) ≤ sqrt(a) ≤ x_n:
            // ε_{n+1} = ε_n² / | (2 * x_n) |
            //         ≤ (2**(e-k))² / (2 * 2**(e-1))
            //         ≤ 2**(2*e-2*k) / 2**e
            //         ≤ 2**(e-2*k)
            xn = (xn + a / xn) >> 1; // ε_1 := | x_1 - sqrt(a) | ≤ 2**(e-4.5)  -- special case, see above
            xn = (xn + a / xn) >> 1; // ε_2 := | x_2 - sqrt(a) | ≤ 2**(e-9)    -- general case with k = 4.5
            xn = (xn + a / xn) >> 1; // ε_3 := | x_3 - sqrt(a) | ≤ 2**(e-18)   -- general case with k = 9
            xn = (xn + a / xn) >> 1; // ε_4 := | x_4 - sqrt(a) | ≤ 2**(e-36)   -- general case with k = 18
            xn = (xn + a / xn) >> 1; // ε_5 := | x_5 - sqrt(a) | ≤ 2**(e-72)   -- general case with k = 36
            xn = (xn + a / xn) >> 1; // ε_6 := | x_6 - sqrt(a) | ≤ 2**(e-144)  -- general case with k = 72

            // Because e ≤ 128 (as discussed during the first estimation phase), we know have reached a precision
            // ε_6 ≤ 2**(e-144) < 1. Given we're operating on integers, then we can ensure that xn is now either
            // sqrt(a) or sqrt(a) + 1.
            return xn - SafeCast.toUint(xn > a / xn);
        }
    }

    /**
     * @dev Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && result * result < a);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log2(uint256 x) internal pure returns (uint256 r) {
        // If value has upper 128 bits set, log2 result is at least 128
        r = SafeCast.toUint(x > 0xffffffffffffffffffffffffffffffff) << 7;
        // If upper 64 bits of 128-bit half set, add 64 to result
        r |= SafeCast.toUint((x >> r) > 0xffffffffffffffff) << 6;
        // If upper 32 bits of 64-bit half set, add 32 to result
        r |= SafeCast.toUint((x >> r) > 0xffffffff) << 5;
        // If upper 16 bits of 32-bit half set, add 16 to result
        r |= SafeCast.toUint((x >> r) > 0xffff) << 4;
        // If upper 8 bits of 16-bit half set, add 8 to result
        r |= SafeCast.toUint((x >> r) > 0xff) << 3;
        // If upper 4 bits of 8-bit half set, add 4 to result
        r |= SafeCast.toUint((x >> r) > 0xf) << 2;

        // Shifts value right by the current result and use it as an index into this lookup table:
        //
        // | x (4 bits) |  index  | table[index] = MSB position |
        // |------------|---------|-----------------------------|
        // |    0000    |    0    |        table[0] = 0         |
        // |    0001    |    1    |        table[1] = 0         |
        // |    0010    |    2    |        table[2] = 1         |
        // |    0011    |    3    |        table[3] = 1         |
        // |    0100    |    4    |        table[4] = 2         |
        // |    0101    |    5    |        table[5] = 2         |
        // |    0110    |    6    |        table[6] = 2         |
        // |    0111    |    7    |        table[7] = 2         |
        // |    1000    |    8    |        table[8] = 3         |
        // |    1001    |    9    |        table[9] = 3         |
        // |    1010    |   10    |        table[10] = 3        |
        // |    1011    |   11    |        table[11] = 3        |
        // |    1100    |   12    |        table[12] = 3        |
        // |    1101    |   13    |        table[13] = 3        |
        // |    1110    |   14    |        table[14] = 3        |
        // |    1111    |   15    |        table[15] = 3        |
        //
        // The lookup table is represented as a 32-byte value with the MSB positions for 0-15 in the first 16 bytes (most significant half).
        assembly ("memory-safe") {
            r := or(r, byte(shr(r, x), 0x0000010102020202030303030303030300000000000000000000000000000000))
        }
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && 1 << result < value);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && 10 ** result < value);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 x) internal pure returns (uint256 r) {
        // If value has upper 128 bits set, log2 result is at least 128
        r = SafeCast.toUint(x > 0xffffffffffffffffffffffffffffffff) << 7;
        // If upper 64 bits of 128-bit half set, add 64 to result
        r |= SafeCast.toUint((x >> r) > 0xffffffffffffffff) << 6;
        // If upper 32 bits of 64-bit half set, add 32 to result
        r |= SafeCast.toUint((x >> r) > 0xffffffff) << 5;
        // If upper 16 bits of 32-bit half set, add 16 to result
        r |= SafeCast.toUint((x >> r) > 0xffff) << 4;
        // Add 1 if upper 8 bits of 16-bit half set, and divide accumulated result by 8
        return (r >> 3) | SafeCast.toUint((x >> r) > 0xff);
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && 1 << (result << 3) < value);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }

    /**
     * @dev Counts the number of leading zero bits in a uint256.
     */
    function clz(uint256 x) internal pure returns (uint256) {
        return ternary(x == 0, 256, 255 - log2(x));
    }
}


// File @openzeppelin/contracts/utils/Bytes.sol@v5.7.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.7.0) (utils/Bytes.sol)

pragma solidity ^0.8.24;

/**
 * @dev Bytes operations.
 */
library Bytes {
    /**
     * @dev Forward search for `s` in `buffer`
     * * If `s` is present in the buffer, returns the index of the first instance
     * * If `s` is not present in the buffer, returns type(uint256).max
     *
     * NOTE: replicates the behavior of https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/indexOf[Javascript's `Array.indexOf`]
     */
    function indexOf(bytes memory buffer, bytes1 s) internal pure returns (uint256) {
        return indexOf(buffer, s, 0);
    }

    /**
     * @dev Forward search for `s` in `buffer` starting at position `pos`
     * * If `s` is present in the buffer (at or after `pos`), returns the index of the next instance
     * * If `s` is not present in the buffer (at or after `pos`), returns type(uint256).max
     *
     * NOTE: replicates the behavior of https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/indexOf[Javascript's `Array.indexOf`]
     */
    function indexOf(bytes memory buffer, bytes1 s, uint256 pos) internal pure returns (uint256) {
        uint256 length = buffer.length;
        for (uint256 i = pos; i < length; ++i) {
            if (bytes1(_unsafeReadBytesOffset(buffer, i)) == s) {
                return i;
            }
        }
        return type(uint256).max;
    }

    /**
     * @dev Backward search for `s` in `buffer`
     * * If `s` is present in the buffer, returns the index of the last instance
     * * If `s` is not present in the buffer, returns type(uint256).max
     *
     * NOTE: replicates the behavior of https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/lastIndexOf[Javascript's `Array.lastIndexOf`]
     */
    function lastIndexOf(bytes memory buffer, bytes1 s) internal pure returns (uint256) {
        return lastIndexOf(buffer, s, type(uint256).max);
    }

    /**
     * @dev Backward search for `s` in `buffer` starting at position `pos`
     * * If `s` is present in the buffer (at or before `pos`), returns the index of the previous instance
     * * If `s` is not present in the buffer (at or before `pos`), returns type(uint256).max
     *
     * NOTE: replicates the behavior of https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/lastIndexOf[Javascript's `Array.lastIndexOf`]
     */
    function lastIndexOf(bytes memory buffer, bytes1 s, uint256 pos) internal pure returns (uint256) {
        unchecked {
            uint256 length = buffer.length;
            for (uint256 i = Math.min(Math.saturatingAdd(pos, 1), length); i > 0; --i) {
                if (bytes1(_unsafeReadBytesOffset(buffer, i - 1)) == s) {
                    return i - 1;
                }
            }
            return type(uint256).max;
        }
    }

    /**
     * @dev Copies the content of `buffer`, from `start` (included) to the end of `buffer` into a new bytes object in
     * memory.
     *
     * NOTE: replicates the behavior of https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/slice[Javascript's `Array.slice`]
     */
    function slice(bytes memory buffer, uint256 start) internal pure returns (bytes memory) {
        return slice(buffer, start, buffer.length);
    }

    /**
     * @dev Copies the content of `buffer`, from `start` (included) to `end` (excluded) into a new bytes object in
     * memory. The `end` argument is truncated to the length of the `buffer`.
     *
     * NOTE: replicates the behavior of https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/slice[Javascript's `Array.slice`]
     */
    function slice(bytes memory buffer, uint256 start, uint256 end) internal pure returns (bytes memory) {
        // sanitize
        end = Math.min(end, buffer.length);
        start = Math.min(start, end);

        // allocate and copy
        bytes memory result = new bytes(end - start);
        assembly ("memory-safe") {
            mcopy(add(result, 0x20), add(add(buffer, 0x20), start), sub(end, start))
        }

        return result;
    }

    /**
     * @dev Moves the content of `buffer`, from `start` (included) to the end of `buffer` to the start of that buffer,
     * and shrinks the buffer length accordingly, effectively overriding the content of buffer with buffer[start:].
     *
     * NOTE: This function modifies the provided buffer in place. If you need to preserve the original buffer, use {slice} instead
     */
    function splice(bytes memory buffer, uint256 start) internal pure returns (bytes memory) {
        return splice(buffer, start, buffer.length);
    }

    /**
     * @dev Moves the content of `buffer`, from `start` (included) to `end` (excluded) to the start of that buffer,
     * and shrinks the buffer length accordingly, effectively overriding the content of buffer with buffer[start:end].
     * The `end` argument is truncated to the length of the `buffer`.
     *
     * NOTE: This function modifies the provided buffer in place. If you need to preserve the original buffer, use {slice} instead
     */
    function splice(bytes memory buffer, uint256 start, uint256 end) internal pure returns (bytes memory) {
        // sanitize
        end = Math.min(end, buffer.length);
        start = Math.min(start, end);

        // move and resize
        assembly ("memory-safe") {
            mcopy(add(buffer, 0x20), add(add(buffer, 0x20), start), sub(end, start))
            mstore(buffer, sub(end, start))
        }

        return buffer;
    }

    /**
     * @dev Replaces bytes in `buffer` starting at `pos` with all bytes from `replacement`.
     *
     * Parameters are clamped to valid ranges (i.e. `pos` is clamped to `[0, buffer.length]`).
     * If `pos >= buffer.length`, no replacement occurs and the buffer is returned unchanged.
     *
     * NOTE: This function modifies the provided buffer in place.
     */
    function replace(bytes memory buffer, uint256 pos, bytes memory replacement) internal pure returns (bytes memory) {
        return replace(buffer, pos, replacement, 0, replacement.length);
    }

    /**
     * @dev Replaces bytes in `buffer` starting at `pos` with bytes from `replacement` starting at `offset`.
     * Copies at most `length` bytes from `replacement` to `buffer`.
     *
     * Parameters are clamped to valid ranges (i.e. `pos` is clamped to `[0, buffer.length]`, `offset` is
     * clamped to `[0, replacement.length]`, and `length` is clamped to `min(length, replacement.length - offset,
     * buffer.length - pos))`. If `pos >= buffer.length` or `offset >= replacement.length`, no replacement occurs
     * and the buffer is returned unchanged.
     *
     * NOTE: This function modifies the provided buffer in place.
     */
    function replace(
        bytes memory buffer,
        uint256 pos,
        bytes memory replacement,
        uint256 offset,
        uint256 length
    ) internal pure returns (bytes memory) {
        // sanitize
        pos = Math.min(pos, buffer.length);
        offset = Math.min(offset, replacement.length);
        length = Math.min(length, Math.min(replacement.length - offset, buffer.length - pos));

        // replace
        assembly ("memory-safe") {
            mcopy(add(add(buffer, 0x20), pos), add(add(replacement, 0x20), offset), length)
        }

        return buffer;
    }

    /**
     * @dev Concatenate an array of bytes into a single bytes object.
     *
     * For fixed bytes types, we recommend using the solidity built-in `bytes.concat` or (equivalent)
     * `abi.encodePacked`.
     *
     * NOTE: this could be done in assembly with a single loop that expands starting at the FMP, but that would be
     * significantly less readable. It might be worth benchmarking the savings of the full-assembly approach.
     */
    function concat(bytes[] memory buffers) internal pure returns (bytes memory) {
        uint256 length = 0;
        for (uint256 i = 0; i < buffers.length; ++i) {
            length += buffers[i].length;
        }

        bytes memory result = new bytes(length);

        uint256 offset = 0x20;
        for (uint256 i = 0; i < buffers.length; ++i) {
            bytes memory input = buffers[i];
            assembly ("memory-safe") {
                mcopy(add(result, offset), add(input, 0x20), mload(input))
            }
            unchecked {
                offset += input.length;
            }
        }

        return result;
    }

    /**
     * @dev Split each byte in `input` into two nibbles (4 bits each)
     *
     * Example: hex"01234567" → hex"0001020304050607"
     */
    function toNibbles(bytes memory input) internal pure returns (bytes memory output) {
        assembly ("memory-safe") {
            let length := mload(input)
            output := mload(0x40)
            mstore(0x40, add(add(output, 0x20), mul(length, 2)))
            mstore(output, mul(length, 2))
            for {
                let i := 0
            } lt(i, length) {
                i := add(i, 0x10)
            } {
                let chunk := shr(128, mload(add(add(input, 0x20), i)))
                chunk := and(
                    0x0000000000000000ffffffffffffffff0000000000000000ffffffffffffffff,
                    or(shl(64, chunk), chunk)
                )
                chunk := and(
                    0x00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff,
                    or(shl(32, chunk), chunk)
                )
                chunk := and(
                    0x0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff,
                    or(shl(16, chunk), chunk)
                )
                chunk := and(
                    0x00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff,
                    or(shl(8, chunk), chunk)
                )
                chunk := and(
                    0x0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f,
                    or(shl(4, chunk), chunk)
                )
                mstore(add(add(output, 0x20), mul(i, 2)), chunk)
            }
        }
    }

    /**
     * @dev Returns true if the two byte buffers are equal.
     */
    function equal(bytes memory a, bytes memory b) internal pure returns (bool) {
        return a.length == b.length && keccak256(a) == keccak256(b);
    }

    /**
     * @dev Reverses the byte order of a bytes32 value, converting between little-endian and big-endian.
     * Inspired by https://graphics.stanford.edu/~seander/bithacks.html#ReverseParallel[Reverse Parallel]
     */
    function reverseBytes32(bytes32 value) internal pure returns (bytes32) {
        value = // swap bytes
            ((value >> 8) & 0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF) |
            ((value & 0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF) << 8);
        value = // swap 2-byte long pairs
            ((value >> 16) & 0x0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF) |
            ((value & 0x0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF) << 16);
        value = // swap 4-byte long pairs
            ((value >> 32) & 0x00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF) |
            ((value & 0x00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF) << 32);
        value = // swap 8-byte long pairs
            ((value >> 64) & 0x0000000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF) |
            ((value & 0x0000000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF) << 64);
        return (value >> 128) | (value << 128); // swap 16-byte long pairs
    }

    /// @dev Same as {reverseBytes32} but optimized for 128-bit values.
    function reverseBytes16(bytes16 value) internal pure returns (bytes16) {
        value = // swap bytes
            ((value & 0xFF00FF00FF00FF00FF00FF00FF00FF00) >> 8) | ((value & 0x00FF00FF00FF00FF00FF00FF00FF00FF) << 8);
        value = // swap 2-byte long pairs
            ((value & 0xFFFF0000FFFF0000FFFF0000FFFF0000) >> 16) | ((value & 0x0000FFFF0000FFFF0000FFFF0000FFFF) << 16);
        value = // swap 4-byte long pairs
            ((value & 0xFFFFFFFF00000000FFFFFFFF00000000) >> 32) | ((value & 0x00000000FFFFFFFF00000000FFFFFFFF) << 32);
        return (value >> 64) | (value << 64); // swap 8-byte long pairs
    }

    /// @dev Same as {reverseBytes32} but optimized for 64-bit values.
    function reverseBytes8(bytes8 value) internal pure returns (bytes8) {
        value = ((value & 0xFF00FF00FF00FF00) >> 8) | ((value & 0x00FF00FF00FF00FF) << 8); // swap bytes
        value = ((value & 0xFFFF0000FFFF0000) >> 16) | ((value & 0x0000FFFF0000FFFF) << 16); // swap 2-byte long pairs
        return (value >> 32) | (value << 32); // swap 4-byte long pairs
    }

    /// @dev Same as {reverseBytes32} but optimized for 32-bit values.
    function reverseBytes4(bytes4 value) internal pure returns (bytes4) {
        value = ((value & 0xFF00FF00) >> 8) | ((value & 0x00FF00FF) << 8); // swap bytes
        return (value >> 16) | (value << 16); // swap 2-byte long pairs
    }

    /// @dev Same as {reverseBytes32} but optimized for 16-bit values.
    function reverseBytes2(bytes2 value) internal pure returns (bytes2) {
        return (value >> 8) | (value << 8);
    }

    /**
     * @dev Counts the number of leading zero bits a bytes array. Returns `8 * buffer.length`
     * if the buffer is all zeros.
     */
    function clz(bytes memory buffer) internal pure returns (uint256) {
        for (uint256 i = 0; i < buffer.length; i += 0x20) {
            bytes32 chunk = _unsafeReadBytesOffset(buffer, i);
            if (chunk != bytes32(0)) {
                return Math.min(8 * i + Math.clz(uint256(chunk)), 8 * buffer.length);
            }
        }
        return 8 * buffer.length;
    }

    /**
     * @dev Reads a bytes32 from a bytes array without bounds checking.
     *
     * NOTE: making this function internal would mean it could be used with memory unsafe offset, and marking the
     * assembly block as such would prevent some optimizations.
     */
    function _unsafeReadBytesOffset(bytes memory buffer, uint256 offset) private pure returns (bytes32 value) {
        // This is not memory safe in the general case, but all calls to this private function are within bounds.
        assembly ("memory-safe") {
            value := mload(add(add(buffer, 0x20), offset))
        }
    }
}


// File @openzeppelin/contracts/utils/math/SignedMath.sol@v5.7.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Branchless ternary evaluation for `a ? b : c`. Gas costs are constant.
     *
     * IMPORTANT: This function may reduce bytecode size and consume less gas when used standalone.
     * However, the compiler may optimize Solidity ternary operations (i.e. `a ? b : c`) to only compute
     * one branch when needed, making this function more expensive.
     */
    function ternary(bool condition, int256 a, int256 b) internal pure returns (int256) {
        unchecked {
            // branchless ternary works because:
            // b ^ (a ^ b) == a
            // b ^ 0 == b
            return b ^ ((a ^ b) * int256(SafeCast.toUint(condition)));
        }
    }

    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return ternary(a > b, a, b);
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return ternary(a < b, a, b);
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // Formula from the "Bit Twiddling Hacks" by Sean Eron Anderson.
            // Since `n` is a signed integer, the generated bytecode will use the SAR opcode to perform the right shift,
            // taking advantage of the most significant (or "sign" bit) in two's complement representation.
            // This opcode adds new most significant bits set to the value of the previous most significant bit. As a result,
            // the mask will either be `bytes32(0)` (if n is positive) or `~bytes32(0)` (if n is negative).
            int256 mask = n >> 255;

            // A `bytes32(0)` mask leaves the input unchanged, while a `~bytes32(0)` mask complements it.
            return uint256((n + mask) ^ mask);
        }
    }
}


// File @openzeppelin/contracts/utils/Strings.sol@v5.7.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.6.0) (utils/Strings.sol)

pragma solidity ^0.8.24;




/**
 * @dev String operations.
 */
library Strings {
    using SafeCast for *;

    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;
    uint256 private constant SPECIAL_CHARS_LOOKUP =
        0xffffffff | // first 32 bits corresponding to the control characters (U+0000 to U+001F)
            (1 << 0x22) | // double quote
            (1 << 0x5c); // backslash

    /**
     * @dev The `value` string doesn't fit in the specified `length`.
     */
    error StringsInsufficientHexLength(uint256 value, uint256 length);

    /**
     * @dev The string being parsed contains characters that are not in scope of the given base.
     */
    error StringsInvalidChar();

    /**
     * @dev The string being parsed is not a properly formatted address.
     */
    error StringsInvalidAddressFormat();

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            assembly ("memory-safe") {
                ptr := add(add(buffer, 0x20), length)
            }
            while (true) {
                ptr--;
                assembly ("memory-safe") {
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toStringSigned(int256 value) internal pure returns (string memory) {
        return string.concat(value < 0 ? "-" : "", toString(SignedMath.abs(value)));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            revert StringsInsufficientHexLength(value, length);
        }
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal
     * representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its checksummed ASCII `string` hexadecimal
     * representation, according to EIP-55.
     */
    function toChecksumHexString(address addr) internal pure returns (string memory) {
        bytes memory buffer = bytes(toHexString(addr));

        // hash the hex part of buffer (skip length + 2 bytes, length 40)
        uint256 hashValue;
        assembly ("memory-safe") {
            hashValue := shr(96, keccak256(add(buffer, 0x22), 40))
        }

        for (uint256 i = 41; i > 1; --i) {
            // possible values for buffer[i] are 48 (0) to 57 (9) and 97 (a) to 102 (f)
            if (hashValue & 0xf > 7 && uint8(buffer[i]) > 96) {
                // case shift by xoring with 0x20
                buffer[i] ^= 0x20;
            }
            hashValue >>= 4;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `bytes` buffer to its ASCII `string` hexadecimal representation.
     */
    function toHexString(bytes memory input) internal pure returns (string memory) {
        unchecked {
            bytes memory buffer = new bytes(2 * input.length + 2);
            buffer[0] = "0";
            buffer[1] = "x";
            for (uint256 i = 0; i < input.length; ++i) {
                uint8 v = uint8(input[i]);
                buffer[2 * i + 2] = HEX_DIGITS[v >> 4];
                buffer[2 * i + 3] = HEX_DIGITS[v & 0xf];
            }
            return string(buffer);
        }
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return Bytes.equal(bytes(a), bytes(b));
    }

    /**
     * @dev Parse a decimal string and returns the value as a `uint256`.
     *
     * Requirements:
     * - The string must be formatted as `[0-9]*`
     * - The result must fit into an `uint256` type
     */
    function parseUint(string memory input) internal pure returns (uint256) {
        return parseUint(input, 0, bytes(input).length);
    }

    /**
     * @dev Variant of {parseUint-string} that parses a substring of `input` located between position `begin` (included) and
     * `end` (excluded).
     *
     * Requirements:
     * - The substring must be formatted as `[0-9]*`
     * - The result must fit into an `uint256` type
     */
    function parseUint(string memory input, uint256 begin, uint256 end) internal pure returns (uint256) {
        (bool success, uint256 value) = tryParseUint(input, begin, end);
        if (!success) revert StringsInvalidChar();
        return value;
    }

    /**
     * @dev Variant of {parseUint-string} that returns false if the parsing fails because of an invalid character.
     *
     * NOTE: This function will revert if the result does not fit in a `uint256`.
     */
    function tryParseUint(string memory input) internal pure returns (bool success, uint256 value) {
        return _tryParseUintUncheckedBounds(input, 0, bytes(input).length);
    }

    /**
     * @dev Variant of {parseUint-string-uint256-uint256} that returns false if the parsing fails because of an invalid
     * character.
     *
     * NOTE: This function will revert if the result does not fit in a `uint256`.
     */
    function tryParseUint(
        string memory input,
        uint256 begin,
        uint256 end
    ) internal pure returns (bool success, uint256 value) {
        if (end > bytes(input).length || begin > end) return (false, 0);
        return _tryParseUintUncheckedBounds(input, begin, end);
    }

    /**
     * @dev Implementation of {tryParseUint-string-uint256-uint256} that does not check bounds. Caller should make sure that
     * `begin <= end <= input.length`. Other inputs would result in undefined behavior.
     */
    function _tryParseUintUncheckedBounds(
        string memory input,
        uint256 begin,
        uint256 end
    ) private pure returns (bool success, uint256 value) {
        bytes memory buffer = bytes(input);

        uint256 result = 0;
        for (uint256 i = begin; i < end; ++i) {
            uint8 chr = _tryParseChr(bytes1(_unsafeReadBytesOffset(buffer, i)));
            if (chr > 9) return (false, 0);
            result *= 10;
            result += chr;
        }
        return (true, result);
    }

    /**
     * @dev Parse a decimal string and returns the value as a `int256`.
     *
     * Requirements:
     * - The string must be formatted as `[-+]?[0-9]*`
     * - The result must fit in an `int256` type.
     */
    function parseInt(string memory input) internal pure returns (int256) {
        return parseInt(input, 0, bytes(input).length);
    }

    /**
     * @dev Variant of {parseInt-string} that parses a substring of `input` located between position `begin` (included) and
     * `end` (excluded).
     *
     * Requirements:
     * - The substring must be formatted as `[-+]?[0-9]*`
     * - The result must fit in an `int256` type.
     */
    function parseInt(string memory input, uint256 begin, uint256 end) internal pure returns (int256) {
        (bool success, int256 value) = tryParseInt(input, begin, end);
        if (!success) revert StringsInvalidChar();
        return value;
    }

    /**
     * @dev Variant of {parseInt-string} that returns false if the parsing fails because of an invalid character or if
     * the result does not fit in a `int256`.
     *
     * NOTE: This function will revert if the absolute value of the result does not fit in a `uint256`.
     */
    function tryParseInt(string memory input) internal pure returns (bool success, int256 value) {
        return _tryParseIntUncheckedBounds(input, 0, bytes(input).length);
    }

    uint256 private constant ABS_MIN_INT256 = 2 ** 255;

    /**
     * @dev Variant of {parseInt-string-uint256-uint256} that returns false if the parsing fails because of an invalid
     * character or if the result does not fit in a `int256`.
     *
     * NOTE: This function will revert if the absolute value of the result does not fit in a `uint256`.
     */
    function tryParseInt(
        string memory input,
        uint256 begin,
        uint256 end
    ) internal pure returns (bool success, int256 value) {
        if (end > bytes(input).length || begin > end) return (false, 0);
        return _tryParseIntUncheckedBounds(input, begin, end);
    }

    /**
     * @dev Implementation of {tryParseInt-string-uint256-uint256} that does not check bounds. Caller should make sure that
     * `begin <= end <= input.length`. Other inputs would result in undefined behavior.
     */
    function _tryParseIntUncheckedBounds(
        string memory input,
        uint256 begin,
        uint256 end
    ) private pure returns (bool success, int256 value) {
        bytes memory buffer = bytes(input);

        // Check presence of a negative sign.
        bytes1 sign = begin == end ? bytes1(0) : bytes1(_unsafeReadBytesOffset(buffer, begin)); // don't do out-of-bound (possibly unsafe) read if sub-string is empty
        bool positiveSign = sign == bytes1("+");
        bool negativeSign = sign == bytes1("-");
        uint256 offset = (positiveSign || negativeSign).toUint();

        (bool absSuccess, uint256 absValue) = tryParseUint(input, begin + offset, end);

        if (absSuccess && absValue < ABS_MIN_INT256) {
            return (true, negativeSign ? -int256(absValue) : int256(absValue));
        } else if (absSuccess && negativeSign && absValue == ABS_MIN_INT256) {
            return (true, type(int256).min);
        } else return (false, 0);
    }

    /**
     * @dev Parse a hexadecimal string (with or without "0x" prefix), and returns the value as a `uint256`.
     *
     * Requirements:
     * - The string must be formatted as `(0x)?[0-9a-fA-F]*`
     * - The result must fit in an `uint256` type.
     */
    function parseHexUint(string memory input) internal pure returns (uint256) {
        return parseHexUint(input, 0, bytes(input).length);
    }

    /**
     * @dev Variant of {parseHexUint-string} that parses a substring of `input` located between position `begin` (included) and
     * `end` (excluded).
     *
     * Requirements:
     * - The substring must be formatted as `(0x)?[0-9a-fA-F]*`
     * - The result must fit in an `uint256` type.
     */
    function parseHexUint(string memory input, uint256 begin, uint256 end) internal pure returns (uint256) {
        (bool success, uint256 value) = tryParseHexUint(input, begin, end);
        if (!success) revert StringsInvalidChar();
        return value;
    }

    /**
     * @dev Variant of {parseHexUint-string} that returns false if the parsing fails because of an invalid character.
     *
     * NOTE: This function will revert if the result does not fit in a `uint256`.
     */
    function tryParseHexUint(string memory input) internal pure returns (bool success, uint256 value) {
        return _tryParseHexUintUncheckedBounds(input, 0, bytes(input).length);
    }

    /**
     * @dev Variant of {parseHexUint-string-uint256-uint256} that returns false if the parsing fails because of an
     * invalid character.
     *
     * NOTE: This function will revert if the result does not fit in a `uint256`.
     */
    function tryParseHexUint(
        string memory input,
        uint256 begin,
        uint256 end
    ) internal pure returns (bool success, uint256 value) {
        if (end > bytes(input).length || begin > end) return (false, 0);
        return _tryParseHexUintUncheckedBounds(input, begin, end);
    }

    /**
     * @dev Implementation of {tryParseHexUint-string-uint256-uint256} that does not check bounds. Caller should make sure that
     * `begin <= end <= input.length`. Other inputs would result in undefined behavior.
     */
    function _tryParseHexUintUncheckedBounds(
        string memory input,
        uint256 begin,
        uint256 end
    ) private pure returns (bool success, uint256 value) {
        bytes memory buffer = bytes(input);

        // skip 0x prefix if present
        bool hasPrefix = (end > begin + 1) && bytes2(_unsafeReadBytesOffset(buffer, begin)) == bytes2("0x"); // don't do out-of-bound (possibly unsafe) read if sub-string is empty
        uint256 offset = hasPrefix.toUint() * 2;

        uint256 result = 0;
        for (uint256 i = begin + offset; i < end; ++i) {
            uint8 chr = _tryParseChr(bytes1(_unsafeReadBytesOffset(buffer, i)));
            if (chr > 15) return (false, 0);
            result *= 16;
            unchecked {
                // Multiplying by 16 is equivalent to a shift of 4 bits (with additional overflow check).
                // This guarantees that adding a value < 16 will not cause an overflow, hence the unchecked.
                result += chr;
            }
        }
        return (true, result);
    }

    /**
     * @dev Parse a hexadecimal string (with or without "0x" prefix), and returns the value as an `address`.
     *
     * Requirements:
     * - The string must be formatted as `(0x)?[0-9a-fA-F]{40}`
     */
    function parseAddress(string memory input) internal pure returns (address) {
        return parseAddress(input, 0, bytes(input).length);
    }

    /**
     * @dev Variant of {parseAddress-string} that parses a substring of `input` located between position `begin` (included) and
     * `end` (excluded).
     *
     * Requirements:
     * - The substring must be formatted as `(0x)?[0-9a-fA-F]{40}`
     */
    function parseAddress(string memory input, uint256 begin, uint256 end) internal pure returns (address) {
        (bool success, address value) = tryParseAddress(input, begin, end);
        if (!success) revert StringsInvalidAddressFormat();
        return value;
    }

    /**
     * @dev Variant of {parseAddress-string} that returns false if the parsing fails because the input is not a properly
     * formatted address. See {parseAddress-string} requirements.
     */
    function tryParseAddress(string memory input) internal pure returns (bool success, address value) {
        return tryParseAddress(input, 0, bytes(input).length);
    }

    /**
     * @dev Variant of {parseAddress-string-uint256-uint256} that returns false if the parsing fails because input is not a properly
     * formatted address. See {parseAddress-string-uint256-uint256} requirements.
     */
    function tryParseAddress(
        string memory input,
        uint256 begin,
        uint256 end
    ) internal pure returns (bool success, address value) {
        if (end > bytes(input).length || begin > end) return (false, address(0));

        bool hasPrefix = (end > begin + 1) && bytes2(_unsafeReadBytesOffset(bytes(input), begin)) == bytes2("0x"); // don't do out-of-bound (possibly unsafe) read if sub-string is empty
        uint256 expectedLength = 40 + hasPrefix.toUint() * 2;

        // check that input is the correct length
        if (end - begin == expectedLength) {
            // length guarantees that this does not overflow, and value is at most type(uint160).max
            (bool s, uint256 v) = _tryParseHexUintUncheckedBounds(input, begin, end);
            return (s, address(uint160(v)));
        } else {
            return (false, address(0));
        }
    }

    function _tryParseChr(bytes1 chr) private pure returns (uint8) {
        uint8 value = uint8(chr);

        // Try to parse `chr`:
        // - Case 1: [0-9]
        // - Case 2: [a-f]
        // - Case 3: [A-F]
        // - otherwise not supported
        unchecked {
            if (value > 47 && value < 58) value -= 48;
            else if (value > 96 && value < 103) value -= 87;
            else if (value > 64 && value < 71) value -= 55;
            else return type(uint8).max;
        }

        return value;
    }

    /**
     * @dev Escape special characters in JSON strings. This can be useful to prevent JSON injection in NFT metadata.
     *
     * WARNING: This function should only be used in double quoted JSON strings. Single quotes are not escaped.
     *
     * NOTE: This function escapes backslashes (including those in \uXXXX sequences) and the characters in ranges
     * defined in section 2.5 of RFC-4627 (U+0000 to U+001F, U+0022 and U+005C). All control characters in U+0000
     * to U+001F are escaped (\b, \t, \n, \f, \r use short form; others use \u00XX). ECMAScript's `JSON.parse` does
     * recover escaped unicode characters that are not in this range, but other tooling may provide different results.
     */
    function escapeJSON(string memory input) internal pure returns (string memory) {
        bytes memory buffer = bytes(input);

        // Put output at the FMP. Memory will be reserved later when we figure out the actual length of the escaped
        // string. All write are done using _unsafeWriteBytesOffset, which avoid the (expensive) length checks for
        // each character written.
        bytes memory output;
        assembly ("memory-safe") {
            output := mload(0x40)
        }
        uint256 outputLength = 0;

        for (uint256 i = 0; i < buffer.length; ++i) {
            uint8 char = uint8(bytes1(_unsafeReadBytesOffset(buffer, i)));
            if (((SPECIAL_CHARS_LOOKUP & (1 << char)) != 0)) {
                _unsafeWriteBytesOffset(output, outputLength++, "\\");
                if (char == 0x08) _unsafeWriteBytesOffset(output, outputLength++, "b");
                else if (char == 0x09) _unsafeWriteBytesOffset(output, outputLength++, "t");
                else if (char == 0x0a) _unsafeWriteBytesOffset(output, outputLength++, "n");
                else if (char == 0x0c) _unsafeWriteBytesOffset(output, outputLength++, "f");
                else if (char == 0x0d) _unsafeWriteBytesOffset(output, outputLength++, "r");
                else if (char == 0x5c) _unsafeWriteBytesOffset(output, outputLength++, "\\");
                else if (char == 0x22) {
                    // solhint-disable-next-line quotes
                    _unsafeWriteBytesOffset(output, outputLength++, '"');
                } else {
                    // U+0000 to U+001F without short form: output \u00XX
                    _unsafeWriteBytesOffset(output, outputLength++, "u");
                    _unsafeWriteBytesOffset(output, outputLength++, "0");
                    _unsafeWriteBytesOffset(output, outputLength++, "0");
                    _unsafeWriteBytesOffset(output, outputLength++, HEX_DIGITS[char >> 4]);
                    _unsafeWriteBytesOffset(output, outputLength++, HEX_DIGITS[char & 0x0f]);
                }
            } else {
                _unsafeWriteBytesOffset(output, outputLength++, bytes1(char));
            }
        }
        // write the actual length and reserve memory
        assembly ("memory-safe") {
            mstore(output, outputLength)
            mstore(0x40, add(output, add(outputLength, 0x20)))
        }

        return string(output);
    }

    /**
     * @dev Reads a bytes32 from a bytes array without bounds checking.
     *
     * NOTE: making this function internal would mean it could be used with memory unsafe offset, and marking the
     * assembly block as such would prevent some optimizations.
     */
    function _unsafeReadBytesOffset(bytes memory buffer, uint256 offset) private pure returns (bytes32 value) {
        // This is not memory safe in the general case, but all calls to this private function are within bounds.
        assembly ("memory-safe") {
            value := mload(add(add(buffer, 0x20), offset))
        }
    }

    /**
     * @dev Write a bytes1 to a bytes array without bounds checking.
     *
     * NOTE: making this function internal would mean it could be used with memory unsafe offset, and marking the
     * assembly block as such would prevent some optimizations.
     */
    function _unsafeWriteBytesOffset(bytes memory buffer, uint256 offset, bytes1 value) private pure {
        // This is not memory safe in the general case, but all calls to this private function are within bounds.
        assembly ("memory-safe") {
            mstore8(add(add(buffer, 0x20), offset), shr(248, value))
        }
    }
}


// File @openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol@v5.7.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.6.0) (utils/cryptography/MessageHashUtils.sol)

pragma solidity ^0.8.24;

/**
 * @dev Signature message hash utilities for producing digests to be consumed by {ECDSA} recovery or signing.
 *
 * The library provides methods for generating a hash of a message that conforms to the
 * https://eips.ethereum.org/EIPS/eip-191[ERC-191] and https://eips.ethereum.org/EIPS/eip-712[EIP 712]
 * specifications.
 */
library MessageHashUtils {
    error ERC5267ExtensionsNotSupported();

    /**
     * @dev Returns the keccak256 digest of an ERC-191 signed data with version
     * `0x45` (`personal_sign` messages).
     *
     * The digest is calculated by prefixing a bytes32 `messageHash` with
     * `"\x19Ethereum Signed Message:\n32"` and hashing the result. It corresponds with the
     * hash signed when using the https://ethereum.org/en/developers/docs/apis/json-rpc/#eth_sign[`eth_sign`] JSON-RPC method.
     *
     * NOTE: The `messageHash` parameter is intended to be the result of hashing a raw message with
     * keccak256, although any bytes32 value can be safely used because the final digest will
     * be re-hashed.
     *
     * See {ECDSA-recover}.
     */
    function toEthSignedMessageHash(bytes32 messageHash) internal pure returns (bytes32 digest) {
        assembly ("memory-safe") {
            mstore(0x00, "\x19Ethereum Signed Message:\n32") // 32 is the bytes-length of messageHash
            mstore(0x1c, messageHash) // 0x1c (28) is the length of the prefix
            digest := keccak256(0x00, 0x3c) // 0x3c is the length of the prefix (0x1c) + messageHash (0x20)
        }
    }

    /**
     * @dev Returns the keccak256 digest of an ERC-191 signed data with version
     * `0x45` (`personal_sign` messages).
     *
     * The digest is calculated by prefixing an arbitrary `message` with
     * `"\x19Ethereum Signed Message:\n" + len(message)` and hashing the result. It corresponds with the
     * hash signed when using the https://ethereum.org/en/developers/docs/apis/json-rpc/#eth_sign[`eth_sign`] JSON-RPC method.
     *
     * See {ECDSA-recover}.
     */
    function toEthSignedMessageHash(bytes memory message) internal pure returns (bytes32) {
        return
            keccak256(bytes.concat("\x19Ethereum Signed Message:\n", bytes(Strings.toString(message.length)), message));
    }

    /**
     * @dev Returns the keccak256 digest of an ERC-191 signed data with version
     * `0x00` (data with intended validator).
     *
     * The digest is calculated by prefixing an arbitrary `data` with `"\x19\x00"` and the intended
     * `validator` address. Then hashing the result.
     *
     * See {ECDSA-recover}.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(hex"19_00", validator, data));
    }

    /**
     * @dev Variant of {toDataWithIntendedValidatorHash-address-bytes} optimized for cases where `data` is a bytes32.
     */
    function toDataWithIntendedValidatorHash(
        address validator,
        bytes32 messageHash
    ) internal pure returns (bytes32 digest) {
        assembly ("memory-safe") {
            mstore(0x00, hex"19_00")
            mstore(0x02, shl(96, validator))
            mstore(0x16, messageHash)
            digest := keccak256(0x00, 0x36)
        }
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-712 typed data (ERC-191 version `0x01`).
     *
     * The digest is calculated from a `domainSeparator` and a `structHash`, by prefixing them with
     * `\x19\x01` and hashing the result. It corresponds to the hash signed by the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`] JSON-RPC method as part of EIP-712.
     *
     * See {ECDSA-recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 digest) {
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, hex"19_01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            digest := keccak256(ptr, 0x42)
        }
    }

    /**
     * @dev Returns the EIP-712 domain separator constructed from an `eip712Domain`. See {IERC5267-eip712Domain}
     *
     * This function dynamically constructs the domain separator based on which fields are present in the
     * `fields` parameter. It contains flags that indicate which domain fields are present:
     *
     * * Bit 0 (0x01): name
     * * Bit 1 (0x02): version
     * * Bit 2 (0x04): chainId
     * * Bit 3 (0x08): verifyingContract
     * * Bit 4 (0x10): salt
     *
     * Arguments that correspond to fields which are not present in `fields` are ignored. For example, if `fields` is
     * `0x0f` (`0b01111`), then the `salt` parameter is ignored.
     */
    function toDomainSeparator(
        bytes1 fields,
        string memory name,
        string memory version,
        uint256 chainId,
        address verifyingContract,
        bytes32 salt
    ) internal pure returns (bytes32 hash) {
        return
            toDomainSeparator(
                fields,
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                chainId,
                verifyingContract,
                salt
            );
    }

    /// @dev Variant of {toDomainSeparator-bytes1-string-string-uint256-address-bytes32} that uses hashed name and version.
    function toDomainSeparator(
        bytes1 fields,
        bytes32 nameHash,
        bytes32 versionHash,
        uint256 chainId,
        address verifyingContract,
        bytes32 salt
    ) internal pure returns (bytes32 hash) {
        bytes32 domainTypeHash = toDomainTypeHash(fields);

        assembly ("memory-safe") {
            // align fields to the right for easy processing
            fields := shr(248, fields)

            // FMP used as scratch space
            let fmp := mload(0x40)
            mstore(fmp, domainTypeHash)

            let ptr := add(fmp, 0x20)
            if and(fields, 0x01) {
                mstore(ptr, nameHash)
                ptr := add(ptr, 0x20)
            }
            if and(fields, 0x02) {
                mstore(ptr, versionHash)
                ptr := add(ptr, 0x20)
            }
            if and(fields, 0x04) {
                mstore(ptr, chainId)
                ptr := add(ptr, 0x20)
            }
            if and(fields, 0x08) {
                mstore(ptr, verifyingContract)
                ptr := add(ptr, 0x20)
            }
            if and(fields, 0x10) {
                mstore(ptr, salt)
                ptr := add(ptr, 0x20)
            }

            hash := keccak256(fmp, sub(ptr, fmp))
        }
    }

    /// @dev Builds an EIP-712 domain type hash depending on the `fields` provided, following https://eips.ethereum.org/EIPS/eip-5267[ERC-5267]
    function toDomainTypeHash(bytes1 fields) internal pure returns (bytes32 hash) {
        if (fields & 0x20 == 0x20) revert ERC5267ExtensionsNotSupported();

        assembly ("memory-safe") {
            // align fields to the right for easy processing
            fields := shr(248, fields)

            // FMP used as scratch space
            let fmp := mload(0x40)
            mstore(fmp, "EIP712Domain(")

            let ptr := add(fmp, 0x0d)
            // name field
            if and(fields, 0x01) {
                mstore(ptr, "string name,")
                ptr := add(ptr, 0x0c)
            }
            // version field
            if and(fields, 0x02) {
                mstore(ptr, "string version,")
                ptr := add(ptr, 0x0f)
            }
            // chainId field
            if and(fields, 0x04) {
                mstore(ptr, "uint256 chainId,")
                ptr := add(ptr, 0x10)
            }
            // verifyingContract field
            if and(fields, 0x08) {
                mstore(ptr, "address verifyingContract,")
                ptr := add(ptr, 0x1a)
            }
            // salt field
            if and(fields, 0x10) {
                mstore(ptr, "bytes32 salt,")
                ptr := add(ptr, 0x0d)
            }
            // if any field is enabled, remove the trailing comma
            ptr := sub(ptr, iszero(iszero(and(fields, 0x1f))))
            // add the closing brace
            mstore8(ptr, 0x29) // add closing brace
            ptr := add(ptr, 1)

            hash := keccak256(fmp, sub(ptr, fmp))
        }
    }
}


// File @openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol@v5.7.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.7.0) (utils/cryptography/EIP712.sol)

pragma solidity ^0.8.24;



/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP-712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding scheme specified in the EIP requires a domain separator and a hash of the typed structured data, whose
 * encoding is very generic and therefore its implementation in Solidity is not feasible, thus this contract
 * does not implement the encoding itself. Protocols need to implement the type-specific encoding they need in order to
 * produce the hash of their typed data using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP-712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * NOTE: The upgradeable version of this contract does not use an immutable cache and recomputes the domain separator
 * each time {_domainSeparatorV4} is called. This is cheaper than accessing a cached version in cold storage.
 */
abstract contract EIP712Upgradeable is Initializable, IERC5267 {
    bytes32 private constant TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    /// @custom:storage-location erc7201:openzeppelin.storage.EIP712
    struct EIP712Storage {
        bytes32 _hashedName;
        bytes32 _hashedVersion;

        string _name;
        string _version;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.EIP712")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant EIP712StorageLocation = 0xa16a46d94261c7517cc8ff89f61c0ce93598e3c849801011dee649a6a557d100;

    function _getEIP712Storage() private pure returns (EIP712Storage storage $) {
        assembly {
            $.slot := EIP712StorageLocation
        }
    }

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP-712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    function __EIP712_init(string memory name, string memory version) internal onlyInitializing {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(string memory name, string memory version) internal onlyInitializing {
        EIP712Storage storage $ = _getEIP712Storage();
        $._name = name;
        $._version = version;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator();
    }

    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash(), block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return MessageHashUtils.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /// @inheritdoc IERC5267
    function eip712Domain()
        public
        view
        virtual
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        )
    {
        return (
            hex"0f", // 01111
            _EIP712Name(),
            _EIP712Version(),
            block.chainid,
            address(this),
            bytes32(0),
            new uint256[](0)
        );
    }

    /**
     * @dev The name parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712Name() internal view virtual returns (string memory) {
        EIP712Storage storage $ = _getEIP712Storage();
        return $._name;
    }

    /**
     * @dev The version parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712Version() internal view virtual returns (string memory) {
        EIP712Storage storage $ = _getEIP712Storage();
        return $._version;
    }

    /**
     * @dev The hash of the name parameter for the EIP712 domain.
     *
     * NOTE: In previous versions this function was virtual. In this version you should override `_EIP712Name` instead.
     */
    function _EIP712NameHash() internal view returns (bytes32) {
        return keccak256(bytes(_EIP712Name()));
    }

    /**
     * @dev The hash of the version parameter for the EIP712 domain.
     *
     * NOTE: In previous versions this function was virtual. In this version you should override `_EIP712Version` instead.
     */
    function _EIP712VersionHash() internal view returns (bytes32) {
        return keccak256(bytes(_EIP712Version()));
    }
}


// File @openzeppelin/contracts-upgradeable/utils/NoncesUpgradeable.sol@v5.7.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.7.0) (utils/Nonces.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides tracking nonces for addresses. Nonces will only increment.
 */
abstract contract NoncesUpgradeable is Initializable {
    /**
     * @dev The nonce used for an `account` is not the expected current nonce.
     */
    error InvalidAccountNonce(address account, uint256 currentNonce);

    /// @custom:storage-location erc7201:openzeppelin.storage.Nonces
    struct NoncesStorage {
        mapping(address account => uint256) _nonces;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Nonces")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant NoncesStorageLocation = 0x5ab42ced628888259c08ac98db1eb0cf702fc1501344311d8b100cd1bfe4bb00;

    function _getNoncesStorage() private pure returns (NoncesStorage storage $) {
        assembly {
            $.slot := NoncesStorageLocation
        }
    }

    function __Nonces_init() internal onlyInitializing {
    }

    function __Nonces_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev Returns the next unused nonce for an address.
     */
    function nonces(address owner) public view virtual returns (uint256) {
        NoncesStorage storage $ = _getNoncesStorage();
        return $._nonces[owner];
    }

    /**
     * @dev Consumes a nonce.
     *
     * Returns the current value and increments nonce.
     */
    function _useNonce(address owner) internal virtual returns (uint256) {
        NoncesStorage storage $ = _getNoncesStorage();
        // For each account, the nonce has an initial value of 0, can only be incremented by one, and cannot be
        // decremented or reset. This guarantees that the nonce never overflows.
        unchecked {
            // It is important to do x++ and not ++x here.
            return $._nonces[owner]++;
        }
    }

    /**
     * @dev Same as {_useNonce} but checking that `nonce` is the next valid for `owner`.
     */
    function _useCheckedNonce(address owner, uint256 nonce) internal virtual {
        uint256 current = _useNonce(owner);
        if (nonce != current) {
            revert InvalidAccountNonce(owner, current);
        }
    }
}


// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol@v5.7.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.5.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity >=0.4.16;

/**
 * @dev Interface of the ERC-20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[ERC-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC-20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also applies here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     *
     * CAUTION: See Security Considerations above.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}


// File @openzeppelin/contracts/utils/cryptography/ECDSA.sol@v5.7.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.7.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.20;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS
    }

    /**
     * @dev The signature is invalid.
     */
    error ECDSAInvalidSignature();

    /**
     * @dev The signature has an invalid length.
     */
    error ECDSAInvalidSignatureLength(uint256 length);

    /**
     * @dev The signature has an S value that is in the upper half order.
     */
    error ECDSAInvalidSignatureS(bytes32 s);

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with `signature` or an error. This will not
     * return address(0) without also returning an error description. Errors are documented using an enum (error type)
     * and a bytes32 providing additional information about the error.
     *
     * If no error is returned, then the address can be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * NOTE: This function only supports 65-byte signatures. ERC-2098 short signatures are rejected. This restriction
     * is DEPRECATED and will be removed in v6.0. Developers SHOULD NOT use signatures as unique identifiers; use hash
     * invalidation or nonces for replay protection.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     *
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     */
    function tryRecover(
        bytes32 hash,
        bytes memory signature
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly ("memory-safe") {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength, bytes32(signature.length));
        }
    }

    /**
     * @dev Variant of {tryRecover} that takes a signature in calldata
     */
    function tryRecoverCalldata(
        bytes32 hash,
        bytes calldata signature
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, calldata slices would work here, but are
            // significantly more expensive (length check) than using calldataload in assembly.
            assembly ("memory-safe") {
                r := calldataload(signature.offset)
                s := calldataload(add(signature.offset, 0x20))
                v := byte(0, calldataload(add(signature.offset, 0x40)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength, bytes32(signature.length));
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * NOTE: This function only supports 65-byte signatures. ERC-2098 short signatures are rejected. This restriction
     * is DEPRECATED and will be removed in v6.0. Developers SHOULD NOT use signatures as unique identifiers; use hash
     * invalidation or nonces for replay protection.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError err, bytes32 errorArg) = tryRecover(hash, signature);
        _throwError(err, errorArg);
        return recovered;
    }

    /**
     * @dev Variant of {recover} that takes a signature in calldata
     */
    function recoverCalldata(bytes32 hash, bytes calldata signature) internal pure returns (address) {
        (address recovered, RecoverError err, bytes32 errorArg) = tryRecoverCalldata(hash, signature);
        _throwError(err, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[ERC-2098 short signatures]
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
        unchecked {
            bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
            // We do not check for an overflow here since the shift operation results in 0 or 1.
            uint8 v = uint8((uint256(vs) >> 255) + 27);
            return tryRecover(hash, v, r, s);
        }
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r` and `vs` short-signature fields separately.
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError err, bytes32 errorArg) = tryRecover(hash, r, vs);
        _throwError(err, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS, s);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature, bytes32(0));
        }

        return (signer, RecoverError.NoError, bytes32(0));
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError err, bytes32 errorArg) = tryRecover(hash, v, r, s);
        _throwError(err, errorArg);
        return recovered;
    }

    /**
     * @dev Parse a signature into its `v`, `r` and `s` components. Supports 65-byte and 64-byte (ERC-2098)
     * formats. Returns (0,0,0) for invalid signatures.
     *
     * For 64-byte signatures, `v` is automatically normalized to 27 or 28.
     * For 65-byte signatures, `v` is returned as-is and MUST already be 27 or 28 for use with ecrecover.
     *
     * Consider validating the result before use, or use {tryRecover}/{recover} which perform full validation.
     */
    function parse(bytes memory signature) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        assembly ("memory-safe") {
            // Check the signature length
            switch mload(signature)
            // - case 65: r,s,v signature (standard)
            case 65 {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098)
            case 64 {
                let vs := mload(add(signature, 0x40))
                r := mload(add(signature, 0x20))
                s := and(vs, shr(1, not(0)))
                v := add(shr(255, vs), 27)
            }
            default {
                r := 0
                s := 0
                v := 0
            }
        }
    }

    /**
     * @dev Variant of {parse} that takes a signature in calldata
     */
    function parseCalldata(bytes calldata signature) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        assembly ("memory-safe") {
            // Check the signature length
            switch signature.length
            // - case 65: r,s,v signature (standard)
            case 65 {
                r := calldataload(signature.offset)
                s := calldataload(add(signature.offset, 0x20))
                v := byte(0, calldataload(add(signature.offset, 0x40)))
            }
            // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098)
            case 64 {
                let vs := calldataload(add(signature.offset, 0x20))
                r := calldataload(signature.offset)
                s := and(vs, shr(1, not(0)))
                v := add(shr(255, vs), 27)
            }
            default {
                r := 0
                s := 0
                v := 0
            }
        }
    }

    /**
     * @dev Optionally reverts with the corresponding custom error according to the `error` argument provided.
     */
    function _throwError(RecoverError err, bytes32 errorArg) private pure {
        if (err == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (err == RecoverError.InvalidSignature) {
            revert ECDSAInvalidSignature();
        } else if (err == RecoverError.InvalidSignatureLength) {
            revert ECDSAInvalidSignatureLength(uint256(errorArg));
        } else if (err == RecoverError.InvalidSignatureS) {
            revert ECDSAInvalidSignatureS(errorArg);
        }
    }
}


// File @openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol@v5.7.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.5.0) (token/ERC20/extensions/ERC20Permit.sol)

pragma solidity ^0.8.24;






/**
 * @dev Implementation of the ERC-20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[ERC-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC-20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
abstract contract ERC20PermitUpgradeable is Initializable, ERC20Upgradeable, IERC20Permit, EIP712Upgradeable, NoncesUpgradeable {
    bytes32 private constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /**
     * @dev Permit deadline has expired.
     */
    error ERC2612ExpiredSignature(uint256 deadline);

    /**
     * @dev Mismatched signature.
     */
    error ERC2612InvalidSigner(address signer, address owner);

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC-20 token name.
     */
    function __ERC20Permit_init(string memory name) internal onlyInitializing {
        __EIP712_init_unchained(name, "1");
    }

    function __ERC20Permit_init_unchained(string memory) internal onlyInitializing {}

    /// @inheritdoc IERC20Permit
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        if (block.timestamp > deadline) {
            revert ERC2612ExpiredSignature(deadline);
        }

        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        if (signer != owner) {
            revert ERC2612InvalidSigner(signer, owner);
        }

        _approve(owner, spender, value);
    }

    /// @inheritdoc IERC20Permit
    function nonces(address owner) public view virtual override(IERC20Permit, NoncesUpgradeable) returns (uint256) {
        return super.nonces(owner);
    }

    /// @inheritdoc IERC20Permit
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        return _domainSeparatorV4();
    }
}


// File @openzeppelin/contracts/utils/Errors.sol@v5.7.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/Errors.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of common custom errors used in multiple contracts
 *
 * IMPORTANT: Backwards compatibility is not guaranteed in future versions of the library.
 * It is recommended to avoid relying on the error API for critical functionality.
 *
 * _Available since v5.1._
 */
library Errors {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error InsufficientBalance(uint256 balance, uint256 needed);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedCall();

    /**
     * @dev The deployment failed.
     */
    error FailedDeployment();

    /**
     * @dev A necessary precompile is missing.
     */
    error MissingPrecompile(address);
}


// File @openzeppelin/contracts/utils/LowLevelCall.sol@v5.7.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.6.0) (utils/LowLevelCall.sol)

pragma solidity ^0.8.20;

/**
 * @dev Library of low level call functions that implement different calling strategies to deal with the return data.
 *
 * WARNING: Using this library requires an advanced understanding of Solidity and how the EVM works. It is recommended
 * to use the {Address} library instead.
 */
library LowLevelCall {
    /// @dev Performs a Solidity function call using a low level `call` and ignoring the return data.
    function callNoReturn(address target, bytes memory data) internal returns (bool success) {
        return callNoReturn(target, 0, data);
    }

    /// @dev Same as {callNoReturn-address-bytes}, but allows specifying the value to be sent in the call.
    function callNoReturn(address target, uint256 value, bytes memory data) internal returns (bool success) {
        assembly ("memory-safe") {
            success := call(gas(), target, value, add(data, 0x20), mload(data), 0x00, 0x00)
        }
    }

    /// @dev Performs a Solidity function call using a low level `call` and returns the first 64 bytes of the result
    /// in the scratch space of memory. Useful for functions that return a tuple with two single-word values.
    ///
    /// WARNING: Do not assume that the results are zero if `success` is false. Memory can be already allocated
    /// and this function doesn't zero it out.
    function callReturn64Bytes(
        address target,
        bytes memory data
    ) internal returns (bool success, bytes32 result1, bytes32 result2) {
        return callReturn64Bytes(target, 0, data);
    }

    /// @dev Same as {callReturn64Bytes-address-bytes}, but allows specifying the value to be sent in the call.
    function callReturn64Bytes(
        address target,
        uint256 value,
        bytes memory data
    ) internal returns (bool success, bytes32 result1, bytes32 result2) {
        assembly ("memory-safe") {
            success := call(gas(), target, value, add(data, 0x20), mload(data), 0x00, 0x40)
            result1 := mload(0x00)
            result2 := mload(0x20)
        }
    }

    /// @dev Performs a Solidity function call using a low level `staticcall` and ignoring the return data.
    function staticcallNoReturn(address target, bytes memory data) internal view returns (bool success) {
        assembly ("memory-safe") {
            success := staticcall(gas(), target, add(data, 0x20), mload(data), 0x00, 0x00)
        }
    }

    /// @dev Performs a Solidity function call using a low level `staticcall` and returns the first 64 bytes of the result
    /// in the scratch space of memory. Useful for functions that return a tuple with two single-word values.
    ///
    /// WARNING: Do not assume that the results are zero if `success` is false. Memory can be already allocated
    /// and this function doesn't zero it out.
    function staticcallReturn64Bytes(
        address target,
        bytes memory data
    ) internal view returns (bool success, bytes32 result1, bytes32 result2) {
        assembly ("memory-safe") {
            success := staticcall(gas(), target, add(data, 0x20), mload(data), 0x00, 0x40)
            result1 := mload(0x00)
            result2 := mload(0x20)
        }
    }

    /// @dev Performs a Solidity function call using a low level `delegatecall` and ignoring the return data.
    function delegatecallNoReturn(address target, bytes memory data) internal returns (bool success) {
        assembly ("memory-safe") {
            success := delegatecall(gas(), target, add(data, 0x20), mload(data), 0x00, 0x00)
        }
    }

    /// @dev Performs a Solidity function call using a low level `delegatecall` and returns the first 64 bytes of the result
    /// in the scratch space of memory. Useful for functions that return a tuple with two single-word values.
    ///
    /// WARNING: Do not assume that the results are zero if `success` is false. Memory can be already allocated
    /// and this function doesn't zero it out.
    function delegatecallReturn64Bytes(
        address target,
        bytes memory data
    ) internal returns (bool success, bytes32 result1, bytes32 result2) {
        assembly ("memory-safe") {
            success := delegatecall(gas(), target, add(data, 0x20), mload(data), 0x00, 0x40)
            result1 := mload(0x00)
            result2 := mload(0x20)
        }
    }

    /// @dev Returns the size of the return data buffer.
    function returnDataSize() internal pure returns (uint256 size) {
        assembly ("memory-safe") {
            size := returndatasize()
        }
    }

    /// @dev Returns a buffer containing the return data from the last call.
    function returnData() internal pure returns (bytes memory result) {
        assembly ("memory-safe") {
            result := mload(0x40)
            mstore(result, returndatasize())
            returndatacopy(add(result, 0x20), 0x00, returndatasize())
            mstore(0x40, add(result, add(0x20, returndatasize())))
        }
    }

    /// @dev Revert with the return data from the last call.
    function bubbleRevert() internal pure {
        assembly ("memory-safe") {
            let fmp := mload(0x40)
            returndatacopy(fmp, 0x00, returndatasize())
            revert(fmp, returndatasize())
        }
    }

    function bubbleRevert(bytes memory returndata) internal pure {
        assembly ("memory-safe") {
            revert(add(returndata, 0x20), mload(returndata))
        }
    }
}


// File @openzeppelin/contracts/utils/Address.sol@v5.7.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.5.0) (utils/Address.sol)

pragma solidity ^0.8.20;


/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert Errors.InsufficientBalance(address(this).balance, amount);
        }
        if (LowLevelCall.callNoReturn(recipient, amount, "")) {
            // call successful, nothing to do
            return;
        } else if (LowLevelCall.returnDataSize() > 0) {
            LowLevelCall.bubbleRevert();
        } else {
            revert Errors.FailedCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {Errors.FailedCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert Errors.InsufficientBalance(address(this).balance, value);
        }
        bool success = LowLevelCall.callNoReturn(target, value, data);
        if (success && (LowLevelCall.returnDataSize() > 0 || target.code.length > 0)) {
            return LowLevelCall.returnData();
        } else if (success) {
            revert AddressEmptyCode(target);
        } else if (LowLevelCall.returnDataSize() > 0) {
            LowLevelCall.bubbleRevert();
        } else {
            revert Errors.FailedCall();
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        bool success = LowLevelCall.staticcallNoReturn(target, data);
        if (success && (LowLevelCall.returnDataSize() > 0 || target.code.length > 0)) {
            return LowLevelCall.returnData();
        } else if (success) {
            revert AddressEmptyCode(target);
        } else if (LowLevelCall.returnDataSize() > 0) {
            LowLevelCall.bubbleRevert();
        } else {
            revert Errors.FailedCall();
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        bool success = LowLevelCall.delegatecallNoReturn(target, data);
        if (success && (LowLevelCall.returnDataSize() > 0 || target.code.length > 0)) {
            return LowLevelCall.returnData();
        } else if (success) {
            revert AddressEmptyCode(target);
        } else if (LowLevelCall.returnDataSize() > 0) {
            LowLevelCall.bubbleRevert();
        } else {
            revert Errors.FailedCall();
        }
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {Errors.FailedCall}) in case
     * of an unsuccessful call.
     *
     * NOTE: This function is DEPRECATED and may be removed in the next major release.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        // only check if target is a contract if the call was successful and the return data is empty
        // otherwise we already know that it was a contract
        if (success && (returndata.length > 0 || target.code.length > 0)) {
            return returndata;
        } else if (success) {
            revert AddressEmptyCode(target);
        } else if (returndata.length > 0) {
            LowLevelCall.bubbleRevert(returndata);
        } else {
            revert Errors.FailedCall();
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {Errors.FailedCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else if (returndata.length > 0) {
            LowLevelCall.bubbleRevert(returndata);
        } else {
            revert Errors.FailedCall();
        }
    }
}


// File @openzeppelin/contracts-upgradeable/utils/MulticallUpgradeable.sol@v5.7.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.5.0) (utils/Multicall.sol)

pragma solidity ^0.8.20;



/**
 * @dev Provides a function to batch together multiple calls in a single external call.
 *
 * Consider any assumption about calldata validation performed by the sender may be violated if it's not especially
 * careful about sending transactions invoking {multicall}. For example, a relay address that filters function
 * selectors won't filter calls nested within a {multicall} operation.
 *
 * NOTE: Since 5.0.1 and 4.9.4, this contract identifies non-canonical contexts (i.e. `msg.sender` is not {Context-_msgSender}).
 * If a non-canonical context is identified, the following self `delegatecall` appends the last bytes of `msg.data`
 * to the subcall. This makes it safe to use with {ERC2771Context}. Contexts that don't affect the resolution of
 * {Context-_msgSender} are not propagated to subcalls.
 */
abstract contract MulticallUpgradeable is Initializable, ContextUpgradeable {
    function __Multicall_init() internal onlyInitializing {
    }

    function __Multicall_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev Receives and executes a batch of function calls on this contract.
     * @custom:oz-upgrades-unsafe-allow-reachable delegatecall
     */
    function multicall(bytes[] calldata data) public virtual returns (bytes[] memory results) {
        bytes memory context = msg.sender == _msgSender()
            ? new bytes(0)
            : msg.data[msg.data.length - _contextSuffixLength():];

        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            results[i] = Address.functionDelegateCall(address(this), bytes.concat(data[i], context));
        }
        return results;
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


// File contracts/modules/6_CMTATBaseERC2612.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

/* ==== OpenZeppelin === */



/* ==== Module === */

/* ==== Interface and other library === */

/**
* @title Extend CMTAT Base with ERC-2612 Permit and Multicall
*/
abstract contract CMTATBaseERC2612 is CMTATBaseERC20CrossChain, ERC20PermitUpgradeable, MulticallUpgradeable {
    /*//////////////////////////////////////////////////////////////
                         INITIALIZER FUNCTION
    //////////////////////////////////////////////////////////////*/
    /**
    * @dev initializer function
    */
    function __CMTAT_openzeppelin_init_unchained(
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_
    ) internal virtual override onlyInitializing {
        CMTATBaseRuleEngine.__CMTAT_openzeppelin_init_unchained(ERC20Attributes_);
        __EIP712_init_unchained(ERC20Attributes_.name, "1");
        __ERC20Permit_init_unchained(ERC20Attributes_.name);
        __Multicall_init_unchained();
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
    * @inheritdoc ERC20PermitUpgradeable
    * @dev Reverts if the contract is paused or if owner/spender is frozen, unless `value`
    * is zero: a zero-value permit is a gasless revocation and stays available so an owner
    * can always sever ties with a spender, even while restricted.
    *
    * The EIP-712 domain name is fixed at initialization and is **not** updated by
    * {TokenAttributeModule-setName}. Signers must build the domain from the ERC-5267
    * {eip712Domain} function (or `DOMAIN_SEPARATOR()`), not from {name}, which may have
    * been changed since deployment.
    */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override(ERC20PermitUpgradeable) {
        _canAuthorizeAllowanceByModuleAndRevert(owner, spender, value);
        ERC20PermitUpgradeable.permit(owner, spender, value, deadline, v, r, s);
    }

    /* ============ State functions ============ */
    /**
    * @dev revert if the contract is in pause state, unless `value` is zero:
    * setting an allowance to zero is a revocation and stays available while paused
    * or while the owner/spender is frozen or off the allowlist.
    * @inheritdoc ERC20Upgradeable
    */
    function approve(
        address spender,
        uint256 value
    ) public virtual override(ERC20Upgradeable, CMTATBaseERC20CrossChain) returns (bool) {
        return CMTATBaseERC20CrossChain.approve(spender, value);
    }

    /**
    * @inheritdoc CMTATBaseERC20CrossChain
    */
    function transfer(
        address to,
        uint256 value
    ) public virtual override(ERC20Upgradeable, CMTATBaseERC20CrossChain) returns (bool) {
        return CMTATBaseERC20CrossChain.transfer(to, value);
    }

    /**
    * @inheritdoc CMTATBaseERC20CrossChain
    */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    )
        public
        virtual
        override(ERC20Upgradeable, CMTATBaseERC20CrossChain)
        returns (bool)
    {
        return CMTATBaseERC20CrossChain.transferFrom(sender, recipient, amount);
    }

    /* ============ View functions ============ */
    /**
    * @inheritdoc CMTATBaseERC20CrossChain
    */
    function decimals()
        public
        view
        virtual
        override(ERC20Upgradeable, CMTATBaseERC20CrossChain)
        returns (uint8)
    {
        return CMTATBaseERC20CrossChain.decimals();
    }

    /**
    * @inheritdoc CMTATBaseERC20CrossChain
    */
    function name()
        public
        view
        virtual
        override(ERC20Upgradeable, CMTATBaseERC20CrossChain)
        returns (string memory)
    {
        return CMTATBaseERC20CrossChain.name();
    }

    /**
    * @inheritdoc CMTATBaseERC20CrossChain
    */
    function symbol()
        public
        view
        virtual
        override(ERC20Upgradeable, CMTATBaseERC20CrossChain)
        returns (string memory)
    {
        return CMTATBaseERC20CrossChain.symbol();
    }

}


// File contracts/deployment/permit/CMTATUpgradeablePermit.sol

// Original license: SPDX_License_Identifier: MPL-2.0

pragma solidity ^0.8.24;

/**
* @title CMTAT version for a proxy deployment (Transparent or Beacon proxy) with Permit and Multicall
*/
contract CMTATUpgradeablePermit is CMTATBaseERC2612 {
    /**
     * @notice Contract version for the deployment with a proxy
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        // Disable the possibility to initialize the implementation
        _disableInitializers();
    }
}
