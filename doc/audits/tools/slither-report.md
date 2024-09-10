**THIS CHECKLIST IS NOT COMPLETE**. Use `--show-ignored-findings` to show all the results.
Summary
 - [incorrect-equality](#incorrect-equality) (2 results) (Medium)
 - [uninitialized-local](#uninitialized-local) (1 results) (Medium)
 - [unused-return](#unused-return) (1 results) (Medium)
 - [shadowing-local](#shadowing-local) (1 results) (Low)
 - [missing-zero-check](#missing-zero-check) (1 results) (Low)
 - [calls-loop](#calls-loop) (4 results) (Low)
 - [timestamp](#timestamp) (5 results) (Low)
 - [assembly](#assembly) (9 results) (Informational)
 - [costly-loop](#costly-loop) (1 results) (Informational)
 - [dead-code](#dead-code) (1 results) (Informational)
 - [solc-version](#solc-version) (1 results) (Informational)
 - [naming-convention](#naming-convention) (56 results) (Informational)
 - [similar-names](#similar-names) (3 results) (Informational)
 - [too-many-digits](#too-many-digits) (2 results) (Informational)
 - [unused-import](#unused-import) (6 results) (Informational)
 - [immutable-states](#immutable-states) (1 results) (Optimization)
## incorrect-equality
Impact: Medium
Confidence: High
 - [ ] ID-0
	[DocumentEngineMock.removeDocument(bytes32)](contracts/mocks/DocumentEngineMock.sol#L72-L89) uses a dangerous strict equality:
	- [bytes(documents[name_].uri).length == 0](contracts/mocks/DocumentEngineMock.sol#L73)

contracts/mocks/DocumentEngineMock.sol#L72-L89


 - [ ] ID-1
	[DocumentEngineMock.getDocument(bytes32)](contracts/mocks/DocumentEngineMock.sol#L37-L49) uses a dangerous strict equality:
	- [bytes(documents[name_].uri).length == 0](contracts/mocks/DocumentEngineMock.sol#L43)

contracts/mocks/DocumentEngineMock.sol#L37-L49

## uninitialized-local

> The concerned variable local `mostRecent` is initialized in the loop

Impact: Medium
Confidence: Medium

 - [ ] ID-2
[SnapshotModuleBase._findScheduledMostRecentPastSnapshot().mostRecent](contracts/modules/internal/base/SnapshotModuleBase.sol#L385) is a local variable never initialized

contracts/modules/internal/base/SnapshotModuleBase.sol#L385

## unused-return

> Not the case

Impact: Medium
Confidence: Medium
 - [ ] ID-3
[DocumentModule.getDocument(bytes32)](contracts/modules/wrapper/extensions/DocumentModule.sol#L74-L81) ignores return value by [$._documentEngine.getDocument(_name)](contracts/modules/wrapper/extensions/DocumentModule.sol#L77)

contracts/modules/wrapper/extensions/DocumentModule.sol#L74-L81

## shadowing-local

> Mock: not intended to be used in production

Impact: Low
Confidence: High

 - [ ] ID-4
	[IDebtEngineMock.setCreditEvents(IDebtGlobal.CreditEvents).creditEvents](contracts/mocks/DebtEngineMock.sol#L7) shadows:
	- [IDebtEngine.creditEvents()](contracts/interfaces/engine/IDebtEngine.sol#L17) (function)

contracts/mocks/DebtEngineMock.sol#L7

## missing-zero-check

> Mock: not intended to be used in production

Impact: Low
Confidence: Medium
 - [ ] ID-5
	[AuthorizationEngineMock.authorizeAdminChange(address).newAdmin](contracts/mocks/AuthorizationEngineMock.sol#L21) lacks a zero-check on :
		- [nextAdmin = newAdmin](contracts/mocks/AuthorizationEngineMock.sol#L22)

contracts/mocks/AuthorizationEngineMock.sol#L21

## calls-loop

> ValidationModuleInternal: Acknowledge
>
> Mock: not intended to be used in production
> ValidationModuleInternal: the loop happens only for batch function. A relevant alternative could be the creation of a batch function for the RuleEngine, but for the moment we don't have an implemented solution.

Impact: Low
Confidence: Medium
 - [ ] ID-6
[RuleEngineMock.messageForTransferRestriction(uint8)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L83-L97) has external calls inside a loop: [_rules[i].canReturnTransferRestrictionCode(_restrictionCode)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L88)

contracts/mocks/RuleEngine/RuleEngineMock.sol#L83-L97


 - [ ] ID-7
[RuleEngineMock.messageForTransferRestriction(uint8)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L83-L97) has external calls inside a loop: [_rules[i].messageForTransferRestriction(_restrictionCode)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L89-L90)

contracts/mocks/RuleEngine/RuleEngineMock.sol#L83-L97


 - [ ] ID-8
[ValidationModuleInternal._operateOnTransfer(address,address,uint256)](contracts/modules/internal/ValidationModuleInternal.sol#L89-L92) has external calls inside a loop: [$._ruleEngine.operateOnTransfer(from,to,amount)](contracts/modules/internal/ValidationModuleInternal.sol#L91)

contracts/modules/internal/ValidationModuleInternal.sol#L89-L92


 - [ ] ID-9
[RuleEngineMock.detectTransferRestriction(address,address,uint256)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L39-L59) has external calls inside a loop: [restriction = _rules[i].detectTransferRestriction(_from,_to,_amount)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L46-L50)

contracts/mocks/RuleEngine/RuleEngineMock.sol#L39-L59

## timestamp

> With the Proof of Work, it was possible for a miner to modify the timestamp in a range of about 15 seconds
>
> With the Proof Of Stake, a new block is created every 12 seconds
>
> In all cases, we are not looking for such precision

Impact: Low
Confidence: Medium
 - [ ] ID-10
	[SnapshotModuleBase._findScheduledMostRecentPastSnapshot()](contracts/modules/internal/base/SnapshotModuleBase.sol#L370-L398) uses timestamp for comparisons
	Dangerous comparisons:
	- [$._scheduledSnapshots[i] <= block.timestamp](contracts/modules/internal/base/SnapshotModuleBase.sol#L389)

contracts/modules/internal/base/SnapshotModuleBase.sol#L370-L398


 - [ ] ID-11
	[DocumentEngineMock.getDocument(bytes32)](contracts/mocks/DocumentEngineMock.sol#L37-L49) uses timestamp for comparisons
	Dangerous comparisons:
	- [bytes(documents[name_].uri).length == 0](contracts/mocks/DocumentEngineMock.sol#L43)

contracts/mocks/DocumentEngineMock.sol#L37-L49


 - [ ] ID-12
	[SnapshotModuleBase._checkTimeSnapshotAlreadyDone(uint256)](contracts/modules/internal/base/SnapshotModuleBase.sol#L420-L424) uses timestamp for comparisons
	Dangerous comparisons:
	- [time <= block.timestamp](contracts/modules/internal/base/SnapshotModuleBase.sol#L421)

contracts/modules/internal/base/SnapshotModuleBase.sol#L420-L424


 - [ ] ID-13
	[SnapshotModuleBase._checkTimeInThePast(uint256)](contracts/modules/internal/base/SnapshotModuleBase.sol#L412-L419) uses timestamp for comparisons
	Dangerous comparisons:
	- [time <= block.timestamp](contracts/modules/internal/base/SnapshotModuleBase.sol#L413)

contracts/modules/internal/base/SnapshotModuleBase.sol#L412-L419


 - [ ] ID-14
	[DocumentEngineMock.removeDocument(bytes32)](contracts/mocks/DocumentEngineMock.sol#L72-L89) uses timestamp for comparisons
	Dangerous comparisons:
	- [bytes(documents[name_].uri).length == 0](contracts/mocks/DocumentEngineMock.sol#L73)

contracts/mocks/DocumentEngineMock.sol#L72-L89

## assembly

> use to implement ERC-7201

Impact: Informational
Confidence: High
 - [ ] ID-15
	[AuthorizationModule._getAuthorizationModuleStorage()](contracts/modules/security/AuthorizationModule.sol#L114-L118) uses assembly
	- [INLINE ASM](contracts/modules/security/AuthorizationModule.sol#L115-L117)

contracts/modules/security/AuthorizationModule.sol#L114-L118


 - [ ] ID-16
	[EnforcementModuleInternal._getEnforcementModuleInternalStorage()](contracts/modules/internal/EnforcementModuleInternal.sol#L112-L116) uses assembly
	- [INLINE ASM](contracts/modules/internal/EnforcementModuleInternal.sol#L113-L115)

contracts/modules/internal/EnforcementModuleInternal.sol#L112-L116


 - [ ] ID-17
	[BaseModule._getBaseModuleStorage()](contracts/modules/wrapper/core/BaseModule.sol#L110-L114) uses assembly
	- [INLINE ASM](contracts/modules/wrapper/core/BaseModule.sol#L111-L113)

contracts/modules/wrapper/core/BaseModule.sol#L110-L114


 - [ ] ID-18
	[ValidationModuleInternal._getValidationModuleInternalStorage()](contracts/modules/internal/ValidationModuleInternal.sol#L96-L100) uses assembly
	- [INLINE ASM](contracts/modules/internal/ValidationModuleInternal.sol#L97-L99)

contracts/modules/internal/ValidationModuleInternal.sol#L96-L100


 - [ ] ID-19
	[SnapshotModuleBase._getSnapshotModuleBaseStorage()](contracts/modules/internal/base/SnapshotModuleBase.sol#L427-L431) uses assembly
	- [INLINE ASM](contracts/modules/internal/base/SnapshotModuleBase.sol#L428-L430)

contracts/modules/internal/base/SnapshotModuleBase.sol#L427-L431


 - [ ] ID-20
	[DocumentModule._getDocumentModuleStorage()](contracts/modules/wrapper/extensions/DocumentModule.sol#L96-L100) uses assembly
	- [INLINE ASM](contracts/modules/wrapper/extensions/DocumentModule.sol#L97-L99)

contracts/modules/wrapper/extensions/DocumentModule.sol#L96-L100


 - [ ] ID-21
	[PauseModule._getPauseModuleStorage()](contracts/modules/wrapper/core/PauseModule.sol#L104-L108) uses assembly
	- [INLINE ASM](contracts/modules/wrapper/core/PauseModule.sol#L105-L107)

contracts/modules/wrapper/core/PauseModule.sol#L104-L108


 - [ ] ID-22
	[DebtModule._getDebtModuleStorage()](contracts/modules/wrapper/extensions/DebtModule.sol#L94-L98) uses assembly
	- [INLINE ASM](contracts/modules/wrapper/extensions/DebtModule.sol#L95-L97)

contracts/modules/wrapper/extensions/DebtModule.sol#L94-L98


 - [ ] ID-23
	[ERC20BaseModule._getERC20BaseModuleStorage()](contracts/modules/wrapper/core/ERC20BaseModule.sol#L134-L138) uses assembly
	- [INLINE ASM](contracts/modules/wrapper/core/ERC20BaseModule.sol#L135-L137)

contracts/modules/wrapper/core/ERC20BaseModule.sol#L134-L138

## costly-loop

> Acknowledge
>
> Mocks are not destined to be used in production

Impact: Informational
Confidence: Medium
 - [ ] ID-24
	[DocumentEngineMock.removeDocument(bytes32)](contracts/mocks/DocumentEngineMock.sol#L72-L89) has costly operations inside a loop:
	- [documentNames.pop()](contracts/mocks/DocumentEngineMock.sol#L83)

contracts/mocks/DocumentEngineMock.sol#L72-L89

## dead-code

> - Implemented to be gasless compatible (see MetaTxModule)
>
> - If we remove this function, we will have the following error:
>
>   "Derived contract must override function "_msgData". Two or more base classes define function with same name and parameter types."

Impact: Informational
Confidence: Medium
 - [ ] ID-25
[CMTAT_BASE._msgData()](contracts/modules/CMTAT_BASE.sol#L232-L239) is never used and should be removed

contracts/modules/CMTAT_BASE.sol#L232-L239

## solc-version

> The version set in the config file is 0.8.27

Impact: Informational
Confidence: High
 - [ ] ID-26
	Version constraint ^0.8.20 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- VerbatimInvalidDeduplication
	- FullInlinerNonExpressionSplitArgumentEvaluationOrder
	- MissingSideEffectsOnSelectorAccess.
	 It is used by:
	- node_modules/@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol#4
	- node_modules/@openzeppelin/contracts-upgradeable/metatx/ERC2771ContextUpgradeable.sol#4
	- node_modules/@openzeppelin/contracts-upgradeable/metatx/ERC2771ForwarderUpgradeable.sol#4
	- node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol#4
	- node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol#4
	- node_modules/@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol#4
	- node_modules/@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol#4
	- node_modules/@openzeppelin/contracts-upgradeable/utils/NoncesUpgradeable.sol#3
	- node_modules/@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol#4
	- node_modules/@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol#4
	- node_modules/@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol#4
	- node_modules/@openzeppelin/contracts/access/AccessControl.sol#4
	- node_modules/@openzeppelin/contracts/access/IAccessControl.sol#4
	- node_modules/@openzeppelin/contracts/access/Ownable.sol#4
	- node_modules/@openzeppelin/contracts/interfaces/IERC1967.sol#4
	- node_modules/@openzeppelin/contracts/interfaces/IERC5267.sol#4
	- node_modules/@openzeppelin/contracts/interfaces/draft-IERC1822.sol#4
	- node_modules/@openzeppelin/contracts/interfaces/draft-IERC6093.sol#3
	- node_modules/@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol#4
	- node_modules/@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol#4
	- node_modules/@openzeppelin/contracts/proxy/Proxy.sol#4
	- node_modules/@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol#4
	- node_modules/@openzeppelin/contracts/proxy/beacon/IBeacon.sol#4
	- node_modules/@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol#4
	- node_modules/@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol#4
	- node_modules/@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol#4
	- node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol#4
	- node_modules/@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol#4
	- node_modules/@openzeppelin/contracts/utils/Address.sol#4
	- node_modules/@openzeppelin/contracts/utils/Arrays.sol#4
	- node_modules/@openzeppelin/contracts/utils/Context.sol#4
	- node_modules/@openzeppelin/contracts/utils/Create2.sol#4
	- node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#5
	- node_modules/@openzeppelin/contracts/utils/Strings.sol#4
	- node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol#4
	- node_modules/@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol#4
	- node_modules/@openzeppelin/contracts/utils/introspection/ERC165.sol#4
	- node_modules/@openzeppelin/contracts/utils/introspection/IERC165.sol#4
	- node_modules/@openzeppelin/contracts/utils/math/Math.sol#4
	- node_modules/@openzeppelin/contracts/utils/math/SignedMath.sol#4
	- contracts/CMTAT_PROXY.sol#3
	- contracts/CMTAT_PROXY_UUPS.sol#3
	- contracts/CMTAT_STANDALONE.sol#3
	- contracts/deployment/CMTAT_BEACON_FACTORY.sol#2
	- contracts/deployment/CMTAT_TP_FACTORY.sol#2
	- contracts/deployment/CMTAT_UUPS_FACTORY.sol#2
	- contracts/deployment/libraries/CMTATFactoryBase.sol#2
	- contracts/deployment/libraries/CMTATFactoryInvariant.sol#2
	- contracts/deployment/libraries/CMTATFactoryRoot.sol#2
	- contracts/interfaces/ICCIPToken.sol#3
	- contracts/interfaces/ICMTATConstructor.sol#7
	- contracts/interfaces/ICMTATSnapshot.sol#3
	- contracts/interfaces/draft-IERC1404/draft-IERC1404.sol#3
	- contracts/interfaces/draft-IERC1404/draft-IERC1404EnumCode.sol#3
	- contracts/interfaces/draft-IERC1404/draft-IERC1404Wrapper.sol#3
	- contracts/interfaces/engine/IAuthorizationEngine.sol#3
	- contracts/interfaces/engine/IDebtEngine.sol#3
	- contracts/interfaces/engine/IDebtGlobal.sol#3
	- contracts/interfaces/engine/IRuleEngine.sol#3
	- contracts/interfaces/engine/draft-IERC1643.sol#3
	- contracts/libraries/Errors.sol#3
	- contracts/libraries/FactoryErrors.sol#3
	- contracts/mocks/AuthorizationEngineMock.sol#3
	- contracts/mocks/DebtEngineMock.sol#3
	- contracts/mocks/DocumentEngineMock.sol#3
	- contracts/mocks/MinimalForwarderMock.sol#3
	- contracts/mocks/RuleEngine/CodeList.sol#3
	- contracts/mocks/RuleEngine/RuleEngineMock.sol#3
	- contracts/mocks/RuleEngine/RuleMock.sol#3
	- contracts/mocks/RuleEngine/interfaces/IRule.sol#3
	- contracts/mocks/RuleEngine/interfaces/IRuleEngineMock.sol#3
	- contracts/modules/CMTAT_BASE.sol#3
	- contracts/modules/internal/ERC20SnapshotModuleInternal.sol#3
	- contracts/modules/internal/EnforcementModuleInternal.sol#3
	- contracts/modules/internal/ValidationModuleInternal.sol#3
	- contracts/modules/internal/base/SnapshotModuleBase.sol#3
	- contracts/modules/security/AuthorizationModule.sol#3
	- contracts/modules/wrapper/controllers/ValidationModule.sol#3
	- contracts/modules/wrapper/core/BaseModule.sol#3
	- contracts/modules/wrapper/core/ERC20BaseModule.sol#3
	- contracts/modules/wrapper/core/ERC20BurnModule.sol#3
	- contracts/modules/wrapper/core/ERC20MintModule.sol#3
	- contracts/modules/wrapper/core/EnforcementModule.sol#3
	- contracts/modules/wrapper/core/PauseModule.sol#3
	- contracts/modules/wrapper/extensions/DebtModule.sol#3
	- contracts/modules/wrapper/extensions/DocumentModule.sol#3
	- contracts/modules/wrapper/extensions/ERC20SnapshotModule.sol#3
	- contracts/modules/wrapper/extensions/MetaTxModule.sol#3
	- contracts/test/proxy/CMTAT_PROXY_TEST.sol#3
	- contracts/test/proxy/CMTAT_PROXY_TEST_UUPS.sol#3

## naming-convention

> It is not really necessary to rename all the variables. It will generate a lot of work for a minor improvement.

Impact: Informational
Confidence: High

 - [ ] ID-27
Contract [CMTAT_PROXY_UUPS](contracts/CMTAT_PROXY_UUPS.sol#L10-L53) is not in CapWords

contracts/CMTAT_PROXY_UUPS.sol#L10-L53


 - [ ] ID-28
Enum [IERC1404EnumCode.REJECTED_CODE_BASE](contracts/interfaces/draft-IERC1404/draft-IERC1404EnumCode.sol#L9-L14) is not in CapWords

contracts/interfaces/draft-IERC1404/draft-IERC1404EnumCode.sol#L9-L14


 - [ ] ID-29
Constant [EnforcementModuleInternal.EnforcementModuleInternalStorageLocation](contracts/modules/internal/EnforcementModuleInternal.sol#L41) is not in UPPER_CASE_WITH_UNDERSCORES

contracts/modules/internal/EnforcementModuleInternal.sol#L41


 - [ ] ID-30
Function [CMTATFactoryRoot.CMTATProxyAddress(uint256)](contracts/deployment/libraries/CMTATFactoryRoot.sol#L48-L50) is not in mixedCase

contracts/deployment/libraries/CMTATFactoryRoot.sol#L48-L50


 - [ ] ID-31
Parameter [RuleEngineMock.detectTransferRestriction(address,address,uint256)._amount](contracts/mocks/RuleEngine/RuleEngineMock.sol#L42) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L42


 - [ ] ID-32
Constant [PauseModule.PauseModuleStorageLocation](contracts/modules/wrapper/core/PauseModule.sol#L28) is not in UPPER_CASE_WITH_UNDERSCORES

contracts/modules/wrapper/core/PauseModule.sol#L28


 - [ ] ID-33
Contract [CMTAT_UUPS_FACTORY](contracts/deployment/CMTAT_UUPS_FACTORY.sol#L15-L92) is not in CapWords

contracts/deployment/CMTAT_UUPS_FACTORY.sol#L15-L92


 - [ ] ID-34
Contract [CMTAT_PROXY](contracts/CMTAT_PROXY.sol#L10-L22) is not in CapWords

contracts/CMTAT_PROXY.sol#L10-L22


 - [ ] ID-35
Function [PauseModule.__PauseModule_init_unchained()](contracts/modules/wrapper/core/PauseModule.sol#L34-L36) is not in mixedCase

contracts/modules/wrapper/core/PauseModule.sol#L34-L36


 - [ ] ID-36
Function [BaseModule.__Base_init_unchained(string,string,string)](contracts/modules/wrapper/core/BaseModule.sol#L42-L51) is not in mixedCase

contracts/modules/wrapper/core/BaseModule.sol#L42-L51


 - [ ] ID-37
Function [EnforcementModuleInternal.__Enforcement_init_unchained()](contracts/modules/internal/EnforcementModuleInternal.sol#L53-L55) is not in mixedCase

contracts/modules/internal/EnforcementModuleInternal.sol#L53-L55


 - [ ] ID-38
Struct [CMTATFactoryInvariant.CMTAT_ARGUMENT](contracts/deployment/libraries/CMTATFactoryInvariant.sol#L13-L18) is not in CapWords

contracts/deployment/libraries/CMTATFactoryInvariant.sol#L13-L18


 - [ ] ID-39
Function [ERC20BurnModule.__ERC20BurnModule_init_unchained()](contracts/modules/wrapper/core/ERC20BurnModule.sol#L32-L34) is not in mixedCase

contracts/modules/wrapper/core/ERC20BurnModule.sol#L32-L34


 - [ ] ID-40
Function [ValidationModuleInternal.__Validation_init_unchained(IRuleEngine)](contracts/modules/internal/ValidationModuleInternal.sol#L30-L38) is not in mixedCase

contracts/modules/internal/ValidationModuleInternal.sol#L30-L38


 - [ ] ID-41
Constant [ValidationModuleInternal.ValidationModuleInternalStorageLocation](contracts/modules/internal/ValidationModuleInternal.sol#L24) is not in UPPER_CASE_WITH_UNDERSCORES

contracts/modules/internal/ValidationModuleInternal.sol#L24


 - [ ] ID-42
Contract [CMTAT_STANDALONE](contracts/CMTAT_STANDALONE.sol#L10-L36) is not in CapWords

contracts/CMTAT_STANDALONE.sol#L10-L36


 - [ ] ID-43
Parameter [RuleEngineMock.operateOnTransfer(address,address,uint256)._to](contracts/mocks/RuleEngine/RuleEngineMock.sol#L74) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L74


 - [ ] ID-44
Parameter [RuleEngineMock.validateTransfer(address,address,uint256)._amount](contracts/mocks/RuleEngine/RuleEngineMock.sol#L64) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L64


 - [ ] ID-45
Parameter [RuleEngineMock.operateOnTransfer(address,address,uint256)._from](contracts/mocks/RuleEngine/RuleEngineMock.sol#L73) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L73


 - [ ] ID-46
Parameter [RuleMock.validateTransfer(address,address,uint256)._to](contracts/mocks/RuleEngine/RuleMock.sol#L14) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L14


 - [ ] ID-47
Parameter [RuleEngineMock.operateOnTransfer(address,address,uint256)._amount](contracts/mocks/RuleEngine/RuleEngineMock.sol#L75) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L75


 - [ ] ID-48
Parameter [RuleMock.canReturnTransferRestrictionCode(uint8)._restrictionCode](contracts/mocks/RuleEngine/RuleMock.sol#L35) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L35


 - [ ] ID-49
Function [DebtModule.__DebtModule_init_unchained(IDebtEngine)](contracts/modules/wrapper/extensions/DebtModule.sol#L41-L50) is not in mixedCase

contracts/modules/wrapper/extensions/DebtModule.sol#L41-L50


 - [ ] ID-50
Parameter [RuleEngineMock.validateTransfer(address,address,uint256)._to](contracts/mocks/RuleEngine/RuleEngineMock.sol#L63) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L63


 - [ ] ID-51
Function [DocumentModule.__DocumentModule_init_unchained(IERC1643)](contracts/modules/wrapper/extensions/DocumentModule.sol#L41-L48) is not in mixedCase

contracts/modules/wrapper/extensions/DocumentModule.sol#L41-L48


 - [ ] ID-52
Parameter [DocumentModule.getDocument(bytes32)._name](contracts/modules/wrapper/extensions/DocumentModule.sol#L74) is not in mixedCase

contracts/modules/wrapper/extensions/DocumentModule.sol#L74


 - [ ] ID-53
Constant [SnapshotModuleBase.SnapshotModuleBaseStorageLocation](contracts/modules/internal/base/SnapshotModuleBase.sol#L45) is not in UPPER_CASE_WITH_UNDERSCORES

contracts/modules/internal/base/SnapshotModuleBase.sol#L45


 - [ ] ID-54
Function [AuthorizationModule.__AuthorizationModule_init_unchained(address,IAuthorizationEngine)](contracts/modules/security/AuthorizationModule.sol#L30-L41) is not in mixedCase

contracts/modules/security/AuthorizationModule.sol#L30-L41


 - [ ] ID-55
Function [CMTAT_BASE.__CMTAT_init(address,ICMTATConstructor.ERC20Attributes,ICMTATConstructor.BaseModuleAttributes,ICMTATConstructor.Engine)](contracts/modules/CMTAT_BASE.sol#L77-L129) is not in mixedCase

contracts/modules/CMTAT_BASE.sol#L77-L129


 - [ ] ID-56
Constant [ERC20BaseModule.ERC20BaseModuleStorageLocation](contracts/modules/wrapper/core/ERC20BaseModule.sol#L26) is not in UPPER_CASE_WITH_UNDERSCORES

contracts/modules/wrapper/core/ERC20BaseModule.sol#L26


 - [ ] ID-57
Parameter [RuleEngineMock.validateTransfer(address,address,uint256)._from](contracts/mocks/RuleEngine/RuleEngineMock.sol#L62) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L62


 - [ ] ID-58
Parameter [RuleMock.validateTransfer(address,address,uint256)._amount](contracts/mocks/RuleEngine/RuleMock.sol#L15) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L15


 - [ ] ID-59
Parameter [CMTAT_PROXY_UUPS.initialize(address,ICMTATConstructor.ERC20Attributes,ICMTATConstructor.BaseModuleAttributes,ICMTATConstructor.Engine).ERC20Attributes_](contracts/CMTAT_PROXY_UUPS.sol#L38) is not in mixedCase

contracts/CMTAT_PROXY_UUPS.sol#L38


 - [ ] ID-60
Parameter [CMTAT_BASE.initialize(address,ICMTATConstructor.ERC20Attributes,ICMTATConstructor.BaseModuleAttributes,ICMTATConstructor.Engine).ERC20Attributes_](contracts/modules/CMTAT_BASE.sol#L61) is not in mixedCase

contracts/modules/CMTAT_BASE.sol#L61


 - [ ] ID-61
Function [CMTAT_BASE.__CMTAT_init_unchained()](contracts/modules/CMTAT_BASE.sol#L131-L133) is not in mixedCase

contracts/modules/CMTAT_BASE.sol#L131-L133


 - [ ] ID-62
Constant [DocumentModule.DocumentModuleStorageLocation](contracts/modules/wrapper/extensions/DocumentModule.sol#L27) is not in UPPER_CASE_WITH_UNDERSCORES

contracts/modules/wrapper/extensions/DocumentModule.sol#L27


 - [ ] ID-63
Parameter [RuleMock.detectTransferRestriction(address,address,uint256)._amount](contracts/mocks/RuleEngine/RuleMock.sol#L26) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L26


 - [ ] ID-64
Function [ERC20BaseModule.__ERC20BaseModule_init_unchained(uint8)](contracts/modules/wrapper/core/ERC20BaseModule.sol#L39-L44) is not in mixedCase

contracts/modules/wrapper/core/ERC20BaseModule.sol#L39-L44


 - [ ] ID-65
Parameter [RuleMock.messageForTransferRestriction(uint8)._restrictionCode](contracts/mocks/RuleEngine/RuleMock.sol#L41) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L41


 - [ ] ID-66
Constant [AuthorizationModule.AuthorizationModuleStorageLocation](contracts/modules/security/AuthorizationModule.sol#L17) is not in UPPER_CASE_WITH_UNDERSCORES

contracts/modules/security/AuthorizationModule.sol#L17


 - [ ] ID-67
Function [ERC20MintModule.__ERC20MintModule_init_unchained()](contracts/modules/wrapper/core/ERC20MintModule.sol#L27-L29) is not in mixedCase

contracts/modules/wrapper/core/ERC20MintModule.sol#L27-L29


 - [ ] ID-68
Parameter [RuleEngineMock.detectTransferRestriction(address,address,uint256)._to](contracts/mocks/RuleEngine/RuleEngineMock.sol#L41) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L41


 - [ ] ID-69
Constant [BaseModule.BaseModuleStorageLocation](contracts/modules/wrapper/core/BaseModule.sol#L27) is not in UPPER_CASE_WITH_UNDERSCORES

contracts/modules/wrapper/core/BaseModule.sol#L27


 - [ ] ID-70
Function [SnapshotModuleBase.__SnapshotModuleBase_init_unchained()](contracts/modules/internal/base/SnapshotModuleBase.sol#L70-L73) is not in mixedCase

contracts/modules/internal/base/SnapshotModuleBase.sol#L70-L73


 - [ ] ID-71
Contract [CMTAT_BEACON_FACTORY](contracts/deployment/CMTAT_BEACON_FACTORY.sol#L16-L111) is not in CapWords

contracts/deployment/CMTAT_BEACON_FACTORY.sol#L16-L111


 - [ ] ID-72
Parameter [CMTAT_BASE.__CMTAT_init(address,ICMTATConstructor.ERC20Attributes,ICMTATConstructor.BaseModuleAttributes,ICMTATConstructor.Engine).ERC20Attributes_](contracts/modules/CMTAT_BASE.sol#L79) is not in mixedCase

contracts/modules/CMTAT_BASE.sol#L79


 - [ ] ID-73
Contract [CMTAT_BASE](contracts/modules/CMTAT_BASE.sol#L29-L240) is not in CapWords

contracts/modules/CMTAT_BASE.sol#L29-L240


 - [ ] ID-74
Parameter [RuleEngineMock.messageForTransferRestriction(uint8)._restrictionCode](contracts/mocks/RuleEngine/RuleEngineMock.sol#L84) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L84


 - [ ] ID-75
Function [ValidationModule.__ValidationModule_init_unchained()](contracts/modules/wrapper/controllers/ValidationModule.sol#L28-L30) is not in mixedCase

contracts/modules/wrapper/controllers/ValidationModule.sol#L28-L30


 - [ ] ID-76
Parameter [RuleEngineMock.detectTransferRestriction(address,address,uint256)._from](contracts/mocks/RuleEngine/RuleEngineMock.sol#L40) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L40


 - [ ] ID-77
Constant [DebtModule.DebtModuleStorageLocation](contracts/modules/wrapper/extensions/DebtModule.sol#L20) is not in UPPER_CASE_WITH_UNDERSCORES

contracts/modules/wrapper/extensions/DebtModule.sol#L20


 - [ ] ID-78
Function [ERC20SnapshotModule.__ERC20SnasphotModule_init_unchained()](contracts/modules/wrapper/extensions/ERC20SnapshotModule.sol#L22-L24) is not in mixedCase

contracts/modules/wrapper/extensions/ERC20SnapshotModule.sol#L22-L24


 - [ ] ID-79
Function [EnforcementModule.__EnforcementModule_init_unchained()](contracts/modules/wrapper/core/EnforcementModule.sol#L27-L29) is not in mixedCase

contracts/modules/wrapper/core/EnforcementModule.sol#L27-L29


 - [ ] ID-80
Function [ERC20SnapshotModuleInternal.__ERC20Snapshot_init_unchained()](contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L21-L24) is not in mixedCase

contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L21-L24


 - [ ] ID-81
Contract [CMTAT_TP_FACTORY](contracts/deployment/CMTAT_TP_FACTORY.sol#L14-L92) is not in CapWords

contracts/deployment/CMTAT_TP_FACTORY.sol#L14-L92


 - [ ] ID-82
Parameter [RuleMock.validateTransfer(address,address,uint256)._from](contracts/mocks/RuleEngine/RuleMock.sol#L13) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L13


## similar-names
Impact: Informational
Confidence: Medium
 - [ ] ID-83
Variable [IERC1643Whole.setDocument(bytes32,string,bytes32)._documentHash](contracts/mocks/DocumentEngineMock.sol#L8) is too similar to [DocumentEngineMock.setDocument(bytes32,string,bytes32).documentHash_](contracts/mocks/DocumentEngineMock.sol#L55)

contracts/mocks/DocumentEngineMock.sol#L8


 - [ ] ID-84
Variable [CMTAT_BEACON_FACTORY._getBytecode(CMTATFactoryInvariant.CMTAT_ARGUMENT)._implementation](contracts/deployment/CMTAT_BEACON_FACTORY.sol#L101-L107) is too similar to [CMTAT_BEACON_FACTORY.constructor(address,address,address,bool).implementation_](contracts/deployment/CMTAT_BEACON_FACTORY.sol#L24)

contracts/deployment/CMTAT_BEACON_FACTORY.sol#L101-L107


 - [ ] ID-85
Variable [DebtEngineMock._creditEvents](contracts/mocks/DebtEngineMock.sol#L15) is too similar to [DebtEngineMock.setCreditEvents(IDebtGlobal.CreditEvents).creditEvents_](contracts/mocks/DebtEngineMock.sol#L29)

contracts/mocks/DebtEngineMock.sol#L15


## too-many-digits
Impact: Informational
Confidence: Medium
 - [ ] ID-86
	[CMTAT_BEACON_FACTORY._getBytecode(CMTATFactoryInvariant.CMTAT_ARGUMENT)](contracts/deployment/CMTAT_BEACON_FACTORY.sol#L98-L109) uses literals with too many digits:
	- [bytecode = abi.encodePacked(type()(BeaconProxy).creationCode,abi.encode(address(beacon),_implementation))](contracts/deployment/CMTAT_BEACON_FACTORY.sol#L108)

contracts/deployment/CMTAT_BEACON_FACTORY.sol#L98-L109


 - [ ] ID-87
	[CMTAT_TP_FACTORY._getBytecode(address,CMTATFactoryInvariant.CMTAT_ARGUMENT)](contracts/deployment/CMTAT_TP_FACTORY.sol#L79-L90) uses literals with too many digits:
	- [bytecode = abi.encodePacked(type()(TransparentUpgradeableProxy).creationCode,abi.encode(logic,proxyAdminOwner,implementation))](contracts/deployment/CMTAT_TP_FACTORY.sol#L89)

contracts/deployment/CMTAT_TP_FACTORY.sol#L79-L90
