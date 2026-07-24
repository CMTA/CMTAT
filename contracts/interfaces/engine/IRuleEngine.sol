// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IERC1404Extend} from "../tokenization/draft-IERC1404.sol";
import {IERC3643IComplianceContract} from "../tokenization/IERC3643Partial.sol";
import {IERC7551Compliance} from "../tokenization/draft-IERC7551.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/*
* @title IRuleEngine - Minimal interface to define a RuleEngine
*/
interface IRuleEngine is IERC7551Compliance, IERC3643IComplianceContract, IERC165 {
    /**
     *  @notice
     *  Function called whenever tokens are transferred from one wallet to another
     *  @dev
     *  Must revert if the transfer is invalid
     *  Same name as ERC-3643 but with one supplementary argument `spender`
     *  This function can be used to update state variables of the RuleEngine contract
     *  This function can be called ONLY by the token contract bound to the RuleEngine
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
