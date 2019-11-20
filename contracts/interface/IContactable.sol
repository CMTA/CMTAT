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
 * @title IContactable
 * @dev IContactable interface
 *
 * @author Sébastien Krafft - <sebastien.krafft@mtpelerin.com>
 *
 **/


interface IContactable {
  function contact() external view returns (string memory);
  function setContact(string calldata _contact) external;

  /**
  * Purpose:
  * This event is emitted when the contact information is changed
  *
  * @param contact - new contact information
  */
  event LogContactSet(string contact);
}
