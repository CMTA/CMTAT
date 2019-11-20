/* 
 * Copyright (c) Capital Market and Technology Association, 2018-2019
 * https://cmta.ch
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. 
 */

pragma solidity ^0.5.3;

import "../lifecycle/Freezable.sol";

contract FreezableMock is Freezable {
  bool public isContractFrozen;
  uint256 public count;

  constructor() public {
    isContractFrozen = false;
    count = 0;
  }

  function normalProcess() external whenNotFrozen {
    count++;
  }

  function actionWhenFrozen() external whenFrozen {
    isContractFrozen = true;
  }
}
