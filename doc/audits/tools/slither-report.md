Summary
 - [suicidal](#suicidal) (1 results) (High)
 - [shadowing-local](#shadowing-local) (15 results) (Low)
 - [calls-loop](#calls-loop) (3 results) (Low)
 - [timestamp](#timestamp) (6 results) (Low)
 - [boolean-equal](#boolean-equal) (1 results) (Informational)
 - [dead-code](#dead-code) (16 results) (Informational)
 - [solc-version](#solc-version) (29 results) (Informational)
 - [naming-convention](#naming-convention) (65 results) (Informational)
 - [unused-state](#unused-state) (4 results) (Informational)
 - [constable-states](#constable-states) (1 results) (Optimization)
 - [immutable-states](#immutable-states) (1 results) (Optimization)
## suicidal
Impact: High
Confidence: High
 - [ ] ID-0
[BaseModule.kill()](contracts/modules/wrapper/mandatory/BaseModule.sol#L113-L119) allows anyone to destruct the contract

contracts/modules/wrapper/mandatory/BaseModule.sol#L113-L119


## shadowing-local
Impact: Low
Confidence: High
 - [ ] ID-1
[CMTAT_STANDALONE.constructor(address,address,string,string,string,string,IEIP1404Wrapper,string,uint256).terms](contracts/CMTAT_STANDALONE.sol#L29) shadows:
	- [BaseModule.terms](contracts/modules/wrapper/mandatory/BaseModule.sol#L23) (state variable)

contracts/CMTAT_STANDALONE.sol#L29


 - [ ] ID-2
[CMTAT_BASE.initialize(address,string,string,string,string,IEIP1404Wrapper,string,uint256).information](contracts/modules/CMTAT_BASE.sol#L54) shadows:
	- [BaseModule.information](contracts/modules/wrapper/mandatory/BaseModule.sol#L24) (state variable)

contracts/modules/CMTAT_BASE.sol#L54


 - [ ] ID-3
[CMTAT_STANDALONE.constructor(address,address,string,string,string,string,IEIP1404Wrapper,string,uint256).information](contracts/CMTAT_STANDALONE.sol#L31) shadows:
	- [BaseModule.information](contracts/modules/wrapper/mandatory/BaseModule.sol#L24) (state variable)

contracts/CMTAT_STANDALONE.sol#L31


 - [ ] ID-4
[CMTAT_STANDALONE.constructor(address,address,string,string,string,string,IEIP1404Wrapper,string,uint256).flag](contracts/CMTAT_STANDALONE.sol#L32) shadows:
	- [BaseModule.flag](contracts/modules/wrapper/mandatory/BaseModule.sol#L25) (state variable)

contracts/CMTAT_STANDALONE.sol#L32


 - [ ] ID-5
[CMTAT_BASE.__CMTAT_init(address,string,string,string,string,IEIP1404Wrapper,string,uint256).terms](contracts/modules/CMTAT_BASE.sol#L77) shadows:
	- [BaseModule.terms](contracts/modules/wrapper/mandatory/BaseModule.sol#L23) (state variable)

contracts/modules/CMTAT_BASE.sol#L77


 - [ ] ID-6
[CMTAT_STANDALONE.constructor(address,address,string,string,string,string,IEIP1404Wrapper,string,uint256).ruleEngine](contracts/CMTAT_STANDALONE.sol#L30) shadows:
	- [ValidationModuleInternal.ruleEngine](contracts/modules/internal/ValidationModuleInternal.sol#L23) (state variable)

contracts/CMTAT_STANDALONE.sol#L30


 - [ ] ID-7
[CMTAT_BASE.__CMTAT_init(address,string,string,string,string,IEIP1404Wrapper,string,uint256).tokenId](contracts/modules/CMTAT_BASE.sol#L76) shadows:
	- [BaseModule.tokenId](contracts/modules/wrapper/mandatory/BaseModule.sol#L22) (state variable)

contracts/modules/CMTAT_BASE.sol#L76


 - [ ] ID-8
[CMTAT_STANDALONE.constructor(address,address,string,string,string,string,IEIP1404Wrapper,string,uint256).tokenId](contracts/CMTAT_STANDALONE.sol#L28) shadows:
	- [BaseModule.tokenId](contracts/modules/wrapper/mandatory/BaseModule.sol#L22) (state variable)

contracts/CMTAT_STANDALONE.sol#L28


 - [ ] ID-9
[CMTAT_BASE.initialize(address,string,string,string,string,IEIP1404Wrapper,string,uint256).tokenId](contracts/modules/CMTAT_BASE.sol#L51) shadows:
	- [BaseModule.tokenId](contracts/modules/wrapper/mandatory/BaseModule.sol#L22) (state variable)

contracts/modules/CMTAT_BASE.sol#L51


 - [ ] ID-10
[CMTAT_BASE.initialize(address,string,string,string,string,IEIP1404Wrapper,string,uint256).flag](contracts/modules/CMTAT_BASE.sol#L55) shadows:
	- [BaseModule.flag](contracts/modules/wrapper/mandatory/BaseModule.sol#L25) (state variable)

contracts/modules/CMTAT_BASE.sol#L55


 - [ ] ID-11
[CMTAT_BASE.__CMTAT_init(address,string,string,string,string,IEIP1404Wrapper,string,uint256).flag](contracts/modules/CMTAT_BASE.sol#L80) shadows:
	- [BaseModule.flag](contracts/modules/wrapper/mandatory/BaseModule.sol#L25) (state variable)

contracts/modules/CMTAT_BASE.sol#L80


 - [ ] ID-12
[CMTAT_BASE.initialize(address,string,string,string,string,IEIP1404Wrapper,string,uint256).terms](contracts/modules/CMTAT_BASE.sol#L52) shadows:
	- [BaseModule.terms](contracts/modules/wrapper/mandatory/BaseModule.sol#L23) (state variable)

contracts/modules/CMTAT_BASE.sol#L52


 - [ ] ID-13
[CMTAT_BASE.__CMTAT_init(address,string,string,string,string,IEIP1404Wrapper,string,uint256).information](contracts/modules/CMTAT_BASE.sol#L79) shadows:
	- [BaseModule.information](contracts/modules/wrapper/mandatory/BaseModule.sol#L24) (state variable)

contracts/modules/CMTAT_BASE.sol#L79


 - [ ] ID-14
[CMTAT_BASE.initialize(address,string,string,string,string,IEIP1404Wrapper,string,uint256).ruleEngine](contracts/modules/CMTAT_BASE.sol#L53) shadows:
	- [ValidationModuleInternal.ruleEngine](contracts/modules/internal/ValidationModuleInternal.sol#L23) (state variable)

contracts/modules/CMTAT_BASE.sol#L53


 - [ ] ID-15
[CMTAT_BASE.__CMTAT_init(address,string,string,string,string,IEIP1404Wrapper,string,uint256).ruleEngine](contracts/modules/CMTAT_BASE.sol#L78) shadows:
	- [ValidationModuleInternal.ruleEngine](contracts/modules/internal/ValidationModuleInternal.sol#L23) (state variable)

contracts/modules/CMTAT_BASE.sol#L78


## calls-loop
Impact: Low
Confidence: Medium
 - [ ] ID-16
[RuleEngineMock.messageForTransferRestriction(uint8)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L72-L83) has external calls inside a loop: [_rules[i].canReturnTransferRestrictionCode(_restrictionCode)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L77)

contracts/mocks/RuleEngine/RuleEngineMock.sol#L72-L83


 - [ ] ID-17
[RuleEngineMock.messageForTransferRestriction(uint8)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L72-L83) has external calls inside a loop: [_rules[i].messageForTransferRestriction(_restrictionCode)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L78-L79)

contracts/mocks/RuleEngine/RuleEngineMock.sol#L72-L83


 - [ ] ID-18
[RuleEngineMock.detectTransferRestriction(address,address,uint256)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L41-L58) has external calls inside a loop: [restriction = _rules[i].detectTransferRestriction(_from,_to,_amount)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L48-L52)

contracts/mocks/RuleEngine/RuleEngineMock.sol#L41-L58


## timestamp
Impact: Low
Confidence: Medium
 - [ ] ID-19
[SnapshotModuleInternal._unscheduleLastSnapshot(uint256)](contracts/modules/internal/SnapshotModuleInternal.sol#L158-L169) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(time > block.timestamp,Snapshot already done)](contracts/modules/internal/SnapshotModuleInternal.sol#L160)

contracts/modules/internal/SnapshotModuleInternal.sol#L158-L169


 - [ ] ID-20
[SnapshotModuleInternal._scheduleSnapshot(uint256)](contracts/modules/internal/SnapshotModuleInternal.sol#L83-L96) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(time > block.timestamp,Snapshot scheduled in the past)](contracts/modules/internal/SnapshotModuleInternal.sol#L85)

contracts/modules/internal/SnapshotModuleInternal.sol#L83-L96


 - [ ] ID-21
[SnapshotModuleInternal._unscheduleSnapshotNotOptimized(uint256)](contracts/modules/internal/SnapshotModuleInternal.sol#L177-L188) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(time > block.timestamp,Snapshot already done)](contracts/modules/internal/SnapshotModuleInternal.sol#L178)

contracts/modules/internal/SnapshotModuleInternal.sol#L177-L188


 - [ ] ID-22
[SnapshotModuleInternal._findScheduledMostRecentPastSnapshot()](contracts/modules/internal/SnapshotModuleInternal.sol#L413-L438) uses timestamp for comparisons
	Dangerous comparisons:
	- [_scheduledSnapshots[i] <= block.timestamp](contracts/modules/internal/SnapshotModuleInternal.sol#L429)

contracts/modules/internal/SnapshotModuleInternal.sol#L413-L438


 - [ ] ID-23
[SnapshotModuleInternal._rescheduleSnapshot(uint256,uint256)](contracts/modules/internal/SnapshotModuleInternal.sol#L127-L153) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(oldTime > block.timestamp,Snapshot already done)](contracts/modules/internal/SnapshotModuleInternal.sol#L129)
	- [require(bool,string)(newTime > block.timestamp,Snapshot scheduled in the past)](contracts/modules/internal/SnapshotModuleInternal.sol#L130)

contracts/modules/internal/SnapshotModuleInternal.sol#L127-L153


 - [ ] ID-24
[SnapshotModuleInternal._scheduleSnapshotNotOptimized(uint256)](contracts/modules/internal/SnapshotModuleInternal.sol#L101-L122) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(time > block.timestamp,Snapshot scheduled in the past)](contracts/modules/internal/SnapshotModuleInternal.sol#L102)

contracts/modules/internal/SnapshotModuleInternal.sol#L101-L122


## boolean-equal
Impact: Informational
Confidence: High
 - [ ] ID-25
[ERC20BaseModule.transferFrom(address,address,uint256)](contracts/modules/wrapper/mandatory/ERC20BaseModule.sol#L74-L85) compares to a boolean constant:
	-[result == true](contracts/modules/wrapper/mandatory/ERC20BaseModule.sol#L80)

contracts/modules/wrapper/mandatory/ERC20BaseModule.sol#L74-L85


## dead-code
Impact: Informational
Confidence: Medium
 - [ ] ID-26
[ValidationModule.__ValidationModule_init(IEIP1404Wrapper,address)](contracts/modules/wrapper/optional/ValidationModule.sol#L25-L49) is never used and should be removed

contracts/modules/wrapper/optional/ValidationModule.sol#L25-L49


 - [ ] ID-27
[EnforcementModule.__EnforcementModule_init(address)](contracts/modules/wrapper/mandatory/EnforcementModule.sol#L25-L42) is never used and should be removed

contracts/modules/wrapper/mandatory/EnforcementModule.sol#L25-L42


 - [ ] ID-28
[SnapshotModule.__SnasphotModule_init(string,string,address)](contracts/modules/wrapper/optional/SnapshotModule.sol#L19-L42) is never used and should be removed

contracts/modules/wrapper/optional/SnapshotModule.sol#L19-L42


 - [ ] ID-29
[MetaTxModule._msgData()](contracts/modules/wrapper/optional/MetaTxModule.sol#L33-L41) is never used and should be removed

contracts/modules/wrapper/optional/MetaTxModule.sol#L33-L41


 - [ ] ID-30
[BurnModule.__BurnModule_init(string,string,address)](contracts/modules/wrapper/mandatory/BurnModule.sol#L12-L31) is never used and should be removed

contracts/modules/wrapper/mandatory/BurnModule.sol#L12-L31


 - [ ] ID-31
[CMTAT_BASE._msgData()](contracts/modules/CMTAT_BASE.sol#L195-L202) is never used and should be removed

contracts/modules/CMTAT_BASE.sol#L195-L202


 - [ ] ID-32
[ERC20BaseModule.__ERC20Module_init(string,string,uint8)](contracts/modules/wrapper/mandatory/ERC20BaseModule.sol#L23-L34) is never used and should be removed

contracts/modules/wrapper/mandatory/ERC20BaseModule.sol#L23-L34


 - [ ] ID-33
[MintModule.__MintModule_init(string,string,address)](contracts/modules/wrapper/mandatory/MintModule.sol#L12-L31) is never used and should be removed

contracts/modules/wrapper/mandatory/MintModule.sol#L12-L31


 - [ ] ID-34
[PauseModule.__PauseModule_init(address)](contracts/modules/wrapper/mandatory/PauseModule.sol#L20-L35) is never used and should be removed

contracts/modules/wrapper/mandatory/PauseModule.sol#L20-L35


 - [ ] ID-35
[SnapshotModuleInternal.__Snapshot_init(string,string)](contracts/modules/internal/SnapshotModuleInternal.sol#L65-L72) is never used and should be removed

contracts/modules/internal/SnapshotModuleInternal.sol#L65-L72


 - [ ] ID-36
[AuthorizationModule.__AuthorizationModule_init(address)](contracts/modules/security/AuthorizationModule.sol#L25-L36) is never used and should be removed

contracts/modules/security/AuthorizationModule.sol#L25-L36


 - [ ] ID-37
[ValidationModuleInternal.__Validation_init(IEIP1404Wrapper)](contracts/modules/internal/ValidationModuleInternal.sol#L28-L33) is never used and should be removed

contracts/modules/internal/ValidationModuleInternal.sol#L28-L33


 - [ ] ID-38
[DebtBaseModule.__DebtBaseModule_init(address)](contracts/modules/wrapper/optional/DebtModule/DebtBaseModule.sol#L59-L74) is never used and should be removed

contracts/modules/wrapper/optional/DebtModule/DebtBaseModule.sol#L59-L74


 - [ ] ID-39
[EnforcementModuleInternal.__Enforcement_init()](contracts/modules/internal/EnforcementModuleInternal.sol#L43-L46) is never used and should be removed

contracts/modules/internal/EnforcementModuleInternal.sol#L43-L46


 - [ ] ID-40
[BaseModule.__Base_init(string,string,string,uint256,address)](contracts/modules/wrapper/mandatory/BaseModule.sol#L34-L54) is never used and should be removed

contracts/modules/wrapper/mandatory/BaseModule.sol#L34-L54


 - [ ] ID-41
[CreditEventsModule.__CreditEvents_init(address)](contracts/modules/wrapper/optional/DebtModule/CreditEventsModule.sol#L23-L38) is never used and should be removed

contracts/modules/wrapper/optional/DebtModule/CreditEventsModule.sol#L23-L38


## solc-version
Impact: Informational
Confidence: High
 - [ ] ID-42
Pragma version[^0.8.17](contracts/modules/wrapper/mandatory/BaseModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/wrapper/mandatory/BaseModule.sol#L3


 - [ ] ID-43
Pragma version[^0.8.17](contracts/modules/CMTAT_BASE.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/CMTAT_BASE.sol#L3


 - [ ] ID-44
Pragma version[^0.8.17](contracts/modules/wrapper/optional/SnapshotModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/wrapper/optional/SnapshotModule.sol#L3


 - [ ] ID-45
Pragma version[^0.8.17](contracts/modules/wrapper/mandatory/MintModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/wrapper/mandatory/MintModule.sol#L3


 - [ ] ID-46
Pragma version[^0.8.17](contracts/modules/wrapper/mandatory/PauseModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/wrapper/mandatory/PauseModule.sol#L3


 - [ ] ID-47
Pragma version[^0.8.17](contracts/modules/internal/EnforcementModuleInternal.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/internal/EnforcementModuleInternal.sol#L3


 - [ ] ID-48
Pragma version[^0.8.17](contracts/CMTAT_PROXY.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/CMTAT_PROXY.sol#L3


 - [ ] ID-49
Pragma version[^0.8.17](contracts/modules/wrapper/optional/MetaTxModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/wrapper/optional/MetaTxModule.sol#L3


 - [ ] ID-50
Pragma version[^0.8.17](contracts/modules/wrapper/optional/DebtModule/CreditEventsModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/wrapper/optional/DebtModule/CreditEventsModule.sol#L3


 - [ ] ID-51
Pragma version[^0.8.0](contracts/mocks/RuleEngine/interfaces/IRuleEngine.sol#L3) allows old versions

contracts/mocks/RuleEngine/interfaces/IRuleEngine.sol#L3


 - [ ] ID-52
Pragma version[^0.8.0](contracts/interfaces/IEIP1404/IEIP1404.sol#L3) allows old versions

contracts/interfaces/IEIP1404/IEIP1404.sol#L3


 - [ ] ID-53
Pragma version[^0.8.17](contracts/mocks/RuleEngine/RuleMock.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/mocks/RuleEngine/RuleMock.sol#L3


 - [ ] ID-54
Pragma version[^0.8.0](contracts/mocks/RuleEngine/interfaces/IRule.sol#L3) allows old versions

contracts/mocks/RuleEngine/interfaces/IRule.sol#L3


 - [ ] ID-55
solc-0.8.17 is not recommended for deployment

 - [ ] ID-56
Pragma version[^0.8.17](contracts/modules/wrapper/mandatory/ERC20BaseModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/wrapper/mandatory/ERC20BaseModule.sol#L3


 - [ ] ID-57
Pragma version[^0.8.0](contracts/interfaces/IDebtGlobal.sol#L3) allows old versions

contracts/interfaces/IDebtGlobal.sol#L3


 - [ ] ID-58
Pragma version[^0.8.17](contracts/modules/internal/SnapshotModuleInternal.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/internal/SnapshotModuleInternal.sol#L3


 - [ ] ID-59
Pragma version[^0.8.17](contracts/modules/wrapper/optional/DebtModule/DebtBaseModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/wrapper/optional/DebtModule/DebtBaseModule.sol#L3


 - [ ] ID-60
Pragma version[^0.8.17](contracts/modules/wrapper/mandatory/EnforcementModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/wrapper/mandatory/EnforcementModule.sol#L3


 - [ ] ID-61
Pragma version[^0.8.17](contracts/modules/security/AuthorizationModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/security/AuthorizationModule.sol#L3


 - [ ] ID-62
Pragma version[^0.8.17](contracts/modules/internal/ValidationModuleInternal.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/internal/ValidationModuleInternal.sol#L3


 - [ ] ID-63
Pragma version[^0.8.17](contracts/modules/wrapper/mandatory/BurnModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/wrapper/mandatory/BurnModule.sol#L3


 - [ ] ID-64
Pragma version[^0.8.0](contracts/interfaces/IEIP1404/IEIP1404Wrapper.sol#L3) allows old versions

contracts/interfaces/IEIP1404/IEIP1404Wrapper.sol#L3


 - [ ] ID-65
Pragma version[^0.8.17](contracts/modules/wrapper/optional/ValidationModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/wrapper/optional/ValidationModule.sol#L3


 - [ ] ID-66
Pragma version[^0.8.17](contracts/mocks/RuleEngine/CodeList.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/mocks/RuleEngine/CodeList.sol#L3


 - [ ] ID-67
Pragma version[^0.8.17](contracts/CMTAT_STANDALONE.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/CMTAT_STANDALONE.sol#L3


 - [ ] ID-68
Pragma version[^0.8.17](contracts/mocks/MinimalForwarderMock.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/mocks/MinimalForwarderMock.sol#L3


 - [ ] ID-69
Pragma version[^0.8.17](contracts/modules/security/OnlyDelegateCallModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/modules/security/OnlyDelegateCallModule.sol#L3


 - [ ] ID-70
Pragma version[^0.8.17](contracts/mocks/RuleEngine/RuleEngineMock.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.16

contracts/mocks/RuleEngine/RuleEngineMock.sol#L3


## naming-convention
Impact: Informational
Confidence: High
 - [ ] ID-71
Variable [RuleEngineMock._rules](contracts/mocks/RuleEngine/RuleEngineMock.sol#L15) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L15


 - [ ] ID-72
Function [SnapshotModule.__SnasphotModule_init(string,string,address)](contracts/modules/wrapper/optional/SnapshotModule.sol#L19-L42) is not in mixedCase

contracts/modules/wrapper/optional/SnapshotModule.sol#L19-L42


 - [ ] ID-73
Variable [CreditEventsModule.__gap](contracts/modules/wrapper/optional/DebtModule/CreditEventsModule.sol#L91) is not in mixedCase

contracts/modules/wrapper/optional/DebtModule/CreditEventsModule.sol#L91


 - [ ] ID-74
Function [EnforcementModuleInternal.__Enforcement_init()](contracts/modules/internal/EnforcementModuleInternal.sol#L43-L46) is not in mixedCase

contracts/modules/internal/EnforcementModuleInternal.sol#L43-L46


 - [ ] ID-75
Function [MintModule.__MintModule_init(string,string,address)](contracts/modules/wrapper/mandatory/MintModule.sol#L12-L31) is not in mixedCase

contracts/modules/wrapper/mandatory/MintModule.sol#L12-L31


 - [ ] ID-76
Enum [IEIP1404Wrapper.REJECTED_CODE_BASE](contracts/interfaces/IEIP1404/IEIP1404Wrapper.sol#L11-L16) is not in CapWords

contracts/interfaces/IEIP1404/IEIP1404Wrapper.sol#L11-L16


 - [ ] ID-77
Parameter [RuleEngineMock.detectTransferRestriction(address,address,uint256)._amount](contracts/mocks/RuleEngine/RuleEngineMock.sol#L44) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L44


 - [ ] ID-78
Variable [BurnModule.__gap](contracts/modules/wrapper/mandatory/BurnModule.sol#L51) is not in mixedCase

contracts/modules/wrapper/mandatory/BurnModule.sol#L51


 - [ ] ID-79
Function [ValidationModuleInternal.__Validation_init(IEIP1404Wrapper)](contracts/modules/internal/ValidationModuleInternal.sol#L28-L33) is not in mixedCase

contracts/modules/internal/ValidationModuleInternal.sol#L28-L33


 - [ ] ID-80
Contract [CMTAT_PROXY](contracts/CMTAT_PROXY.sol#L8-L25) is not in CapWords

contracts/CMTAT_PROXY.sol#L8-L25


 - [ ] ID-81
Function [PauseModule.__PauseModule_init_unchained()](contracts/modules/wrapper/mandatory/PauseModule.sol#L37-L39) is not in mixedCase

contracts/modules/wrapper/mandatory/PauseModule.sol#L37-L39


 - [ ] ID-82
Function [CreditEventsModule.__CreditEvents_init_unchained()](contracts/modules/wrapper/optional/DebtModule/CreditEventsModule.sol#L40-L42) is not in mixedCase

contracts/modules/wrapper/optional/DebtModule/CreditEventsModule.sol#L40-L42


 - [ ] ID-83
Variable [CMTAT_BASE.__gap](contracts/modules/CMTAT_BASE.sol#L204) is not in mixedCase

contracts/modules/CMTAT_BASE.sol#L204


 - [ ] ID-84
Function [EnforcementModuleInternal.__Enforcement_init_unchained()](contracts/modules/internal/EnforcementModuleInternal.sol#L48-L50) is not in mixedCase

contracts/modules/internal/EnforcementModuleInternal.sol#L48-L50


 - [ ] ID-85
Variable [ValidationModuleInternal.__gap](contracts/modules/internal/ValidationModuleInternal.sol#L75) is not in mixedCase

contracts/modules/internal/ValidationModuleInternal.sol#L75


 - [ ] ID-86
Function [EnforcementModule.__EnforcementModule_init(address)](contracts/modules/wrapper/mandatory/EnforcementModule.sol#L25-L42) is not in mixedCase

contracts/modules/wrapper/mandatory/EnforcementModule.sol#L25-L42


 - [ ] ID-87
Variable [SnapshotModuleInternal.__gap](contracts/modules/internal/SnapshotModuleInternal.sol#L440) is not in mixedCase

contracts/modules/internal/SnapshotModuleInternal.sol#L440


 - [ ] ID-88
Variable [BaseModule.__gap](contracts/modules/wrapper/mandatory/BaseModule.sol#L121) is not in mixedCase

contracts/modules/wrapper/mandatory/BaseModule.sol#L121


 - [ ] ID-89
Variable [ValidationModule.__gap](contracts/modules/wrapper/optional/ValidationModule.sol#L139) is not in mixedCase

contracts/modules/wrapper/optional/ValidationModule.sol#L139


 - [ ] ID-90
Variable [MintModule.__gap](contracts/modules/wrapper/mandatory/MintModule.sol#L51) is not in mixedCase

contracts/modules/wrapper/mandatory/MintModule.sol#L51


 - [ ] ID-91
Variable [EnforcementModule.__gap](contracts/modules/wrapper/mandatory/EnforcementModule.sol#L74) is not in mixedCase

contracts/modules/wrapper/mandatory/EnforcementModule.sol#L74


 - [ ] ID-92
Contract [CMTAT_STANDALONE](contracts/CMTAT_STANDALONE.sol#L8-L50) is not in CapWords

contracts/CMTAT_STANDALONE.sol#L8-L50


 - [ ] ID-93
Variable [DebtBaseModule.__gap](contracts/modules/wrapper/optional/DebtModule/DebtBaseModule.sol#L261) is not in mixedCase

contracts/modules/wrapper/optional/DebtModule/DebtBaseModule.sol#L261


 - [ ] ID-94
Variable [AuthorizationModule.__gap](contracts/modules/security/AuthorizationModule.sol#L61) is not in mixedCase

contracts/modules/security/AuthorizationModule.sol#L61


 - [ ] ID-95
Parameter [RuleEngineMock.validateTransfer(address,address,uint256)._amount](contracts/mocks/RuleEngine/RuleEngineMock.sol#L63) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L63


 - [ ] ID-96
Parameter [RuleMock.validateTransfer(address,address,uint256)._to](contracts/mocks/RuleEngine/RuleMock.sol#L15) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L15


 - [ ] ID-97
Function [ERC20BaseModule.__ERC20Module_init_unchained(uint8)](contracts/modules/wrapper/mandatory/ERC20BaseModule.sol#L36-L40) is not in mixedCase

contracts/modules/wrapper/mandatory/ERC20BaseModule.sol#L36-L40


 - [ ] ID-98
Variable [EnforcementModuleInternal.__gap](contracts/modules/internal/EnforcementModuleInternal.sol#L91) is not in mixedCase

contracts/modules/internal/EnforcementModuleInternal.sol#L91


 - [ ] ID-99
Parameter [RuleMock.canReturnTransferRestrictionCode(uint8)._restrictionCode](contracts/mocks/RuleEngine/RuleMock.sol#L33) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L33


 - [ ] ID-100
Function [AuthorizationModule.__AuthorizationModule_init_unchained(address)](contracts/modules/security/AuthorizationModule.sol#L43-L48) is not in mixedCase

contracts/modules/security/AuthorizationModule.sol#L43-L48


 - [ ] ID-101
Parameter [RuleEngineMock.validateTransfer(address,address,uint256)._to](contracts/mocks/RuleEngine/RuleEngineMock.sol#L62) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L62


 - [ ] ID-102
Function [BaseModule.__Base_init_unchained(string,string,string,uint256)](contracts/modules/wrapper/mandatory/BaseModule.sol#L56-L66) is not in mixedCase

contracts/modules/wrapper/mandatory/BaseModule.sol#L56-L66


 - [ ] ID-103
Variable [SnapshotModule.__gap](contracts/modules/wrapper/optional/SnapshotModule.sol#L102) is not in mixedCase

contracts/modules/wrapper/optional/SnapshotModule.sol#L102


 - [ ] ID-104
Function [AuthorizationModule.__AuthorizationModule_init(address)](contracts/modules/security/AuthorizationModule.sol#L25-L36) is not in mixedCase

contracts/modules/security/AuthorizationModule.sol#L25-L36


 - [ ] ID-105
Parameter [RuleEngineMock.validateTransfer(address,address,uint256)._from](contracts/mocks/RuleEngine/RuleEngineMock.sol#L61) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L61


 - [ ] ID-106
Parameter [RuleMock.validateTransfer(address,address,uint256)._amount](contracts/mocks/RuleEngine/RuleMock.sol#L16) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L16


 - [ ] ID-107
Variable [PauseModule.__gap](contracts/modules/wrapper/mandatory/PauseModule.sol#L67) is not in mixedCase

contracts/modules/wrapper/mandatory/PauseModule.sol#L67


 - [ ] ID-108
Function [CMTAT_BASE.__CMTAT_init_unchained()](contracts/modules/CMTAT_BASE.sol#L128-L131) is not in mixedCase

contracts/modules/CMTAT_BASE.sol#L128-L131


 - [ ] ID-109
Function [BurnModule.__BurnModule_init(string,string,address)](contracts/modules/wrapper/mandatory/BurnModule.sol#L12-L31) is not in mixedCase

contracts/modules/wrapper/mandatory/BurnModule.sol#L12-L31


 - [ ] ID-110
Function [ValidationModule.__ValidationModule_init(IEIP1404Wrapper,address)](contracts/modules/wrapper/optional/ValidationModule.sol#L25-L49) is not in mixedCase

contracts/modules/wrapper/optional/ValidationModule.sol#L25-L49


 - [ ] ID-111
Parameter [RuleMock.detectTransferRestriction(address,address,uint256)._amount](contracts/mocks/RuleEngine/RuleMock.sol#L27) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L27


 - [ ] ID-112
Function [BurnModule.__BurnModule_init_unchained()](contracts/modules/wrapper/mandatory/BurnModule.sol#L33-L35) is not in mixedCase

contracts/modules/wrapper/mandatory/BurnModule.sol#L33-L35


 - [ ] ID-113
Parameter [RuleMock.messageForTransferRestriction(uint8)._restrictionCode](contracts/mocks/RuleEngine/RuleMock.sol#L39) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L39


 - [ ] ID-114
Function [BaseModule.__Base_init(string,string,string,uint256,address)](contracts/modules/wrapper/mandatory/BaseModule.sol#L34-L54) is not in mixedCase

contracts/modules/wrapper/mandatory/BaseModule.sol#L34-L54


 - [ ] ID-115
Function [MintModule.__MintModule_init_unchained()](contracts/modules/wrapper/mandatory/MintModule.sol#L33-L35) is not in mixedCase

contracts/modules/wrapper/mandatory/MintModule.sol#L33-L35


 - [ ] ID-116
Function [SnapshotModuleInternal.__Snapshot_init_unchained()](contracts/modules/internal/SnapshotModuleInternal.sol#L74-L77) is not in mixedCase

contracts/modules/internal/SnapshotModuleInternal.sol#L74-L77


 - [ ] ID-117
Function [CMTAT_BASE.__CMTAT_init(address,string,string,string,string,IEIP1404Wrapper,string,uint256)](contracts/modules/CMTAT_BASE.sol#L72-L126) is not in mixedCase

contracts/modules/CMTAT_BASE.sol#L72-L126


 - [ ] ID-118
Parameter [RuleEngineMock.detectTransferRestriction(address,address,uint256)._to](contracts/mocks/RuleEngine/RuleEngineMock.sol#L43) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L43


 - [ ] ID-119
Variable [MetaTxModule.__gap](contracts/modules/wrapper/optional/MetaTxModule.sol#L43) is not in mixedCase

contracts/modules/wrapper/optional/MetaTxModule.sol#L43


 - [ ] ID-120
Function [ERC20BaseModule.__ERC20Module_init(string,string,uint8)](contracts/modules/wrapper/mandatory/ERC20BaseModule.sol#L23-L34) is not in mixedCase

contracts/modules/wrapper/mandatory/ERC20BaseModule.sol#L23-L34


 - [ ] ID-121
Function [SnapshotModuleInternal.__Snapshot_init(string,string)](contracts/modules/internal/SnapshotModuleInternal.sol#L65-L72) is not in mixedCase

contracts/modules/internal/SnapshotModuleInternal.sol#L65-L72


 - [ ] ID-122
Function [CreditEventsModule.__CreditEvents_init(address)](contracts/modules/wrapper/optional/DebtModule/CreditEventsModule.sol#L23-L38) is not in mixedCase

contracts/modules/wrapper/optional/DebtModule/CreditEventsModule.sol#L23-L38


 - [ ] ID-123
Function [SnapshotModule.__SnasphotModule_init_unchained()](contracts/modules/wrapper/optional/SnapshotModule.sol#L44-L46) is not in mixedCase

contracts/modules/wrapper/optional/SnapshotModule.sol#L44-L46


 - [ ] ID-124
Variable [ERC20BaseModule.__gap](contracts/modules/wrapper/mandatory/ERC20BaseModule.sol#L107) is not in mixedCase

contracts/modules/wrapper/mandatory/ERC20BaseModule.sol#L107


 - [ ] ID-125
Contract [CMTAT_BASE](contracts/modules/CMTAT_BASE.sol#L27-L205) is not in CapWords

contracts/modules/CMTAT_BASE.sol#L27-L205


 - [ ] ID-126
Parameter [RuleEngineMock.messageForTransferRestriction(uint8)._restrictionCode](contracts/mocks/RuleEngine/RuleEngineMock.sol#L73) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L73


 - [ ] ID-127
Function [DebtBaseModule.__DebtBaseModule_init(address)](contracts/modules/wrapper/optional/DebtModule/DebtBaseModule.sol#L59-L74) is not in mixedCase

contracts/modules/wrapper/optional/DebtModule/DebtBaseModule.sol#L59-L74


 - [ ] ID-128
Function [ValidationModule.__ValidationModule_init_unchained()](contracts/modules/wrapper/optional/ValidationModule.sol#L51-L53) is not in mixedCase

contracts/modules/wrapper/optional/ValidationModule.sol#L51-L53


 - [ ] ID-129
Function [DebtBaseModule.__DebtBaseModule_init_unchained()](contracts/modules/wrapper/optional/DebtModule/DebtBaseModule.sol#L76-L78) is not in mixedCase

contracts/modules/wrapper/optional/DebtModule/DebtBaseModule.sol#L76-L78


 - [ ] ID-130
Parameter [RuleEngineMock.detectTransferRestriction(address,address,uint256)._from](contracts/mocks/RuleEngine/RuleEngineMock.sol#L42) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L42


 - [ ] ID-131
Function [PauseModule.__PauseModule_init(address)](contracts/modules/wrapper/mandatory/PauseModule.sol#L20-L35) is not in mixedCase

contracts/modules/wrapper/mandatory/PauseModule.sol#L20-L35


 - [ ] ID-132
Function [ValidationModuleInternal.__Validation_init_unchained(IEIP1404Wrapper)](contracts/modules/internal/ValidationModuleInternal.sol#L35-L42) is not in mixedCase

contracts/modules/internal/ValidationModuleInternal.sol#L35-L42


 - [ ] ID-133
Function [EnforcementModule.__EnforcementModule_init_unchained()](contracts/modules/wrapper/mandatory/EnforcementModule.sol#L44-L46) is not in mixedCase

contracts/modules/wrapper/mandatory/EnforcementModule.sol#L44-L46


 - [ ] ID-134
Parameter [RuleMock.validateTransfer(address,address,uint256)._from](contracts/mocks/RuleEngine/RuleMock.sol#L14) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L14


 - [ ] ID-135
Variable [CMTAT_PROXY.__gap](contracts/CMTAT_PROXY.sol#L24) is not in mixedCase

contracts/CMTAT_PROXY.sol#L24


## unused-state
Impact: Informational
Confidence: High
 - [ ] ID-136
[CodeList.TEXT_CODE_NOT_FOUND](contracts/mocks/RuleEngine/CodeList.sol#L9) is never used in [RuleEngineMock](contracts/mocks/RuleEngine/RuleEngineMock.sol#L14-L84)

contracts/mocks/RuleEngine/CodeList.sol#L9


 - [ ] ID-137
[CodeList.TEXT_AMOUNT_TOO_HIGH](contracts/mocks/RuleEngine/CodeList.sol#L8) is never used in [RuleEngineMock](contracts/mocks/RuleEngine/RuleEngineMock.sol#L14-L84)

contracts/mocks/RuleEngine/CodeList.sol#L8


 - [ ] ID-138
[CodeList.AMOUNT_TOO_HIGH](contracts/mocks/RuleEngine/CodeList.sol#L7) is never used in [RuleEngineMock](contracts/mocks/RuleEngine/RuleEngineMock.sol#L14-L84)

contracts/mocks/RuleEngine/CodeList.sol#L7


 - [ ] ID-139
[CMTAT_PROXY.__gap](contracts/CMTAT_PROXY.sol#L24) is never used in [CMTAT_PROXY](contracts/CMTAT_PROXY.sol#L8-L25)

contracts/CMTAT_PROXY.sol#L24


## constable-states
Impact: Optimization
Confidence: High
 - [ ] ID-140
[BaseModule.deployedWithProxy](contracts/modules/wrapper/mandatory/BaseModule.sol#L11) should be constant 

contracts/modules/wrapper/mandatory/BaseModule.sol#L11


## immutable-states
Impact: Optimization
Confidence: High
 - [ ] ID-141
[BaseModule.deployedWithProxy](contracts/modules/wrapper/mandatory/BaseModule.sol#L11) should be immutable 

contracts/modules/wrapper/mandatory/BaseModule.sol#L11


