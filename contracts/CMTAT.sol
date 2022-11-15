//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

// required OZ imports here
import "../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../openzeppelin-contracts-upgradeable/contracts/utils/ContextUpgradeable.sol";
import "./modules/BaseModule.sol";
import "./modules/AuthorizationModule.sol";
import "./modules/BurnModule.sol";
import "./modules/MintModule.sol";
import "./modules/BurnModule.sol";
import "./modules/EnforcementModule.sol";
import "./modules/PauseModule.sol";
import "./modules/ValidationModule.sol";
import "./modules/MetaTxModule.sol";
import "./modules/SnapshotModule.sol";
import "./interfaces/IRuleEngine.sol";

contract CMTAT is
    Initializable,
    ContextUpgradeable,
    BaseModule,
    PauseModule,
    MintModule,
    BurnModule,
    EnforcementModule,
    ValidationModule,
    MetaTxModule,
    SnapshotModule
{
    enum REJECTED_CODE { TRANSFER_OK, TRANSFER_REJECTED_PAUSED, TRANSFER_REJECTED_FROZEN }
    string constant TEXT_TRANSFER_OK = "No restriction";
   
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address forwarder
    ) MetaTxModule(forwarder) {
    }

    function initialize(
        address owner,
        string memory name,
        string memory symbol,
        string memory tokenId,
        string memory terms
    ) public initializer {
        __CMTAT_init(owner, name, symbol, tokenId, terms);
    }

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE` and `PAUSER_ROLE` to the
     * account that deploys the contract.
     *
     * See {ERC20-constructor}.
     */
    function __CMTAT_init(
        address owner,
        string memory name,
        string memory symbol,
        string memory tokenId,
        string memory terms
    ) internal onlyInitializing {
        __Context_init_unchained();
        __Base_init_unchained(0, tokenId, terms);
        __AccessControl_init_unchained();
        __ERC20_init_unchained(name, symbol);
        __Pausable_init_unchained();
        __Enforcement_init_unchained();
        __Snapshot_init_unchained();
        __CMTAT_init_unchained(owner);
    }

    function __CMTAT_init_unchained(address owner) internal onlyInitializing {
        _setupRole(DEFAULT_ADMIN_ROLE, owner);
        _setupRole(ENFORCER_ROLE, owner);
        _setupRole(MINTER_ROLE, owner);
        _setupRole(BURNER_ROLE, owner);
        _setupRole(PAUSER_ROLE, owner);
        _setupRole(SNAPSHOOTER_ROLE, owner);
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /**
     * @dev Freezes an address.
     *
     */
    function freeze(address account)
        public
        onlyRole(ENFORCER_ROLE)
        returns (bool)
    {
        return _freeze(account);
    }

    /**
     * @dev Unfreezes an address.
     *
     */
    function unfreeze(address account)
        public
        onlyRole(ENFORCER_ROLE)
        returns (bool)
    {
        return _unfreeze(account);
    }

    function decimals()
        public
        view
        virtual
        override(ERC20Upgradeable, BaseModule)
        returns (uint8)
    {
        return super.decimals();
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override(ERC20Upgradeable, BaseModule) returns (bool) {
        return super.transferFrom(sender, recipient, amount);
    }

    /**
     * @dev ERC1404 check if _value token can be transferred from _from to _to
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param amount uint256 the amount of tokens to be transferred
     * @return code of the rejection reason
     */
    function detectTransferRestriction(
        address from,
        address to,
        uint256 amount
    ) public view returns (uint8 code) {
        if (paused()) {
            return uint8(REJECTED_CODE.TRANSFER_REJECTED_PAUSED);
        } else if (frozen(from)) {
            return uint8(REJECTED_CODE.TRANSFER_REJECTED_FROZEN);
        } else if (address(ruleEngine) != address(0)) {
            return _detectTransferRestriction(from, to, amount);
        }
        return uint8(REJECTED_CODE.TRANSFER_OK);
    }

    /**
     * @dev ERC1404 returns the human readable explaination corresponding to the error code returned by detectTransferRestriction
     * @param restrictionCode The error code returned by detectTransferRestriction
     * @return message The human readable explaination corresponding to the error code returned by detectTransferRestriction
     */
    function messageForTransferRestriction(uint8 restrictionCode)
        external
        view
        returns (string memory message)
    {
        if (restrictionCode == uint8(REJECTED_CODE.TRANSFER_OK)) {
            return TEXT_TRANSFER_OK;
        } else if (restrictionCode == uint8(REJECTED_CODE.TRANSFER_REJECTED_PAUSED)) {
            return TEXT_TRANSFER_REJECTED_PAUSED;
        } else if (restrictionCode == uint8(REJECTED_CODE.TRANSFER_REJECTED_FROZEN)) {
            return TEXT_TRANSFER_REJECTED_FROZEN;
        } else if (address(ruleEngine) != address(0)) {
            return _messageForTransferRestriction(restrictionCode);
        }
    }

    function scheduleSnapshot(uint256 time)
        public
        onlyRole(SNAPSHOOTER_ROLE)
    {
        _scheduleSnapshot(time);
    }

    function rescheduleSnapshot(uint256 oldTime, uint256 newTime)
        public
        onlyRole(SNAPSHOOTER_ROLE)
    {
        _rescheduleSnapshot(oldTime, newTime);
    }

    function unscheduleSnapshot(uint256 time)
        public
        onlyRole(SNAPSHOOTER_ROLE)
    {
        _unscheduleSnapshot(time);
    }



    /// @custom:oz-upgrades-unsafe-allow selfdestruct
    function kill() public onlyRole(DEFAULT_ADMIN_ROLE) {
        selfdestruct(payable(_msgSender()));
    }

    function setRuleEngine(IRuleEngine ruleEngine_)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        ruleEngine = ruleEngine_;
        emit RuleEngineSet(address(ruleEngine_));
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(SnapshotModule, ERC20Upgradeable) {
        require(!paused(), "CMTAT: token transfer while paused");
        require(!frozen(from), "CMTAT: token transfer while frozen");

        super._beforeTokenTransfer(from, to, amount);

        if (address(ruleEngine) != address(0)) {
            require(
                _validateTransfer(from, to, amount),
                "CMTAT: transfer rejected by validation module"
            );
        }
    }

    function _msgSender()
        internal
        view
        override(ERC2771ContextUpgradeable, ContextUpgradeable)
        returns (address sender)
    {
        return super._msgSender();
    }

    function _msgData()
        internal
        view
        override(ERC2771ContextUpgradeable, ContextUpgradeable)
        returns (bytes calldata)
    {
        return super._msgData();
    }

    uint256[50] private __gap;
}
