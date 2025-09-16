// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC165 } from "@openzeppelin/contracts/interfaces/IERC165.sol";


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
interface IERC5679 is IERC5679Mint, IERC5679Burn{} 



