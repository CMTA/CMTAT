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
 * @title IDestroyable
 * @dev IDestroyable interface
 *
 * @author Sébastien Krafft - <sebastien.krafft@mtpelerin.com>
 *
 **/
 

interface IDestroyable {
  /**
  * Purpose;
  * To destroy issued tokens.
  *
  * Conditions:
  * Only issuer can execute this function.
  *
  * @param shareholders - list of shareholders
  */
  function destroy(address[] calldata shareholders) external;

  /**
  * Purpose:
  * This event is emitted when issued tokens are destroyed.
  *
  * @param shareholders - list of shareholders of destroyed tokens
  */
  event LogDestroyed(address[] shareholders);
}
