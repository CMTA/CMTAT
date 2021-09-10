pragma solidity ^0.8.2;

// required OZ imports here
import "../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";


abstract contract BaseModule is Initializable, ERC20Upgradeable {
    /* Events */
    event Spend (address indexed owner, address indexed spender, uint amount);

    /* Variables */
    uint8 private _decimals;
    string public tokenId;
    string public terms;

    /* Initializers */
    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function __Base_init(string memory name_, string memory symbol_, uint8 decimals_, string memory tokenId_, string memory terms_) internal initializer {
        __ERC20_init(name_, symbol_);
        _decimals = decimals_;
        tokenId = tokenId_;
        terms = terms_;
    }

    function __Base_init_unchained(uint8 decimals_, string memory tokenId_, string memory terms_) internal initializer {
        _decimals = decimals_;
        tokenId = tokenId_;
        terms = terms_;
    }

    /* Methods */
    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        bool result = super.transferFrom(sender, recipient, amount);
        if (result == true) {
            emit Spend(sender, _msgSender(), amount);
        }

        return result;
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount, uint256 currentAllowance) public virtual returns (bool) {
        require(allowance(_msgSender(), spender) == currentAllowance, "CMTAT: current allowance is not right");
        super.approve(spender, amount);
        return true;
    }

    uint256[50] private __gap;
}