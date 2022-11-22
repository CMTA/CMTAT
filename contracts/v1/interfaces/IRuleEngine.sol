pragma solidity ^0.8.2;

import "./IRule.sol";

interface IRuleEngineV1 {

  function setRules(IRuleV1[] calldata rules_) external;
  function ruleLength() external view returns (uint256);
  function rule(uint256 ruleId) external view returns (IRuleV1);
  function rules() external view returns(IRuleV1[] memory);

  function validateTransfer(
    address _from,
    address _to,
    uint256 _amount)
  external view returns (bool);

  function detectTransferRestriction (
    address _from,
    address _to,
    uint256 _value)
  external view returns (uint8);

  function messageForTransferRestriction (uint8 _restrictionCode) external view returns (string memory);
}
