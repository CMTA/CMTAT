/* 
 * Copyright (c) Capital Market and Technology Association, 2018-2019
 * https://cmta.ch
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. 
 */

pragma solidity ^0.5.3;

import "../zeppelin/ownership/Ownable.sol";
import "../interface/IFreezable.sol";

/**
 * @title Freezable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 *
 * @author Sébastien Krafft - <sebastien.krafft@mtpelerin.com>
 *
 * errors:
 * FR01: Token is frozen
 * FR02: Token is not frozen
 */


contract Freezable is IFreezable, Ownable {

  bool public frozen = false;

  /**
   * @dev Modifier to make a function callable only when the contract is not frozen.
   */
  modifier whenNotFrozen() {
    require(!frozen, "FR01");
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is frozen.
   */
  modifier whenFrozen() {
    require(frozen, "FR02");
    _;
  }

  /**
   * @dev called by the owner to freeze, triggers stopped state
   */
  function freeze() public onlyOwner whenNotFrozen {
    frozen = true;
    emit LogFrozen(now);
  }

  /**
   * @dev called by the owner to unfreeze, returns to normal state
   */
  function unfreeze() public onlyOwner whenFrozen {
    frozen = false;
    emit LogUnfrozen(now);
  }
}
