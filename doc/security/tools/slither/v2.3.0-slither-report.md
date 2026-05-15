# Slither report

Summary

 - [suicidal](#suicidal) (1 results) (High)
 - [calls-loop](#calls-loop) (3 results) (Low)
 - [timestamp](#timestamp) (6 results) (Low)
 - [dead-code](#dead-code) (16 results) (Informational)
 - [solc-version](#solc-version) (29 results) (Informational)
 - [naming-convention](#naming-convention) (65 results) (Informational)
 - [unused-state](#unused-state) (1 results) (Informational)
 - [constable-states](#constable-states) (1 results) (Optimization)
 - [immutable-states](#immutable-states) (1 results) (Optimization)
## suicidal
Impact: High
Confidence: High
 - [ ] ID-0
[BaseModule.kill()](contracts/modules/wrapper/mandatory/BaseModule.sol#L114-L120) allows anyone to destruct the contract

contracts/modules/wrapper/mandatory/BaseModule.sol#L114-L120

> Remark:
>
> The function is protected by an access control.
>
> Only an address with the role (DEFAULT_ADMIN_ROLE) can call this function

## calls-loop

> Remark:
>
> - The RuleEngine is a trusted contract deployed by the issuer.
>
> It is not a problem to perform external call to this contract
>
> - When a ruleEngine is created, the issuer has indeed to keep in mind to limit the number of rules.



Impact: Low
Confidence: Medium
 - [ ] ID-1
[RuleEngineMock.messageForTransferRestriction(uint8)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L72-L83) has external calls inside a loop: [_rules[i].canReturnTransferRestrictionCode(_restrictionCode)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L77)

contracts/mocks/RuleEngine/RuleEngineMock.sol#L72-L83


 - [ ] ID-2
[RuleEngineMock.messageForTransferRestriction(uint8)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L72-L83) has external calls inside a loop: [_rules[i].messageForTransferRestriction(_restrictionCode)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L78-L79)

contracts/mocks/RuleEngine/RuleEngineMock.sol#L72-L83


 - [ ] ID-3
[RuleEngineMock.detectTransferRestriction(address,address,uint256)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L41-L58) has external calls inside a loop: [restriction = _rules[i].detectTransferRestriction(_from,_to,_amount)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L48-L52)

contracts/mocks/RuleEngine/RuleEngineMock.sol#L41-L58


## timestamp
> Remark:
>
> With the Proof of Work, it was possible for a miner to modify the timestamp in a range of about 15 seconds
>
> With the Proof Of Stake, a new block is created every 12 seconds
>
> In all cases, we are not looking for such precision

Impact: Low
Confidence: Medium

 - [ ] ID-4
	[SnapshotModuleInternal._unscheduleLastSnapshot(uint256)](contracts/modules/internal/SnapshotModuleInternal.sol#L158-L169) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(time > block.timestamp,Snapshot already done)](contracts/modules/internal/SnapshotModuleInternal.sol#L160)

contracts/modules/internal/SnapshotModuleInternal.sol#L158-L169


 - [ ] ID-5
	[SnapshotModuleInternal._scheduleSnapshot(uint256)](contracts/modules/internal/SnapshotModuleInternal.sol#L83-L96) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(time > block.timestamp,Snapshot scheduled in the past)](contracts/modules/internal/SnapshotModuleInternal.sol#L85)

contracts/modules/internal/SnapshotModuleInternal.sol#L83-L96


 - [ ] ID-6
	[SnapshotModuleInternal._unscheduleSnapshotNotOptimized(uint256)](contracts/modules/internal/SnapshotModuleInternal.sol#L177-L188) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(time > block.timestamp,Snapshot already done)](contracts/modules/internal/SnapshotModuleInternal.sol#L178)

contracts/modules/internal/SnapshotModuleInternal.sol#L177-L188


 - [ ] ID-7
	[SnapshotModuleInternal._findScheduledMostRecentPastSnapshot()](contracts/modules/internal/SnapshotModuleInternal.sol#L413-L438) uses timestamp for comparisons
	Dangerous comparisons:
	- [_scheduledSnapshots[i] <= block.timestamp](contracts/modules/internal/SnapshotModuleInternal.sol#L429)

contracts/modules/internal/SnapshotModuleInternal.sol#L413-L438


 - [ ] ID-8
	[SnapshotModuleInternal._rescheduleSnapshot(uint256,uint256)](contracts/modules/internal/SnapshotModuleInternal.sol#L127-L153) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(oldTime > block.timestamp,Snapshot already done)](contracts/modules/internal/SnapshotModuleInternal.sol#L129)
	- [require(bool,string)(newTime > block.timestamp,Snapshot scheduled in the past)](contracts/modules/internal/SnapshotModuleInternal.sol#L130)

contracts/modules/internal/SnapshotModuleInternal.sol#L127-L153


 - [ ] ID-9
	[SnapshotModuleInternal._scheduleSnapshotNotOptimized(uint256)](contracts/modules/internal/SnapshotModuleInternal.sol#L101-L122) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(time > block.timestamp,Snapshot scheduled in the past)](contracts/modules/internal/SnapshotModuleInternal.sol#L102)

contracts/modules/internal/SnapshotModuleInternal.sol#L101-L122

## dead-code

> Remark:
>
> function init: 
>
> We have theses dead codes because we follow the same architecture and
> principle as OpenZeppelin,
>
> For example:https://github.com/OpenZeppelin/openzeppelin-contracts-
> upgradeable/blob/master/contracts/access/AccessControlUpgradeable.
>
> sol#L51
>
> ID-15 - msgData:
>
> - Implemented to be gasless compatible (see MetaTxModule)
>
> - If we remove this function, we will have the following error:
>
>   "Derived contract must override function "_msgData". Two or more base classes define function with same name and parameter types."

Impact: Informational
Confidence: Medium
 - [ ] ID-10
[ValidationModule.__ValidationModule_init(IEIP1404Wrapper,address)](contracts/modules/wrapper/optional/ValidationModule.sol#L25-L49) is never used and should be removed

contracts/modules/wrapper/optional/ValidationModule.sol#L25-L49


 - [ ] ID-11
[EnforcementModule.__EnforcementModule_init(address)](contracts/modules/wrapper/mandatory/EnforcementModule.sol#L25-L42) is never used and should be removed

contracts/modules/wrapper/mandatory/EnforcementModule.sol#L25-L42


 - [ ] ID-12
[SnapshotModule.__SnasphotModule_init(string,string,address)](contracts/modules/wrapper/optional/SnapshotModule.sol#L19-L42) is never used and should be removed

contracts/modules/wrapper/optional/SnapshotModule.sol#L19-L42


 - [ ] ID-13
[MetaTxModule._msgData()](contracts/modules/wrapper/optional/MetaTxModule.sol#L33-L41) is never used and should be removed

contracts/modules/wrapper/optional/MetaTxModule.sol#L33-L41


 - [ ] ID-14
[BurnModule.__BurnModule_init(string,string,address)](contracts/modules/wrapper/mandatory/BurnModule.sol#L12-L31) is never used and should be removed

contracts/modules/wrapper/mandatory/BurnModule.sol#L12-L31


 - [ ] ID-15
[CMTAT_BASE._msgData()](contracts/modules/CMTAT_BASE.sol#L195-L202) is never used and should be removed

contracts/modules/CMTAT_BASE.sol#L195-L202


 - [ ] ID-16
[ERC20BaseModule.__ERC20Module_init(string,string,uint8)](contracts/modules/wrapper/mandatory/ERC20BaseModule.sol#L23-L34) is never used and should be removed

contracts/modules/wrapper/mandatory/ERC20BaseModule.sol#L23-L34


 - [ ] ID-17
[MintModule.__MintModule_init(string,string,address)](contracts/modules/wrapper/mandatory/MintModule.sol#L12-L31) is never used and should be removed

contracts/modules/wrapper/mandatory/MintModule.sol#L12-L31


 - [ ] ID-18
[PauseModule.__PauseModule_init(address)](contracts/modules/wrapper/mandatory/PauseModule.sol#L20-L35) is never used and should be removed

contracts/modules/wrapper/mandatory/PauseModule.sol#L20-L35


 - [ ] ID-19
[SnapshotModuleInternal.__Snapshot_init(string,string)](contracts/modules/internal/SnapshotModuleInternal.sol#L65-L72) is never used and should be removed

contracts/modules/internal/SnapshotModuleInternal.sol#L65-L72


 - [ ] ID-20
[AuthorizationModule.__AuthorizationModule_init(address)](contracts/modules/security/AuthorizationModule.sol#L25-L36) is never used and should be removed

contracts/modules/security/AuthorizationModule.sol#L25-L36


 - [ ] ID-21
[ValidationModuleInternal.__Validation_init(IEIP1404Wrapper)](contracts/modules/internal/ValidationModuleInternal.sol#L28-L33) is never used and should be removed

contracts/modules/internal/ValidationModuleInternal.sol#L28-L33


 - [ ] ID-22
[DebtBaseModule.__DebtBaseModule_init(address)](contracts/modules/wrapper/optional/DebtModule/DebtBaseModule.sol#L59-L74) is never used and should be removed

contracts/modules/wrapper/optional/DebtModule/DebtBaseModule.sol#L59-L74


 - [ ] ID-23
[EnforcementModuleInternal.__Enforcement_init()](contracts/modules/internal/EnforcementModuleInternal.sol#L43-L46) is never used and should be removed

contracts/modules/internal/EnforcementModuleInternal.sol#L43-L46


 - [ ] ID-24
[BaseModule.__Base_init(string,string,string,uint256,address)](contracts/modules/wrapper/mandatory/BaseModule.sol#L35-L55) is never used and should be removed

contracts/modules/wrapper/mandatory/BaseModule.sol#L35-L55


 - [ ] ID-25
[CreditEventsModule.__CreditEvents_init(address)](contracts/modules/wrapper/optional/DebtModule/CreditEventsModule.sol#L23-L38) is never used and should be removed

contracts/modules/wrapper/optional/DebtModule/CreditEventsModule.sol#L23-L38

## solc-version

> Remark:
>
> Not necessary, the latest solidity version at the time of this release is the version 0.8.20.
> The comment is good but we think three versions backwards is enough.
> It is not the best practice to use an outdated version because each version
> fixes some bugs.

Impact: Informational
Confidence: High
 - [ ] ID-26
Pragma version[^0.8.17](contracts/modules/wrapper/mandatory/BaseModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/wrapper/mandatory/BaseModule.sol#L3


 - [ ] ID-27
Pragma version[^0.8.17](contracts/modules/CMTAT_BASE.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/CMTAT_BASE.sol#L3


 - [ ] ID-28
Pragma version[^0.8.17](contracts/modules/wrapper/optional/SnapshotModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/wrapper/optional/SnapshotModule.sol#L3


 - [ ] ID-29
Pragma version[^0.8.17](contracts/modules/wrapper/mandatory/MintModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/wrapper/mandatory/MintModule.sol#L3


 - [ ] ID-30
Pragma version[^0.8.17](contracts/modules/wrapper/mandatory/PauseModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/wrapper/mandatory/PauseModule.sol#L3


 - [ ] ID-31
Pragma version[^0.8.17](contracts/modules/internal/EnforcementModuleInternal.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/internal/EnforcementModuleInternal.sol#L3


 - [ ] ID-32
Pragma version[^0.8.17](contracts/CMTAT_PROXY.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/CMTAT_PROXY.sol#L3


 - [ ] ID-33
Pragma version[^0.8.17](contracts/modules/wrapper/optional/MetaTxModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/wrapper/optional/MetaTxModule.sol#L3


 - [ ] ID-34
Pragma version[^0.8.17](contracts/modules/wrapper/optional/DebtModule/CreditEventsModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/wrapper/optional/DebtModule/CreditEventsModule.sol#L3


 - [ ] ID-35
Pragma version[^0.8.0](contracts/mocks/RuleEngine/interfaces/IRuleEngine.sol#L3) allows old versions

contracts/mocks/RuleEngine/interfaces/IRuleEngine.sol#L3


 - [ ] ID-36
Pragma version[^0.8.0](contracts/interfaces/IEIP1404/IEIP1404.sol#L3) allows old versions

contracts/interfaces/IEIP1404/IEIP1404.sol#L3


 - [ ] ID-37
Pragma version[^0.8.17](contracts/mocks/RuleEngine/RuleMock.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/mocks/RuleEngine/RuleMock.sol#L3


 - [ ] ID-38
Pragma version[^0.8.0](contracts/mocks/RuleEngine/interfaces/IRule.sol#L3) allows old versions

contracts/mocks/RuleEngine/interfaces/IRule.sol#L3


 - [ ] ID-39
solc-0.8.17 is not recommended for deployment

 - [ ] ID-40
Pragma version[^0.8.17](contracts/modules/wrapper/mandatory/ERC20BaseModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/wrapper/mandatory/ERC20BaseModule.sol#L3


 - [ ] ID-41
Pragma version[^0.8.0](contracts/interfaces/IDebtGlobal.sol#L3) allows old versions

contracts/interfaces/IDebtGlobal.sol#L3


 - [ ] ID-42
Pragma version[^0.8.17](contracts/modules/internal/SnapshotModuleInternal.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/internal/SnapshotModuleInternal.sol#L3


 - [ ] ID-43
Pragma version[^0.8.17](contracts/modules/wrapper/optional/DebtModule/DebtBaseModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/wrapper/optional/DebtModule/DebtBaseModule.sol#L3


 - [ ] ID-44
Pragma version[^0.8.17](contracts/modules/wrapper/mandatory/EnforcementModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/wrapper/mandatory/EnforcementModule.sol#L3


 - [ ] ID-45
Pragma version[^0.8.17](contracts/modules/security/AuthorizationModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/security/AuthorizationModule.sol#L3


 - [ ] ID-46
Pragma version[^0.8.17](contracts/modules/internal/ValidationModuleInternal.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/internal/ValidationModuleInternal.sol#L3


 - [ ] ID-47
Pragma version[^0.8.17](contracts/modules/wrapper/mandatory/BurnModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/wrapper/mandatory/BurnModule.sol#L3


 - [ ] ID-48
Pragma version[^0.8.0](contracts/interfaces/IEIP1404/IEIP1404Wrapper.sol#L3) allows old versions

contracts/interfaces/IEIP1404/IEIP1404Wrapper.sol#L3


 - [ ] ID-49
Pragma version[^0.8.17](contracts/modules/wrapper/optional/ValidationModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/wrapper/optional/ValidationModule.sol#L3


 - [ ] ID-50
Pragma version[^0.8.17](contracts/mocks/RuleEngine/CodeList.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/mocks/RuleEngine/CodeList.sol#L3


 - [ ] ID-51
Pragma version[^0.8.17](contracts/CMTAT_STANDALONE.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/CMTAT_STANDALONE.sol#L3


 - [ ] ID-52
Pragma version[^0.8.17](contracts/mocks/MinimalForwarderMock.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/mocks/MinimalForwarderMock.sol#L3


 - [ ] ID-53
Pragma version[^0.8.17](contracts/modules/security/OnlyDelegateCallModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/security/OnlyDelegateCallModule.sol#L3


 - [ ] ID-54
Pragma version[^0.8.17](contracts/mocks/RuleEngine/RuleEngineMock.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/mocks/RuleEngine/RuleEngineMock.sol#L3

## naming-convention

> Remark:
>
> It is not really necessary to rename all the variables. It will generate a lot of work for a minor improvement.



Impact: Informational
Confidence: High

 - [ ] ID-55
Variable [RuleEngineMock._rules](contracts/mocks/RuleEngine/RuleEngineMock.sol#L15) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L15


 - [ ] ID-56
Function [SnapshotModule.__SnasphotModule_init(string,string,address)](contracts/modules/wrapper/optional/SnapshotModule.sol#L19-L42) is not in mixedCase

contracts/modules/wrapper/optional/SnapshotModule.sol#L19-L42


 - [ ] ID-57
Variable [CreditEventsModule.__gap](contracts/modules/wrapper/optional/DebtModule/CreditEventsModule.sol#L91) is not in mixedCase

contracts/modules/wrapper/optional/DebtModule/CreditEventsModule.sol#L91


 - [ ] ID-58
Function [EnforcementModuleInternal.__Enforcement_init()](contracts/modules/internal/EnforcementModuleInternal.sol#L43-L46) is not in mixedCase

contracts/modules/internal/EnforcementModuleInternal.sol#L43-L46


 - [ ] ID-59
Function [MintModule.__MintModule_init(string,string,address)](contracts/modules/wrapper/mandatory/MintModule.sol#L12-L31) is not in mixedCase

contracts/modules/wrapper/mandatory/MintModule.sol#L12-L31


 - [ ] ID-60
Enum [IEIP1404Wrapper.REJECTED_CODE_BASE](contracts/interfaces/IEIP1404/IEIP1404Wrapper.sol#L11-L16) is not in CapWords

contracts/interfaces/IEIP1404/IEIP1404Wrapper.sol#L11-L16


 - [ ] ID-61
Parameter [RuleEngineMock.detectTransferRestriction(address,address,uint256)._amount](contracts/mocks/RuleEngine/RuleEngineMock.sol#L44) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L44


 - [ ] ID-62
Variable [BurnModule.__gap](contracts/modules/wrapper/mandatory/BurnModule.sol#L51) is not in mixedCase

contracts/modules/wrapper/mandatory/BurnModule.sol#L51


 - [ ] ID-63
Function [ValidationModuleInternal.__Validation_init(IEIP1404Wrapper)](contracts/modules/internal/ValidationModuleInternal.sol#L28-L33) is not in mixedCase

contracts/modules/internal/ValidationModuleInternal.sol#L28-L33


 - [ ] ID-64
Contract [CMTAT_PROXY](contracts/CMTAT_PROXY.sol#L8-L25) is not in CapWords

contracts/CMTAT_PROXY.sol#L8-L25


 - [ ] ID-65
Function [PauseModule.__PauseModule_init_unchained()](contracts/modules/wrapper/mandatory/PauseModule.sol#L37-L39) is not in mixedCase

contracts/modules/wrapper/mandatory/PauseModule.sol#L37-L39


 - [ ] ID-66
Function [CreditEventsModule.__CreditEvents_init_unchained()](contracts/modules/wrapper/optional/DebtModule/CreditEventsModule.sol#L40-L42) is not in mixedCase

contracts/modules/wrapper/optional/DebtModule/CreditEventsModule.sol#L40-L42


 - [ ] ID-67
Variable [CMTAT_BASE.__gap](contracts/modules/CMTAT_BASE.sol#L204) is not in mixedCase

contracts/modules/CMTAT_BASE.sol#L204


 - [ ] ID-68
Function [EnforcementModuleInternal.__Enforcement_init_unchained()](contracts/modules/internal/EnforcementModuleInternal.sol#L48-L50) is not in mixedCase

contracts/modules/internal/EnforcementModuleInternal.sol#L48-L50


 - [ ] ID-69
Variable [ValidationModuleInternal.__gap](contracts/modules/internal/ValidationModuleInternal.sol#L75) is not in mixedCase

contracts/modules/internal/ValidationModuleInternal.sol#L75


 - [ ] ID-70
Function [EnforcementModule.__EnforcementModule_init(address)](contracts/modules/wrapper/mandatory/EnforcementModule.sol#L25-L42) is not in mixedCase

contracts/modules/wrapper/mandatory/EnforcementModule.sol#L25-L42


 - [ ] ID-71
Variable [SnapshotModuleInternal.__gap](contracts/modules/internal/SnapshotModuleInternal.sol#L440) is not in mixedCase

contracts/modules/internal/SnapshotModuleInternal.sol#L440


 - [ ] ID-72
Variable [BaseModule.__gap](contracts/modules/wrapper/mandatory/BaseModule.sol#L122) is not in mixedCase

contracts/modules/wrapper/mandatory/BaseModule.sol#L122


 - [ ] ID-73
Variable [ValidationModule.__gap](contracts/modules/wrapper/optional/ValidationModule.sol#L139) is not in mixedCase

contracts/modules/wrapper/optional/ValidationModule.sol#L139


 - [ ] ID-74
Variable [MintModule.__gap](contracts/modules/wrapper/mandatory/MintModule.sol#L51) is not in mixedCase

contracts/modules/wrapper/mandatory/MintModule.sol#L51


 - [ ] ID-75
Variable [EnforcementModule.__gap](contracts/modules/wrapper/mandatory/EnforcementModule.sol#L74) is not in mixedCase

contracts/modules/wrapper/mandatory/EnforcementModule.sol#L74


 - [ ] ID-76
Contract [CMTAT_STANDALONE](contracts/CMTAT_STANDALONE.sol#L8-L50) is not in CapWords

contracts/CMTAT_STANDALONE.sol#L8-L50


 - [ ] ID-77
Variable [DebtBaseModule.__gap](contracts/modules/wrapper/optional/DebtModule/DebtBaseModule.sol#L261) is not in mixedCase

contracts/modules/wrapper/optional/DebtModule/DebtBaseModule.sol#L261


 - [ ] ID-78
Variable [AuthorizationModule.__gap](contracts/modules/security/AuthorizationModule.sol#L61) is not in mixedCase

contracts/modules/security/AuthorizationModule.sol#L61


 - [ ] ID-79
Parameter [RuleEngineMock.validateTransfer(address,address,uint256)._amount](contracts/mocks/RuleEngine/RuleEngineMock.sol#L63) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L63


 - [ ] ID-80
Parameter [RuleMock.validateTransfer(address,address,uint256)._to](contracts/mocks/RuleEngine/RuleMock.sol#L15) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L15


 - [ ] ID-81
Function [ERC20BaseModule.__ERC20Module_init_unchained(uint8)](contracts/modules/wrapper/mandatory/ERC20BaseModule.sol#L36-L40) is not in mixedCase

contracts/modules/wrapper/mandatory/ERC20BaseModule.sol#L36-L40


 - [ ] ID-82
Variable [EnforcementModuleInternal.__gap](contracts/modules/internal/EnforcementModuleInternal.sol#L91) is not in mixedCase

contracts/modules/internal/EnforcementModuleInternal.sol#L91


 - [ ] ID-83
Parameter [RuleMock.canReturnTransferRestrictionCode(uint8)._restrictionCode](contracts/mocks/RuleEngine/RuleMock.sol#L33) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L33


 - [ ] ID-84
Function [AuthorizationModule.__AuthorizationModule_init_unchained(address)](contracts/modules/security/AuthorizationModule.sol#L43-L48) is not in mixedCase

contracts/modules/security/AuthorizationModule.sol#L43-L48


 - [ ] ID-85
Parameter [RuleEngineMock.validateTransfer(address,address,uint256)._to](contracts/mocks/RuleEngine/RuleEngineMock.sol#L62) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L62


 - [ ] ID-86
Function [BaseModule.__Base_init_unchained(string,string,string,uint256)](contracts/modules/wrapper/mandatory/BaseModule.sol#L57-L67) is not in mixedCase

contracts/modules/wrapper/mandatory/BaseModule.sol#L57-L67


 - [ ] ID-87
Variable [SnapshotModule.__gap](contracts/modules/wrapper/optional/SnapshotModule.sol#L102) is not in mixedCase

contracts/modules/wrapper/optional/SnapshotModule.sol#L102


 - [ ] ID-88
Function [AuthorizationModule.__AuthorizationModule_init(address)](contracts/modules/security/AuthorizationModule.sol#L25-L36) is not in mixedCase

contracts/modules/security/AuthorizationModule.sol#L25-L36


 - [ ] ID-89
Parameter [RuleEngineMock.validateTransfer(address,address,uint256)._from](contracts/mocks/RuleEngine/RuleEngineMock.sol#L61) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L61


 - [ ] ID-90
Parameter [RuleMock.validateTransfer(address,address,uint256)._amount](contracts/mocks/RuleEngine/RuleMock.sol#L16) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L16


 - [ ] ID-91
Variable [PauseModule.__gap](contracts/modules/wrapper/mandatory/PauseModule.sol#L67) is not in mixedCase

contracts/modules/wrapper/mandatory/PauseModule.sol#L67


 - [ ] ID-92
Function [CMTAT_BASE.__CMTAT_init_unchained()](contracts/modules/CMTAT_BASE.sol#L128-L131) is not in mixedCase

contracts/modules/CMTAT_BASE.sol#L128-L131


 - [ ] ID-93
Function [BurnModule.__BurnModule_init(string,string,address)](contracts/modules/wrapper/mandatory/BurnModule.sol#L12-L31) is not in mixedCase

contracts/modules/wrapper/mandatory/BurnModule.sol#L12-L31


 - [ ] ID-94
Function [ValidationModule.__ValidationModule_init(IEIP1404Wrapper,address)](contracts/modules/wrapper/optional/ValidationModule.sol#L25-L49) is not in mixedCase

contracts/modules/wrapper/optional/ValidationModule.sol#L25-L49


 - [ ] ID-95
Parameter [RuleMock.detectTransferRestriction(address,address,uint256)._amount](contracts/mocks/RuleEngine/RuleMock.sol#L27) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L27


 - [ ] ID-96
Function [BurnModule.__BurnModule_init_unchained()](contracts/modules/wrapper/mandatory/BurnModule.sol#L33-L35) is not in mixedCase

contracts/modules/wrapper/mandatory/BurnModule.sol#L33-L35


 - [ ] ID-97
Parameter [RuleMock.messageForTransferRestriction(uint8)._restrictionCode](contracts/mocks/RuleEngine/RuleMock.sol#L39) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L39


 - [ ] ID-98
Function [BaseModule.__Base_init(string,string,string,uint256,address)](contracts/modules/wrapper/mandatory/BaseModule.sol#L35-L55) is not in mixedCase

contracts/modules/wrapper/mandatory/BaseModule.sol#L35-L55


 - [ ] ID-99
Function [MintModule.__MintModule_init_unchained()](contracts/modules/wrapper/mandatory/MintModule.sol#L33-L35) is not in mixedCase

contracts/modules/wrapper/mandatory/MintModule.sol#L33-L35


 - [ ] ID-100
Function [SnapshotModuleInternal.__Snapshot_init_unchained()](contracts/modules/internal/SnapshotModuleInternal.sol#L74-L77) is not in mixedCase

contracts/modules/internal/SnapshotModuleInternal.sol#L74-L77


 - [ ] ID-101
Function [CMTAT_BASE.__CMTAT_init(address,string,string,string,string,IEIP1404Wrapper,string,uint256)](contracts/modules/CMTAT_BASE.sol#L72-L126) is not in mixedCase

contracts/modules/CMTAT_BASE.sol#L72-L126


 - [ ] ID-102
Parameter [RuleEngineMock.detectTransferRestriction(address,address,uint256)._to](contracts/mocks/RuleEngine/RuleEngineMock.sol#L43) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L43


 - [ ] ID-103
Variable [MetaTxModule.__gap](contracts/modules/wrapper/optional/MetaTxModule.sol#L43) is not in mixedCase

contracts/modules/wrapper/optional/MetaTxModule.sol#L43


 - [ ] ID-104
Function [ERC20BaseModule.__ERC20Module_init(string,string,uint8)](contracts/modules/wrapper/mandatory/ERC20BaseModule.sol#L23-L34) is not in mixedCase

contracts/modules/wrapper/mandatory/ERC20BaseModule.sol#L23-L34


 - [ ] ID-105
Function [SnapshotModuleInternal.__Snapshot_init(string,string)](contracts/modules/internal/SnapshotModuleInternal.sol#L65-L72) is not in mixedCase

contracts/modules/internal/SnapshotModuleInternal.sol#L65-L72


 - [ ] ID-106
Function [CreditEventsModule.__CreditEvents_init(address)](contracts/modules/wrapper/optional/DebtModule/CreditEventsModule.sol#L23-L38) is not in mixedCase

contracts/modules/wrapper/optional/DebtModule/CreditEventsModule.sol#L23-L38


 - [ ] ID-107
Function [SnapshotModule.__SnasphotModule_init_unchained()](contracts/modules/wrapper/optional/SnapshotModule.sol#L44-L46) is not in mixedCase

contracts/modules/wrapper/optional/SnapshotModule.sol#L44-L46


 - [ ] ID-108
Variable [ERC20BaseModule.__gap](contracts/modules/wrapper/mandatory/ERC20BaseModule.sol#L108) is not in mixedCase

contracts/modules/wrapper/mandatory/ERC20BaseModule.sol#L108


 - [ ] ID-109
Contract [CMTAT_BASE](contracts/modules/CMTAT_BASE.sol#L27-L205) is not in CapWords

contracts/modules/CMTAT_BASE.sol#L27-L205


 - [ ] ID-110
Parameter [RuleEngineMock.messageForTransferRestriction(uint8)._restrictionCode](contracts/mocks/RuleEngine/RuleEngineMock.sol#L73) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L73


 - [ ] ID-111
Function [DebtBaseModule.__DebtBaseModule_init(address)](contracts/modules/wrapper/optional/DebtModule/DebtBaseModule.sol#L59-L74) is not in mixedCase

contracts/modules/wrapper/optional/DebtModule/DebtBaseModule.sol#L59-L74


 - [ ] ID-112
Function [ValidationModule.__ValidationModule_init_unchained()](contracts/modules/wrapper/optional/ValidationModule.sol#L51-L53) is not in mixedCase

contracts/modules/wrapper/optional/ValidationModule.sol#L51-L53


 - [ ] ID-113
Function [DebtBaseModule.__DebtBaseModule_init_unchained()](contracts/modules/wrapper/optional/DebtModule/DebtBaseModule.sol#L76-L78) is not in mixedCase

contracts/modules/wrapper/optional/DebtModule/DebtBaseModule.sol#L76-L78


 - [ ] ID-114
Parameter [RuleEngineMock.detectTransferRestriction(address,address,uint256)._from](contracts/mocks/RuleEngine/RuleEngineMock.sol#L42) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L42


 - [ ] ID-115
Function [PauseModule.__PauseModule_init(address)](contracts/modules/wrapper/mandatory/PauseModule.sol#L20-L35) is not in mixedCase

contracts/modules/wrapper/mandatory/PauseModule.sol#L20-L35


 - [ ] ID-116
Function [ValidationModuleInternal.__Validation_init_unchained(IEIP1404Wrapper)](contracts/modules/internal/ValidationModuleInternal.sol#L35-L42) is not in mixedCase

contracts/modules/internal/ValidationModuleInternal.sol#L35-L42


 - [ ] ID-117
Function [EnforcementModule.__EnforcementModule_init_unchained()](contracts/modules/wrapper/mandatory/EnforcementModule.sol#L44-L46) is not in mixedCase

contracts/modules/wrapper/mandatory/EnforcementModule.sol#L44-L46


 - [ ] ID-118
Parameter [RuleMock.validateTransfer(address,address,uint256)._from](contracts/mocks/RuleEngine/RuleMock.sol#L14) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L14


 - [ ] ID-119
Variable [CMTAT_PROXY.__gap](contracts/CMTAT_PROXY.sol#L24) is not in mixedCase

contracts/CMTAT_PROXY.sol#L24

## unused-state

> Remark:
>
> You can remove it or you can keep it. It is indeed not a requirement for the
> main child contract, but it costs nothing to keep it in the code, see https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable#storage-gaps

Impact: Informational
Confidence: High
 - [ ] ID-120
[CMTAT_PROXY.__gap](contracts/CMTAT_PROXY.sol#L24) is never used in [CMTAT_PROXY](contracts/CMTAT_PROXY.sol#L8-L25)

contracts/CMTAT_PROXY.sol#L24

## constable-states

> Remark:
>
> It will not work if we declare the variable as a constant because it is set to :
>
> - False if deployed in standalone mode (default value)
> - True if deployed with a proxy, set inside the constructor

Impact: Optimization
Confidence: High

 - [ ] ID-121
[BaseModule.deployedWithProxy](contracts/modules/wrapper/mandatory/BaseModule.sol#L12) should be constant 

contracts/modules/wrapper/mandatory/BaseModule.sol#L12

## immutable-states

> Remark:
>
> It will not work if we declare the variable as an immutable because we set the value inside the constructor of the implementation contract when we perform a deployment with a proxy, which will not be possible if we use an immutable variable.

Impact: Optimization
Confidence: High

 - [ ] ID-122
[BaseModule.deployedWithProxy](contracts/modules/wrapper/mandatory/BaseModule.sol#L12) should be immutable 

contracts/modules/wrapper/mandatory/BaseModule.sol#L12

