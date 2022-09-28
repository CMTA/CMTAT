//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.2;

import "../interfaces/IRule.sol";


contract RuleMock is IRule {
  uint8 constant AMOUNT_TOO_HIGH = 10;
  string constant TEXT_AMOUNT_TOO_HIGH = "Amount too high";
  string constant TEXT_CODE_NOT_FOUND = "Code not found";

  function isTransferValid(
    address _from, address _to, uint256 _amount)
  public pure override returns (bool isValid)
  {
    return detectTransferRestriction(_from, _to, _amount) == 0;
  }

  function detectTransferRestriction(
    address /* _from */, address /* _to */, uint256 _amount)
  public pure override returns (uint8)
  {
    return _amount < 20 ? 0 : AMOUNT_TOO_HIGH;
  }

  function canReturnTransferRestrictionCode(uint8 _restrictionCode) public pure override returns (bool) {
    return _restrictionCode == AMOUNT_TOO_HIGH;
  }

  function messageForTransferRestriction(uint8 _restrictionCode) external pure override returns (string memory) {
    return _restrictionCode == AMOUNT_TOO_HIGH ? TEXT_AMOUNT_TOO_HIGH : TEXT_CODE_NOT_FOUND;
  }
}
