Solidity supports a special documentation comment format called **NatSpec (Ethereum Natural Language Specification Format)**, used to describe functions, return values, and other contract elements. NatSpec is inspired by Doxygen but is not fully compatible with it.

Solidity developers are encouraged to fully annotate all public interfaces (ABI) using NatSpec.

The Solidity compiler understands NatSpec comments and can extract them into a **machine-readable format**. NatSpec also supports **custom annotations** (e.g., `@custom:<name>`) for use by third-party tools like analysis and verification systems.



## Documentation Example

Documentation is inserted above each `contract`, `interface`, `library`, `function`, and `event` using the Doxygen notation format. A `public` state variable is equivalent to a `function` for the purposes of NatSpec.

- For Solidity you may choose `///` for single or multi-line comments, or `/**` and ending with `*/`.

The following example shows a contract and a function using all available tags.

Note

The Solidity compiler only interprets tags if they are external or public. You are welcome to use similar comments for your internal and private functions, but those will not be parsed.

This may change in the future.

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 < 0.9.0;

/// @title A simulator for trees
/// @author Larry A. Gardner
/// @notice You can use this contract for only the most basic simulation
/// @dev All function calls are currently implemented without side effects
/// @custom:experimental This is an experimental contract.
contract Tree {
    /// @notice Calculate tree age in years, rounded up, for live trees
    /// @dev The Alexandr N. Tetearing algorithm could increase precision
    /// @param rings The number of rings from dendrochronological sample
    /// @return Age in years, rounded up for partial years
    function age(uint256 rings) external virtual pure returns (uint256) {
        return rings + 1;
    }

    /// @notice Returns the amount of leaves the tree has.
    /// @dev Returns only a fixed number.
    function leaves() external virtual pure returns(uint256) {
        return 2;
    }
}

contract Plant {
    function leaves() external virtual pure returns(uint256) {
        return 3;
    }
}

contract KumquatTree is Tree, Plant {
    function age(uint256 rings) external override pure returns (uint256) {
        return rings + 2;
    }

    /// Return the amount of leaves that this specific kind of tree has
    /// @inheritdoc Tree
    function leaves() external override(Tree, Plant) pure returns(uint256) {
        return 3;
    }
}
```



## Tags

All tags are optional. The following table explains the purpose of each NatSpec tag and where it may be used. As a special case, if no tags are used then the Solidity compiler will interpret a `///` or `/**` comment in the same way as if it were tagged with `@notice`.

| Tag           |                                                              | Context                                                      |
| ------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| `@title`      | A title that should describe the contract/interface          | contract, library, interface                                 |
| `@author`     | The name of the author                                       | contract, library, interface                                 |
| `@notice`     | Explain to an end user what this does                        | contract, library, interface, function, public state variable, event |
| `@dev`        | Explain to a developer any extra details                     | contract, library, interface, function, state variable, event |
| `@param`      | Documents a parameter just like in Doxygen (must be followed by parameter name) | function, event                                              |
| `@return`     | Documents the return variables of a contract’s function      | function, public state variable                              |
| `@inheritdoc` | Copies all missing tags from the base function (must be followed by the contract name) | function, public state variable                              |
| `@custom:...` | Custom tag, semantics is application-defined                 | everywhere                                                   |

If your function returns multiple values, like `(int quotient, int remainder)` then use multiple `@return` statements in the same format as the `@param` statements.

Custom tags start with `@custom:` and must be followed by one or more lowercase letters or hyphens. It cannot start with a hyphen however. They can be used everywhere and are part of the developer documentation.



### Inheritance Notes

Functions without NatSpec will automatically inherit the documentation of their base function. Exceptions to this are:

- When the parameter names are different.
- When there is more than one base function.
- When there is an explicit `@inheritdoc` tag which specifies which contract should be used to inherit.