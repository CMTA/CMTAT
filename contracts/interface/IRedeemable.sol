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
 * @title IRedeemable
 * @dev IRedeemable interface
 *
 * @author Sébastien Krafft - <sebastien.krafft@mtpelerin.com>
 *
 **/


interface IRedeemable {
  function redeem(uint256 value) external;

  /**
  * Purpose:
  * This event is emitted when tokens are redeemed.
  *
  * @param value - amount of redeemed tokens
  */
  event LogRedeemed(uint256 value);
}
