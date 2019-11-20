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
 * @title IReassignable
 * @dev IReassignable interface
 *
 * @author Sébastien Krafft - <sebastien.krafft@mtpelerin.com>
 *
 **/
 

interface IReassignable {
  /**
  * Purpose:
  * To withdraw tokens from the original address and
  * transfer those tokens to the replacement address.
  * Use in cases when e.g. investor loses access to his account.
  *
  * Conditions:
  * Throw error if the `original` address supplied is not a shareholder.
  * Throw error if the 'replacement' address already holds tokens.
  * Original address MUST NOT be reused again.
  * Only issuer can execute this function.
  *
  * @param original - original address
  * @param replacement - replacement address
    */
  function reassign(
    address original,
    address replacement
  ) 
    external;

  /**
  * Purpose:
  * This event is emitted when tokens are withdrawn from one address
  * and issued to a new one.
  *
  * @param original - original address
  * @param replacement - replacement address
  * @param value - amount transfered from original to replacement
  */
  event LogReassigned(
    address indexed original,
    address indexed replacement,
    uint256 value
  );
}
