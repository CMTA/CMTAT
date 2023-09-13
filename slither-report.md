**THIS CHECKLIST IS NOT COMPLETE**. Use `--show-ignored-findings` to show all the results.
Summary
 - [uninitialized-local](#uninitialized-local) (1 results) (Medium)
 - [calls-loop](#calls-loop) (4 results) (Low)
 - [timestamp](#timestamp) (6 results) (Low)
 - [costly-loop](#costly-loop) (2 results) (Informational)
 - [dead-code](#dead-code) (16 results) (Informational)
 - [solc-version](#solc-version) (29 results) (Informational)
 - [naming-convention](#naming-convention) (65 results) (Informational)
 - [unused-state](#unused-state) (1 results) (Informational)
 - [constable-states](#constable-states) (1 results) (Optimization)
 - [immutable-states](#immutable-states) (1 results) (Optimization)
## uninitialized-local
Impact: Medium
Confidence: Medium
 - [ ] ID-0
[ERC20SnapshotModuleInternal._findScheduledMostRecentPastSnapshot().mostRecent](contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L473) is a local variable never initialized

contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L473


## calls-loop
Impact: Low
Confidence: Medium
 - [ ] ID-1
[RuleEngineMock.messageForTransferRestriction(uint8)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L74-L88) has external calls inside a loop: [_rules[i].messageForTransferRestriction(_restrictionCode)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L80-L81)

contracts/mocks/RuleEngine/RuleEngineMock.sol#L74-L88


 - [ ] ID-2
[RuleEngineMock.messageForTransferRestriction(uint8)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L74-L88) has external calls inside a loop: [_rules[i].canReturnTransferRestrictionCode(_restrictionCode)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L79)

contracts/mocks/RuleEngine/RuleEngineMock.sol#L74-L88


 - [ ] ID-3
[ValidationModuleInternal._validateTransfer(address,address,uint256)](contracts/modules/internal/ValidationModuleInternal.sol#L47-L53) has external calls inside a loop: [ruleEngine.validateTransfer(from,to,amount)](contracts/modules/internal/ValidationModuleInternal.sol#L52)

contracts/modules/internal/ValidationModuleInternal.sol#L47-L53


 - [ ] ID-4
[RuleEngineMock.detectTransferRestriction(address,address,uint256)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L40-L60) has external calls inside a loop: [restriction = _rules[i].detectTransferRestriction(_from,_to,_amount)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L47-L51)

contracts/mocks/RuleEngine/RuleEngineMock.sol#L40-L60


## timestamp
Impact: Low
Confidence: Medium
 - [ ] ID-5
[ERC20SnapshotModuleInternal._findScheduledMostRecentPastSnapshot()](contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L460-L488) uses timestamp for comparisons
	Dangerous comparisons:
	- [_scheduledSnapshots[i] <= block.timestamp](contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L476)

contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L460-L488


 - [ ] ID-6
[ERC20SnapshotModuleInternal._scheduleSnapshotNotOptimized(uint256)](contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L116-L144) uses timestamp for comparisons
	Dangerous comparisons:
	- [time <= block.timestamp](contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L117)

contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L116-L144


 - [ ] ID-7
[ERC20SnapshotModuleInternal._unscheduleSnapshotNotOptimized(uint256)](contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L217-L232) uses timestamp for comparisons
	Dangerous comparisons:
	- [time <= block.timestamp](contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L218)

contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L217-L232


 - [ ] ID-8
[ERC20SnapshotModuleInternal._unscheduleLastSnapshot(uint256)](contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L195-L209) uses timestamp for comparisons
	Dangerous comparisons:
	- [time <= block.timestamp](contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L197)

contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L195-L209


 - [ ] ID-9
[ERC20SnapshotModuleInternal._rescheduleSnapshot(uint256,uint256)](contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L149-L190) uses timestamp for comparisons
	Dangerous comparisons:
	- [oldTime <= block.timestamp](contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L151)
	- [newTime <= block.timestamp](contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L154)

contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L149-L190


 - [ ] ID-10
[ERC20SnapshotModuleInternal._scheduleSnapshot(uint256)](contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L85-L111) uses timestamp for comparisons
	Dangerous comparisons:
	- [time <= block.timestamp](contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L87)

contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L85-L111


## costly-loop
Impact: Informational
Confidence: Medium
 - [ ] ID-11
[ERC20SnapshotModuleInternal._setCurrentSnapshot()](contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L406-L415) has costly operations inside a loop:
	- [_currentSnapshotIndex = scheduleSnapshotIndex](contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L413)

contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L406-L415


 - [ ] ID-12
[ERC20SnapshotModuleInternal._setCurrentSnapshot()](contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L406-L415) has costly operations inside a loop:
	- [_currentSnapshotTime = scheduleSnapshotTime](contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L412)

contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L406-L415


## dead-code
Impact: Informational
Confidence: Medium
 - [ ] ID-13
[MetaTxModule._msgData()](contracts/modules/wrapper/extensions/MetaTxModule.sol#L33-L41) is never used and should be removed

contracts/modules/wrapper/extensions/MetaTxModule.sol#L33-L41


 - [ ] ID-14
[PauseModule.__PauseModule_init(address,uint48)](contracts/modules/wrapper/core/PauseModule.sol#L25-L40) is never used and should be removed

contracts/modules/wrapper/core/PauseModule.sol#L25-L40


 - [ ] ID-15
[ValidationModule.__ValidationModule_init(IEIP1404Wrapper,address,uint48)](contracts/modules/wrapper/controller/ValidationModule.sol#L27-L54) is never used and should be removed

contracts/modules/wrapper/controller/ValidationModule.sol#L27-L54


 - [ ] ID-16
[ERC20MintModule.__ERC20MintModule_init(string,string,address,uint48)](contracts/modules/wrapper/core/ERC20MintModule.sol#L16-L36) is never used and should be removed

contracts/modules/wrapper/core/ERC20MintModule.sol#L16-L36


 - [ ] ID-17
[CMTAT_BASE._msgData()](contracts/modules/CMTAT_BASE.sol#L216-L223) is never used and should be removed

contracts/modules/CMTAT_BASE.sol#L216-L223


 - [ ] ID-18
[DebtBaseModule.__DebtBaseModule_init(address,uint48)](contracts/modules/wrapper/extensions/DebtModule/DebtBaseModule.sol#L58-L75) is never used and should be removed

contracts/modules/wrapper/extensions/DebtModule/DebtBaseModule.sol#L58-L75


 - [ ] ID-19
[ERC20BaseModule.__ERC20Module_init(string,string,uint8)](contracts/modules/wrapper/core/ERC20BaseModule.sol#L27-L38) is never used and should be removed

contracts/modules/wrapper/core/ERC20BaseModule.sol#L27-L38


 - [ ] ID-20
[CreditEventsModule.__CreditEvents_init(address,uint48)](contracts/modules/wrapper/extensions/DebtModule/CreditEventsModule.sol#L25-L42) is never used and should be removed

contracts/modules/wrapper/extensions/DebtModule/CreditEventsModule.sol#L25-L42


 - [ ] ID-21
[ERC20BurnModule.__ERC20BurnModule_init(string,string,address,uint48)](contracts/modules/wrapper/core/ERC20BurnModule.sol#L15-L35) is never used and should be removed

contracts/modules/wrapper/core/ERC20BurnModule.sol#L15-L35


 - [ ] ID-22
[ValidationModuleInternal.__Validation_init(IEIP1404Wrapper)](contracts/modules/internal/ValidationModuleInternal.sol#L28-L33) is never used and should be removed

contracts/modules/internal/ValidationModuleInternal.sol#L28-L33


 - [ ] ID-23
[EnforcementModuleInternal.__Enforcement_init()](contracts/modules/internal/EnforcementModuleInternal.sol#L43-L46) is never used and should be removed

contracts/modules/internal/EnforcementModuleInternal.sol#L43-L46


 - [ ] ID-24
[ERC20SnapshotModule.__ERC20SnasphotModule_init(string,string,address,uint48)](contracts/modules/wrapper/extensions/ERC20SnapshotModule.sol#L19-L43) is never used and should be removed

contracts/modules/wrapper/extensions/ERC20SnapshotModule.sol#L19-L43


 - [ ] ID-25
[BaseModule.__Base_init(string,string,string,uint256,address,uint48)](contracts/modules/wrapper/core/BaseModule.sol#L41-L61) is never used and should be removed

contracts/modules/wrapper/core/BaseModule.sol#L41-L61


 - [ ] ID-26
[ERC20SnapshotModuleInternal.__ERC20Snapshot_init(string,string)](contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L67-L74) is never used and should be removed

contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L67-L74


 - [ ] ID-27
[EnforcementModule.__EnforcementModule_init(address,uint48)](contracts/modules/wrapper/core/EnforcementModule.sol#L25-L42) is never used and should be removed

contracts/modules/wrapper/core/EnforcementModule.sol#L25-L42


 - [ ] ID-28
[AuthorizationModule.__AuthorizationModule_init(address,uint48)](contracts/modules/security/AuthorizationModule.sol#L29-L42) is never used and should be removed

contracts/modules/security/AuthorizationModule.sol#L29-L42


## solc-version
Impact: Informational
Confidence: High
 - [ ] ID-29
Pragma version[^0.8.20](contracts/modules/internal/ValidationModuleInternal.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

contracts/modules/internal/ValidationModuleInternal.sol#L3


 - [ ] ID-30
Pragma version[^0.8.20](contracts/modules/wrapper/core/ERC20BurnModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

contracts/modules/wrapper/core/ERC20BurnModule.sol#L3


 - [ ] ID-31
Pragma version[^0.8.20](contracts/CMTAT_PROXY.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

contracts/CMTAT_PROXY.sol#L3


 - [ ] ID-32
Pragma version[^0.8.20](contracts/modules/CMTAT_BASE.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

contracts/modules/CMTAT_BASE.sol#L3


 - [ ] ID-33
Pragma version[^0.8.20](contracts/libraries/Errors.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

contracts/libraries/Errors.sol#L3


 - [ ] ID-34
Pragma version[^0.8.20](contracts/mocks/MinimalForwarderMock.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

contracts/mocks/MinimalForwarderMock.sol#L3


 - [ ] ID-35
Pragma version[^0.8.20](contracts/modules/security/AuthorizationModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

contracts/modules/security/AuthorizationModule.sol#L3


 - [ ] ID-36
Pragma version[^0.8.20](contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L3


 - [ ] ID-37
solc-0.8.20 is not recommended for deployment

 - [ ] ID-38
Pragma version[^0.8.0](contracts/mocks/RuleEngine/interfaces/IRuleEngine.sol#L3) allows old versions

contracts/mocks/RuleEngine/interfaces/IRuleEngine.sol#L3


 - [ ] ID-39
Pragma version[^0.8.0](contracts/interfaces/IEIP1404/IEIP1404.sol#L3) allows old versions

contracts/interfaces/IEIP1404/IEIP1404.sol#L3


 - [ ] ID-40
Pragma version[^0.8.0](contracts/mocks/RuleEngine/interfaces/IRule.sol#L3) allows old versions

contracts/mocks/RuleEngine/interfaces/IRule.sol#L3


 - [ ] ID-41
Pragma version[^0.8.20](contracts/modules/internal/EnforcementModuleInternal.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

contracts/modules/internal/EnforcementModuleInternal.sol#L3


 - [ ] ID-42
Pragma version[^0.8.20](contracts/modules/wrapper/core/BaseModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

contracts/modules/wrapper/core/BaseModule.sol#L3


 - [ ] ID-43
Pragma version[^0.8.20](contracts/modules/wrapper/extensions/DebtModule/DebtBaseModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

contracts/modules/wrapper/extensions/DebtModule/DebtBaseModule.sol#L3


 - [ ] ID-44
Pragma version[^0.8.0](contracts/interfaces/IDebtGlobal.sol#L3) allows old versions

contracts/interfaces/IDebtGlobal.sol#L3


 - [ ] ID-45
Pragma version[^0.8.20](contracts/mocks/RuleEngine/RuleMock.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

contracts/mocks/RuleEngine/RuleMock.sol#L3


 - [ ] ID-46
Pragma version[^0.8.20](contracts/modules/wrapper/core/ERC20MintModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

contracts/modules/wrapper/core/ERC20MintModule.sol#L3


 - [ ] ID-47
Pragma version[^0.8.20](contracts/modules/wrapper/extensions/ERC20SnapshotModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

contracts/modules/wrapper/extensions/ERC20SnapshotModule.sol#L3


 - [ ] ID-48
Pragma version[^0.8.20](contracts/modules/wrapper/controller/ValidationModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

contracts/modules/wrapper/controller/ValidationModule.sol#L3


 - [ ] ID-49
Pragma version[^0.8.20](contracts/mocks/RuleEngine/CodeList.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

contracts/mocks/RuleEngine/CodeList.sol#L3


 - [ ] ID-50
Pragma version[^0.8.0](contracts/interfaces/IEIP1404/IEIP1404Wrapper.sol#L3) allows old versions

contracts/interfaces/IEIP1404/IEIP1404Wrapper.sol#L3


 - [ ] ID-51
Pragma version[^0.8.20](contracts/modules/wrapper/extensions/DebtModule/CreditEventsModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

contracts/modules/wrapper/extensions/DebtModule/CreditEventsModule.sol#L3


 - [ ] ID-52
Pragma version[^0.8.20](contracts/modules/wrapper/core/ERC20BaseModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

contracts/modules/wrapper/core/ERC20BaseModule.sol#L3


 - [ ] ID-53
Pragma version[^0.8.20](contracts/modules/wrapper/core/PauseModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

contracts/modules/wrapper/core/PauseModule.sol#L3


 - [ ] ID-54
Pragma version[^0.8.20](contracts/mocks/RuleEngine/RuleEngineMock.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

contracts/mocks/RuleEngine/RuleEngineMock.sol#L3


 - [ ] ID-55
Pragma version[^0.8.20](contracts/modules/wrapper/extensions/MetaTxModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

contracts/modules/wrapper/extensions/MetaTxModule.sol#L3


 - [ ] ID-56
Pragma version[^0.8.20](contracts/CMTAT_STANDALONE.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

contracts/CMTAT_STANDALONE.sol#L3


 - [ ] ID-57
Pragma version[^0.8.20](contracts/modules/wrapper/core/EnforcementModule.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

contracts/modules/wrapper/core/EnforcementModule.sol#L3


## naming-convention
Impact: Informational
Confidence: High
 - [ ] ID-58
Variable [RuleEngineMock._rules](contracts/mocks/RuleEngine/RuleEngineMock.sol#L14) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L14


 - [ ] ID-59
Function [ERC20BurnModule.__ERC20BurnModule_init(string,string,address,uint48)](contracts/modules/wrapper/core/ERC20BurnModule.sol#L15-L35) is not in mixedCase

contracts/modules/wrapper/core/ERC20BurnModule.sol#L15-L35


 - [ ] ID-60
Variable [CreditEventsModule.__gap](contracts/modules/wrapper/extensions/DebtModule/CreditEventsModule.sol#L99) is not in mixedCase

contracts/modules/wrapper/extensions/DebtModule/CreditEventsModule.sol#L99


 - [ ] ID-61
Function [EnforcementModuleInternal.__Enforcement_init()](contracts/modules/internal/EnforcementModuleInternal.sol#L43-L46) is not in mixedCase

contracts/modules/internal/EnforcementModuleInternal.sol#L43-L46


 - [ ] ID-62
Function [AuthorizationModule.__AuthorizationModule_init(address,uint48)](contracts/modules/security/AuthorizationModule.sol#L29-L42) is not in mixedCase

contracts/modules/security/AuthorizationModule.sol#L29-L42


 - [ ] ID-63
Function [BaseModule.__Base_init(string,string,string,uint256,address,uint48)](contracts/modules/wrapper/core/BaseModule.sol#L41-L61) is not in mixedCase

contracts/modules/wrapper/core/BaseModule.sol#L41-L61


 - [ ] ID-64
Enum [IEIP1404Wrapper.REJECTED_CODE_BASE](contracts/interfaces/IEIP1404/IEIP1404Wrapper.sol#L11-L16) is not in CapWords

contracts/interfaces/IEIP1404/IEIP1404Wrapper.sol#L11-L16


 - [ ] ID-65
Parameter [RuleEngineMock.detectTransferRestriction(address,address,uint256)._amount](contracts/mocks/RuleEngine/RuleEngineMock.sol#L43) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L43


 - [ ] ID-66
Function [ValidationModuleInternal.__Validation_init(IEIP1404Wrapper)](contracts/modules/internal/ValidationModuleInternal.sol#L28-L33) is not in mixedCase

contracts/modules/internal/ValidationModuleInternal.sol#L28-L33


 - [ ] ID-67
Function [DebtBaseModule.__DebtBaseModule_init(address,uint48)](contracts/modules/wrapper/extensions/DebtModule/DebtBaseModule.sol#L58-L75) is not in mixedCase

contracts/modules/wrapper/extensions/DebtModule/DebtBaseModule.sol#L58-L75


 - [ ] ID-68
Contract [CMTAT_PROXY](contracts/CMTAT_PROXY.sol#L7-L23) is not in CapWords

contracts/CMTAT_PROXY.sol#L7-L23


 - [ ] ID-69
Function [ERC20SnapshotModuleInternal.__ERC20Snapshot_init(string,string)](contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L67-L74) is not in mixedCase

contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L67-L74


 - [ ] ID-70
Function [PauseModule.__PauseModule_init_unchained()](contracts/modules/wrapper/core/PauseModule.sol#L42-L44) is not in mixedCase

contracts/modules/wrapper/core/PauseModule.sol#L42-L44


 - [ ] ID-71
Function [CreditEventsModule.__CreditEvents_init_unchained()](contracts/modules/wrapper/extensions/DebtModule/CreditEventsModule.sol#L44-L46) is not in mixedCase

contracts/modules/wrapper/extensions/DebtModule/CreditEventsModule.sol#L44-L46


 - [ ] ID-72
Variable [CMTAT_BASE.__gap](contracts/modules/CMTAT_BASE.sol#L225) is not in mixedCase

contracts/modules/CMTAT_BASE.sol#L225


 - [ ] ID-73
Function [EnforcementModuleInternal.__Enforcement_init_unchained()](contracts/modules/internal/EnforcementModuleInternal.sol#L48-L50) is not in mixedCase

contracts/modules/internal/EnforcementModuleInternal.sol#L48-L50


 - [ ] ID-74
Variable [ValidationModuleInternal.__gap](contracts/modules/internal/ValidationModuleInternal.sol#L75) is not in mixedCase

contracts/modules/internal/ValidationModuleInternal.sol#L75


 - [ ] ID-75
Function [ERC20BurnModule.__ERC20BurnModule_init_unchained()](contracts/modules/wrapper/core/ERC20BurnModule.sol#L37-L39) is not in mixedCase

contracts/modules/wrapper/core/ERC20BurnModule.sol#L37-L39


 - [ ] ID-76
Function [CreditEventsModule.__CreditEvents_init(address,uint48)](contracts/modules/wrapper/extensions/DebtModule/CreditEventsModule.sol#L25-L42) is not in mixedCase

contracts/modules/wrapper/extensions/DebtModule/CreditEventsModule.sol#L25-L42


 - [ ] ID-77
Variable [BaseModule.__gap](contracts/modules/wrapper/core/BaseModule.sol#L117) is not in mixedCase

contracts/modules/wrapper/core/BaseModule.sol#L117


 - [ ] ID-78
Variable [ValidationModule.__gap](contracts/modules/wrapper/controller/ValidationModule.sol#L144) is not in mixedCase

contracts/modules/wrapper/controller/ValidationModule.sol#L144


 - [ ] ID-79
Function [ValidationModule.__ValidationModule_init(IEIP1404Wrapper,address,uint48)](contracts/modules/wrapper/controller/ValidationModule.sol#L27-L54) is not in mixedCase

contracts/modules/wrapper/controller/ValidationModule.sol#L27-L54


 - [ ] ID-80
Variable [EnforcementModule.__gap](contracts/modules/wrapper/core/EnforcementModule.sol#L74) is not in mixedCase

contracts/modules/wrapper/core/EnforcementModule.sol#L74


 - [ ] ID-81
Contract [CMTAT_STANDALONE](contracts/CMTAT_STANDALONE.sol#L7-L52) is not in CapWords

contracts/CMTAT_STANDALONE.sol#L7-L52


 - [ ] ID-82
Variable [DebtBaseModule.__gap](contracts/modules/wrapper/extensions/DebtModule/DebtBaseModule.sol#L265) is not in mixedCase

contracts/modules/wrapper/extensions/DebtModule/DebtBaseModule.sol#L265


 - [ ] ID-83
Function [PauseModule.__PauseModule_init(address,uint48)](contracts/modules/wrapper/core/PauseModule.sol#L25-L40) is not in mixedCase

contracts/modules/wrapper/core/PauseModule.sol#L25-L40


 - [ ] ID-84
Function [EnforcementModule.__EnforcementModule_init(address,uint48)](contracts/modules/wrapper/core/EnforcementModule.sol#L25-L42) is not in mixedCase

contracts/modules/wrapper/core/EnforcementModule.sol#L25-L42


 - [ ] ID-85
Variable [AuthorizationModule.__gap](contracts/modules/security/AuthorizationModule.sol#L80) is not in mixedCase

contracts/modules/security/AuthorizationModule.sol#L80


 - [ ] ID-86
Parameter [RuleEngineMock.validateTransfer(address,address,uint256)._amount](contracts/mocks/RuleEngine/RuleEngineMock.sol#L65) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L65


 - [ ] ID-87
Parameter [RuleMock.validateTransfer(address,address,uint256)._to](contracts/mocks/RuleEngine/RuleMock.sol#L14) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L14


 - [ ] ID-88
Function [ERC20BaseModule.__ERC20Module_init_unchained(uint8)](contracts/modules/wrapper/core/ERC20BaseModule.sol#L40-L44) is not in mixedCase

contracts/modules/wrapper/core/ERC20BaseModule.sol#L40-L44


 - [ ] ID-89
Variable [EnforcementModuleInternal.__gap](contracts/modules/internal/EnforcementModuleInternal.sol#L91) is not in mixedCase

contracts/modules/internal/EnforcementModuleInternal.sol#L91


 - [ ] ID-90
Parameter [RuleMock.canReturnTransferRestrictionCode(uint8)._restrictionCode](contracts/mocks/RuleEngine/RuleMock.sol#L35) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L35


 - [ ] ID-91
Parameter [RuleEngineMock.validateTransfer(address,address,uint256)._to](contracts/mocks/RuleEngine/RuleEngineMock.sol#L64) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L64


 - [ ] ID-92
Function [BaseModule.__Base_init_unchained(string,string,string,uint256)](contracts/modules/wrapper/core/BaseModule.sol#L63-L73) is not in mixedCase

contracts/modules/wrapper/core/BaseModule.sol#L63-L73


 - [ ] ID-93
Parameter [RuleEngineMock.validateTransfer(address,address,uint256)._from](contracts/mocks/RuleEngine/RuleEngineMock.sol#L63) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L63


 - [ ] ID-94
Parameter [RuleMock.validateTransfer(address,address,uint256)._amount](contracts/mocks/RuleEngine/RuleMock.sol#L15) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L15


 - [ ] ID-95
Function [AuthorizationModule.__AuthorizationModule_init_unchained()](contracts/modules/security/AuthorizationModule.sol#L51-L53) is not in mixedCase

contracts/modules/security/AuthorizationModule.sol#L51-L53


 - [ ] ID-96
Variable [PauseModule.__gap](contracts/modules/wrapper/core/PauseModule.sol#L100) is not in mixedCase

contracts/modules/wrapper/core/PauseModule.sol#L100


 - [ ] ID-97
Function [CMTAT_BASE.__CMTAT_init_unchained()](contracts/modules/CMTAT_BASE.sol#L147-L149) is not in mixedCase

contracts/modules/CMTAT_BASE.sol#L147-L149


 - [ ] ID-98
Variable [ERC20SnapshotModule.__gap](contracts/modules/wrapper/extensions/ERC20SnapshotModule.sol#L103) is not in mixedCase

contracts/modules/wrapper/extensions/ERC20SnapshotModule.sol#L103


 - [ ] ID-99
Parameter [RuleMock.detectTransferRestriction(address,address,uint256)._amount](contracts/mocks/RuleEngine/RuleMock.sol#L26) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L26


 - [ ] ID-100
Parameter [RuleMock.messageForTransferRestriction(uint8)._restrictionCode](contracts/mocks/RuleEngine/RuleMock.sol#L41) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L41


 - [ ] ID-101
Function [ERC20MintModule.__ERC20MintModule_init_unchained()](contracts/modules/wrapper/core/ERC20MintModule.sol#L38-L40) is not in mixedCase

contracts/modules/wrapper/core/ERC20MintModule.sol#L38-L40


 - [ ] ID-102
Parameter [RuleEngineMock.detectTransferRestriction(address,address,uint256)._to](contracts/mocks/RuleEngine/RuleEngineMock.sol#L42) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L42


 - [ ] ID-103
Variable [MetaTxModule.__gap](contracts/modules/wrapper/extensions/MetaTxModule.sol#L43) is not in mixedCase

contracts/modules/wrapper/extensions/MetaTxModule.sol#L43


 - [ ] ID-104
Function [ERC20BaseModule.__ERC20Module_init(string,string,uint8)](contracts/modules/wrapper/core/ERC20BaseModule.sol#L27-L38) is not in mixedCase

contracts/modules/wrapper/core/ERC20BaseModule.sol#L27-L38


 - [ ] ID-105
Function [ERC20SnapshotModule.__ERC20SnasphotModule_init(string,string,address,uint48)](contracts/modules/wrapper/extensions/ERC20SnapshotModule.sol#L19-L43) is not in mixedCase

contracts/modules/wrapper/extensions/ERC20SnapshotModule.sol#L19-L43


 - [ ] ID-106
Variable [ERC20BurnModule.__gap](contracts/modules/wrapper/core/ERC20BurnModule.sol#L96) is not in mixedCase

contracts/modules/wrapper/core/ERC20BurnModule.sol#L96


 - [ ] ID-107
Variable [ERC20BaseModule.__gap](contracts/modules/wrapper/core/ERC20BaseModule.sol#L138) is not in mixedCase

contracts/modules/wrapper/core/ERC20BaseModule.sol#L138


 - [ ] ID-108
Function [ERC20MintModule.__ERC20MintModule_init(string,string,address,uint48)](contracts/modules/wrapper/core/ERC20MintModule.sol#L16-L36) is not in mixedCase

contracts/modules/wrapper/core/ERC20MintModule.sol#L16-L36


 - [ ] ID-109
Contract [CMTAT_BASE](contracts/modules/CMTAT_BASE.sol#L30-L226) is not in CapWords

contracts/modules/CMTAT_BASE.sol#L30-L226


 - [ ] ID-110
Parameter [RuleEngineMock.messageForTransferRestriction(uint8)._restrictionCode](contracts/mocks/RuleEngine/RuleEngineMock.sol#L75) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L75


 - [ ] ID-111
Variable [ERC20MintModule.__gap](contracts/modules/wrapper/core/ERC20MintModule.sol#L95) is not in mixedCase

contracts/modules/wrapper/core/ERC20MintModule.sol#L95


 - [ ] ID-112
Function [CMTAT_BASE.__CMTAT_init(address,uint48,string,string,uint8,string,string,IEIP1404Wrapper,string,uint256)](contracts/modules/CMTAT_BASE.sol#L88-L145) is not in mixedCase

contracts/modules/CMTAT_BASE.sol#L88-L145


 - [ ] ID-113
Function [ValidationModule.__ValidationModule_init_unchained()](contracts/modules/wrapper/controller/ValidationModule.sol#L56-L58) is not in mixedCase

contracts/modules/wrapper/controller/ValidationModule.sol#L56-L58


 - [ ] ID-114
Function [DebtBaseModule.__DebtBaseModule_init_unchained()](contracts/modules/wrapper/extensions/DebtModule/DebtBaseModule.sol#L77-L79) is not in mixedCase

contracts/modules/wrapper/extensions/DebtModule/DebtBaseModule.sol#L77-L79


 - [ ] ID-115
Parameter [RuleEngineMock.detectTransferRestriction(address,address,uint256)._from](contracts/mocks/RuleEngine/RuleEngineMock.sol#L41) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L41


 - [ ] ID-116
Function [ERC20SnapshotModule.__ERC20SnasphotModule_init_unchained()](contracts/modules/wrapper/extensions/ERC20SnapshotModule.sol#L45-L47) is not in mixedCase

contracts/modules/wrapper/extensions/ERC20SnapshotModule.sol#L45-L47


 - [ ] ID-117
Function [ValidationModuleInternal.__Validation_init_unchained(IEIP1404Wrapper)](contracts/modules/internal/ValidationModuleInternal.sol#L35-L42) is not in mixedCase

contracts/modules/internal/ValidationModuleInternal.sol#L35-L42


 - [ ] ID-118
Variable [ERC20SnapshotModuleInternal.__gap](contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L490) is not in mixedCase

contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L490


 - [ ] ID-119
Function [EnforcementModule.__EnforcementModule_init_unchained()](contracts/modules/wrapper/core/EnforcementModule.sol#L44-L46) is not in mixedCase

contracts/modules/wrapper/core/EnforcementModule.sol#L44-L46


 - [ ] ID-120
Function [ERC20SnapshotModuleInternal.__ERC20Snapshot_init_unchained()](contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L76-L79) is not in mixedCase

contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L76-L79


 - [ ] ID-121
Parameter [RuleMock.validateTransfer(address,address,uint256)._from](contracts/mocks/RuleEngine/RuleMock.sol#L13) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L13


 - [ ] ID-122
Variable [CMTAT_PROXY.__gap](contracts/CMTAT_PROXY.sol#L22) is not in mixedCase

contracts/CMTAT_PROXY.sol#L22


## unused-state
Impact: Informational
Confidence: High
 - [ ] ID-123
[BaseModule.deployedWithProxy](contracts/modules/wrapper/core/BaseModule.sol#L17) is never used in [CMTAT_STANDALONE](contracts/CMTAT_STANDALONE.sol#L7-L52)

contracts/modules/wrapper/core/BaseModule.sol#L17


## constable-states
Impact: Optimization
Confidence: High
 - [ ] ID-124
[BaseModule.deployedWithProxy](contracts/modules/wrapper/core/BaseModule.sol#L17) should be constant 

contracts/modules/wrapper/core/BaseModule.sol#L17


## immutable-states
Impact: Optimization
Confidence: High
 - [ ] ID-125
[BaseModule.deployedWithProxy](contracts/modules/wrapper/core/BaseModule.sol#L17) should be immutable 

contracts/modules/wrapper/core/BaseModule.sol#L17


