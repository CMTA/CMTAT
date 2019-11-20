/* 
 * Copyright (c) Capital Market and Technology Association, 2018-2019
 * https://cmta.ch
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. 
 */

pragma solidity ^0.5.3;

/**
 * @title IFreezable
 * @dev IFreezable interface
 *
 * @author Sébastien Krafft - <sebastien.krafft@mtpelerin.com>
 *
 **/


interface IFreezable {
  /**
  * Purpose:
  * To pause transfer of tokens.
  *
  * Conditions:
  * Only issuer can execute this function.
  *
  */
  function freeze() external;

  /**
  * Purpose:
  * To resume ('unpause') transfer of tokens.
  *
  * Conditions:
  * Only issuer can execute this function.
  *
  */
  function unfreeze() external;

  /**
  * Purpose:
  * This event is emitted when transfer of tokens is frozen.
  *
  * @param timestamp - block timestamp when transfer of tokens 
  * was paused
  */
  event LogFrozen(uint256 timestamp);

  /**
  * Purpose:
  * This event is emitted when transfer of tokens is 
  * resumed ('unfrozen').
  *
  * @param timestamp - block timestamp when transfer of tokens 
  * was resumed ('unfrozen').
  */
  event LogUnfrozen(uint256 timestamp);
}
