// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

interface ICMTAT_BASE {
    error AddressZeroNotAllowed();
    error InvalidTransfer(address from, address to, uint256 amount);
    error SameValue();
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Burn(address indexed owner, uint256 amount, string reason);
    event Flag(uint256 indexed newFlag);
    event Information(
        string indexed newInformationIndexed,
        string newInformation
    );
    event Initialized(uint8 version);
    event Mint(address indexed beneficiary, uint256 amount);
    event Paused(address account);
    event RoleAdminChanged(
        bytes32 indexed role,
        bytes32 indexed previousAdminRole,
        bytes32 indexed newAdminRole
    );
    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );
    event RoleRevoked(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );
    event Spend(address indexed owner, address indexed spender, uint256 amount);
    event Term(string indexed newTermIndexed, string newTerm);
    event TokenId(string indexed newTokenIdIndexed, string newTokenId);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Unpaused(address account);

    function BURNER_ROLE() external view returns (bytes32);

    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);

    function MINTER_ROLE() external view returns (bytes32);

    function PAUSER_ROLE() external view returns (bytes32);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function decimals() external view returns (uint8);

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool);

    function flag() external view returns (uint256);

    function forceBurn(
        address account,
        uint256 amount,
        string memory reason
    ) external;

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function hasRole(bytes32 role, address account)
        external
        view
        returns (bool);

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool);

    function information() external view returns (string memory);

    function initialize(
        address admin,
        string memory nameIrrevocable,
        string memory symbolIrrevocable,
        uint8 decimalsIrrevocable,
        string memory tokenId_,
        string memory terms_,
        string memory information_,
        uint256 flag_
    ) external;

    function mint(address to, uint256 amount) external;

    function name() external view returns (string memory);

    function pause() external;

    function paused() external view returns (bool);

    function renounceRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function setFlag(uint256 flag_) external;

    function setInformation(string memory information_) external;

    function setTerms(string memory terms_) external;

    function setTokenId(string memory tokenId_) external;

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function symbol() external view returns (string memory);

    function terms() external view returns (string memory);

    function tokenId() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function unpause() external;
}
