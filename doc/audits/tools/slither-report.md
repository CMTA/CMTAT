**THIS CHECKLIST IS NOT COMPLETE**. Use `--show-ignored-findings` to show all the results.
Summary
 - [shadowing-state](#shadowing-state) (1 results) (High)
 - [reentrancy-no-eth](#reentrancy-no-eth) (1 results) (Medium)
 - [uninitialized-local](#uninitialized-local) (1 results) (Medium)
 - [missing-zero-check](#missing-zero-check) (2 results) (Low)
 - [calls-loop](#calls-loop) (4 results) (Low)
 - [reentrancy-benign](#reentrancy-benign) (3 results) (Low)
 - [reentrancy-events](#reentrancy-events) (2 results) (Low)
 - [timestamp](#timestamp) (6 results) (Low)
 - [costly-loop](#costly-loop) (2 results) (Informational)
 - [dead-code](#dead-code) (1 results) (Informational)
 - [solc-version](#solc-version) (1 results) (Informational)
 - [naming-convention](#naming-convention) (57 results) (Informational)
## shadowing-state
Impact: High
Confidence: High
 - [ ] ID-0
	[ERC20SnapshotModuleInternal._scheduledSnapshots](contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L25) shadows:
	- [SnapshotModuleBase._scheduledSnapshots](contracts/modules/internal/base/SnapshotModuleBase.sol#L62)

contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L25


## reentrancy-no-eth
Impact: Medium
Confidence: Medium
 - [ ] ID-1
	Reentrancy in [CMTAT_BASE.burnAndMint(address,address,uint256,uint256,string)](contracts/modules/CMTAT_BASE.sol#L189-L192):
	External calls:
	- [burn(from,amountToBurn,reason)](contracts/modules/CMTAT_BASE.sol#L190)
		- [ruleEngine.operateOnTransfer(from,to,amount)](contracts/modules/internal/ValidationModuleInternal.sol#L65)
	- [mint(to,amountToMint)](contracts/modules/CMTAT_BASE.sol#L191)
		- [ruleEngine.operateOnTransfer(from,to,amount)](contracts/modules/internal/ValidationModuleInternal.sol#L65)
		State variables written after the call(s):
	- [mint(to,amountToMint)](contracts/modules/CMTAT_BASE.sol#L191)
		- [_currentSnapshotIndex = scheduleSnapshotIndex](contracts/modules/internal/base/SnapshotModuleBase.sol#L328)
		[SnapshotModuleBase._currentSnapshotIndex](contracts/modules/internal/base/SnapshotModuleBase.sol#L55) can be used in cross function reentrancies:
	- [SnapshotModuleBase._findScheduledMostRecentPastSnapshot()](contracts/modules/internal/base/SnapshotModuleBase.sol#L375-L402)
	- [SnapshotModuleBase._setCurrentSnapshot()](contracts/modules/internal/base/SnapshotModuleBase.sol#L321-L330)
	- [mint(to,amountToMint)](contracts/modules/CMTAT_BASE.sol#L191)
		- [_currentSnapshotTime = scheduleSnapshotTime](contracts/modules/internal/base/SnapshotModuleBase.sol#L327)
		[SnapshotModuleBase._currentSnapshotTime](contracts/modules/internal/base/SnapshotModuleBase.sol#L53) can be used in cross function reentrancies:
	- [SnapshotModuleBase._setCurrentSnapshot()](contracts/modules/internal/base/SnapshotModuleBase.sol#L321-L330)
	- [SnapshotModuleBase._updateSnapshot(SnapshotModuleBase.Snapshots,uint256)](contracts/modules/internal/base/SnapshotModuleBase.sol#L305-L314)
	- [SnapshotModuleBase.getNextSnapshots()](contracts/modules/internal/base/SnapshotModuleBase.sol#L82-L111)

contracts/modules/CMTAT_BASE.sol#L189-L192

## uninitialized-local

> The concerned variable local `mostRecent` is initialized in the loop

Impact: Medium
Confidence: Medium

 - [ ] ID-2
[SnapshotModuleBase._findScheduledMostRecentPastSnapshot().mostRecent](contracts/modules/internal/base/SnapshotModuleBase.sol#L389) is a local variable never initialized

contracts/modules/internal/base/SnapshotModuleBase.sol#L389

## missing-zero-check

> Mock: not intended to be used in production

Impact: Low
Confidence: Medium


 - [ ] ID-4
	[AuthorizationEngineMock.authorizeAdminChange(address).newAdmin](contracts/mocks/AuthorizationEngineMock.sol#L21) lacks a zero-check on :
		- [nextAdmin = newAdmin](contracts/mocks/AuthorizationEngineMock.sol#L22)

contracts/mocks/AuthorizationEngineMock.sol#L21

## calls-loop

>Mock: not intended to be used in production
>ValidationModuleInternal: the loop happens only for batch function. A relevant alternative could be the creation of a batch function for the RuleEngine, but for the moment we don't have an implemented solution.

Impact: Low
Confidence: Medium

 - [ ] ID-5
[RuleEngineMock.messageForTransferRestriction(uint8)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L83-L97) has external calls inside a loop: [_rules[i].canReturnTransferRestrictionCode(_restrictionCode)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L88)

contracts/mocks/RuleEngine/RuleEngineMock.sol#L83-L97


 - [ ] ID-6
[RuleEngineMock.messageForTransferRestriction(uint8)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L83-L97) has external calls inside a loop: [_rules[i].messageForTransferRestriction(_restrictionCode)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L89-L90)

contracts/mocks/RuleEngine/RuleEngineMock.sol#L83-L97


 - [ ] ID-7
[ValidationModuleInternal._operateOnTransfer(address,address,uint256)](contracts/modules/internal/ValidationModuleInternal.sol#L64-L66) has external calls inside a loop: [ruleEngine.operateOnTransfer(from,to,amount)](contracts/modules/internal/ValidationModuleInternal.sol#L65)

contracts/modules/internal/ValidationModuleInternal.sol#L64-L66


 - [ ] ID-8
[RuleEngineMock.detectTransferRestriction(address,address,uint256)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L39-L59) has external calls inside a loop: [restriction = _rules[i].detectTransferRestriction(_from,_to,_amount)](contracts/mocks/RuleEngine/RuleEngineMock.sol#L46-L50)

contracts/mocks/RuleEngine/RuleEngineMock.sol#L39-L59

## reentrancy-benign

> Factory contract : It is not a security issue since only authorized user can call the function
> CMTAT_BASE._update: the contract called is a trusted contract (RuleEngine)



Impact: Low
Confidence: Medium
 - [ ] ID-9
	Reentrancy in [CMTAT_BEACON_FACTORY.deployCMTAT(address,IAuthorizationEngine,string,string,uint8,string,string,IRuleEngine,string,uint256)](contracts/deployment/CMTAT_BEACON_FACTORY.sol#L41-L75):
	External calls:
	- [cmtat = new BeaconProxy(address(beacon),abi.encodeWithSelector(CMTAT_PROXY(address(0)).initialize.selector,admin,authorizationEngineIrrevocable,nameIrrevocable,symbolIrrevocable,decimalsIrrevocable,tokenId_,terms_,ruleEngine_,information_,flag_))](contracts/deployment/CMTAT_BEACON_FACTORY.sol#L54-L69)
	State variables written after the call(s):
	- [cmtatCounterId ++](contracts/deployment/CMTAT_BEACON_FACTORY.sol#L72)
	- [cmtats[cmtatCounterId] = address(cmtat)](contracts/deployment/CMTAT_BEACON_FACTORY.sol#L70)
	- [cmtatsList.push(address(cmtat))](contracts/deployment/CMTAT_BEACON_FACTORY.sol#L73)

contracts/deployment/CMTAT_BEACON_FACTORY.sol#L41-L75


 - [ ] ID-10
	Reentrancy in [CMTAT_TP_FACTORY.deployCMTAT(address,address,IAuthorizationEngine,string,string,uint8,string,string,IRuleEngine,string,uint256)](contracts/deployment/CMTAT_TP_FACTORY.sol#L32-L68):
	External calls:
	- [cmtat = new TransparentUpgradeableProxy(logic,proxyAdminOwner,abi.encodeWithSelector(CMTAT_PROXY(address(0)).initialize.selector,admin,authorizationEngineIrrevocable,nameIrrevocable,symbolIrrevocable,decimalsIrrevocable,tokenId_,terms_,ruleEngine_,information_,flag_))](contracts/deployment/CMTAT_TP_FACTORY.sol#L46-L62)
	State variables written after the call(s):
	- [cmtatID ++](contracts/deployment/CMTAT_TP_FACTORY.sol#L65)
	- [cmtats[cmtatID] = address(cmtat)](contracts/deployment/CMTAT_TP_FACTORY.sol#L63)
	- [cmtatsList.push(address(cmtat))](contracts/deployment/CMTAT_TP_FACTORY.sol#L66)

contracts/deployment/CMTAT_TP_FACTORY.sol#L32-L68


 - [ ] ID-11
	Reentrancy in [CMTAT_BASE._update(address,address,uint256)](contracts/modules/CMTAT_BASE.sol#L198-L213):
	External calls:
	- [! ValidationModule._operateOnTransfer(from,to,amount)](contracts/modules/CMTAT_BASE.sol#L203)
		- [ruleEngine.operateOnTransfer(from,to,amount)](contracts/modules/internal/ValidationModuleInternal.sol#L65)
		State variables written after the call(s):
	- [ERC20SnapshotModuleInternal._snapshotUpdate(from,to)](contracts/modules/CMTAT_BASE.sol#L211)
		- [_currentSnapshotIndex = scheduleSnapshotIndex](contracts/modules/internal/base/SnapshotModuleBase.sol#L328)
	- [ERC20SnapshotModuleInternal._snapshotUpdate(from,to)](contracts/modules/CMTAT_BASE.sol#L211)
		- [_currentSnapshotTime = scheduleSnapshotTime](contracts/modules/internal/base/SnapshotModuleBase.sol#L327)

contracts/modules/CMTAT_BASE.sol#L198-L213

## reentrancy-events

> It is not a security issue since only authorized user can call the function

Impact: Low
Confidence: Medium
 - [ ] ID-12
	Reentrancy in [CMTAT_TP_FACTORY.deployCMTAT(address,address,IAuthorizationEngine,string,string,uint8,string,string,IRuleEngine,string,uint256)](contracts/deployment/CMTAT_TP_FACTORY.sol#L32-L68):
	External calls:
	- [cmtat = new TransparentUpgradeableProxy(logic,proxyAdminOwner,abi.encodeWithSelector(CMTAT_PROXY(address(0)).initialize.selector,admin,authorizationEngineIrrevocable,nameIrrevocable,symbolIrrevocable,decimalsIrrevocable,tokenId_,terms_,ruleEngine_,information_,flag_))](contracts/deployment/CMTAT_TP_FACTORY.sol#L46-L62)
	Event emitted after the call(s):
	- [CMTAT(address(cmtat),cmtatID)](contracts/deployment/CMTAT_TP_FACTORY.sol#L64)

contracts/deployment/CMTAT_TP_FACTORY.sol#L32-L68


 - [ ] ID-13
	Reentrancy in [CMTAT_BEACON_FACTORY.deployCMTAT(address,IAuthorizationEngine,string,string,uint8,string,string,IRuleEngine,string,uint256)](contracts/deployment/CMTAT_BEACON_FACTORY.sol#L41-L75):
	External calls:
	- [cmtat = new BeaconProxy(address(beacon),abi.encodeWithSelector(CMTAT_PROXY(address(0)).initialize.selector,admin,authorizationEngineIrrevocable,nameIrrevocable,symbolIrrevocable,decimalsIrrevocable,tokenId_,terms_,ruleEngine_,information_,flag_))](contracts/deployment/CMTAT_BEACON_FACTORY.sol#L54-L69)
	Event emitted after the call(s):
	- [CMTAT(address(cmtat),cmtatCounterId)](contracts/deployment/CMTAT_BEACON_FACTORY.sol#L71)

contracts/deployment/CMTAT_BEACON_FACTORY.sol#L41-L75

## timestamp

> With the Proof of Work, it was possible for a miner to modify the timestamp in a range of about 15 seconds
>
> With the Proof Of Stake, a new block is created every 12 seconds
>
> In all cases, we are not looking for such precision

Impact: Low
Confidence: Medium
 - [ ] ID-14
	[SnapshotModuleBase._scheduleSnapshotNotOptimized(uint256)](contracts/modules/internal/base/SnapshotModuleBase.sol#L149-L177) uses timestamp for comparisons
	Dangerous comparisons:
	- [time <= block.timestamp](contracts/modules/internal/base/SnapshotModuleBase.sol#L150)

contracts/modules/internal/base/SnapshotModuleBase.sol#L149-L177


 - [ ] ID-15
	[SnapshotModuleBase._rescheduleSnapshot(uint256,uint256)](contracts/modules/internal/base/SnapshotModuleBase.sol#L182-L223) uses timestamp for comparisons
	Dangerous comparisons:
	- [oldTime <= block.timestamp](contracts/modules/internal/base/SnapshotModuleBase.sol#L184)
	- [newTime <= block.timestamp](contracts/modules/internal/base/SnapshotModuleBase.sol#L187)

contracts/modules/internal/base/SnapshotModuleBase.sol#L182-L223


 - [ ] ID-16
	[SnapshotModuleBase._unscheduleSnapshotNotOptimized(uint256)](contracts/modules/internal/base/SnapshotModuleBase.sol#L250-L263) uses timestamp for comparisons
	Dangerous comparisons:
	- [time <= block.timestamp](contracts/modules/internal/base/SnapshotModuleBase.sol#L251)

contracts/modules/internal/base/SnapshotModuleBase.sol#L250-L263


 - [ ] ID-17
	[SnapshotModuleBase._scheduleSnapshot(uint256)](contracts/modules/internal/base/SnapshotModuleBase.sol#L118-L144) uses timestamp for comparisons
	Dangerous comparisons:
	- [time <= block.timestamp](contracts/modules/internal/base/SnapshotModuleBase.sol#L120)

contracts/modules/internal/base/SnapshotModuleBase.sol#L118-L144


 - [ ] ID-18
	[SnapshotModuleBase._unscheduleLastSnapshot(uint256)](contracts/modules/internal/base/SnapshotModuleBase.sol#L228-L242) uses timestamp for comparisons
	Dangerous comparisons:
	- [time <= block.timestamp](contracts/modules/internal/base/SnapshotModuleBase.sol#L230)

contracts/modules/internal/base/SnapshotModuleBase.sol#L228-L242


 - [ ] ID-19
	[SnapshotModuleBase._findScheduledMostRecentPastSnapshot()](contracts/modules/internal/base/SnapshotModuleBase.sol#L375-L402) uses timestamp for comparisons
	Dangerous comparisons:
	- [_scheduledSnapshots[i] <= block.timestamp](contracts/modules/internal/base/SnapshotModuleBase.sol#L393)

contracts/modules/internal/base/SnapshotModuleBase.sol#L375-L402

## costly-loop

> Inside the function, these two operations are not performed inside a loop.
>
> It seems that the only loops which calls`setCurrentSnapshot`are inside the batch functions(mintBatch, burnBatch, ...) through a call to the function update.
> At the moment, there is no trivial solution to resolve this.

Impact: Informational
Confidence: Medium
 - [ ] ID-20
	[SnapshotModuleBase._setCurrentSnapshot()](contracts/modules/internal/base/SnapshotModuleBase.sol#L321-L330) has costly operations inside a loop:
	- [_currentSnapshotTime = scheduleSnapshotTime](contracts/modules/internal/base/SnapshotModuleBase.sol#L327)

contracts/modules/internal/base/SnapshotModuleBase.sol#L321-L330


 - [ ] ID-21
	[SnapshotModuleBase._setCurrentSnapshot()](contracts/modules/internal/base/SnapshotModuleBase.sol#L321-L330) has costly operations inside a loop:
	- [_currentSnapshotIndex = scheduleSnapshotIndex](contracts/modules/internal/base/SnapshotModuleBase.sol#L328)

contracts/modules/internal/base/SnapshotModuleBase.sol#L321-L330

## dead-code

> - Implemented to be gasless compatible (see MetaTxModule)
>
> - If we remove this function, we will have the following error:
>
>   "Derived contract must override function "_msgData". Two or more base classes define function with same name and parameter types."

Impact: Informational
Confidence: Medium

 - [ ] ID-22
[CMTAT_BASE._msgData()](contracts/modules/CMTAT_BASE.sol#L240-L247) is never used and should be removed

contracts/modules/CMTAT_BASE.sol#L240-L247

## solc-version

> The version set in the config file is 0.8.22

Impact: Informational
Confidence: High
 - [ ] ID-23
	Version constraint ^0.8.20 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- VerbatimInvalidDeduplication
	- FullInlinerNonExpressionSplitArgumentEvaluationOrder
	- MissingSideEffectsOnSelectorAccess.
	 It is used by:
	- node_modules/@openzeppelin/contracts/access/AccessControl.sol#4
	- node_modules/@openzeppelin/contracts/access/IAccessControl.sol#4
	- node_modules/@openzeppelin/contracts/access/Ownable.sol#4
	- node_modules/@openzeppelin/contracts/interfaces/IERC1967.sol#4
	- node_modules/@openzeppelin/contracts/interfaces/IERC5267.sol#4
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
	- node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#5
	- node_modules/@openzeppelin/contracts/utils/Strings.sol#4
	- node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol#4
	- node_modules/@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol#4
	- node_modules/@openzeppelin/contracts/utils/introspection/ERC165.sol#4
	- node_modules/@openzeppelin/contracts/utils/introspection/IERC165.sol#4
	- node_modules/@openzeppelin/contracts/utils/math/Math.sol#4
	- node_modules/@openzeppelin/contracts/utils/math/SignedMath.sol#4
	- contracts/CMTAT_PROXY.sol#3
	- contracts/CMTAT_STANDALONE.sol#3
	- contracts/deployment/CMTAT_BEACON_FACTORY.sol#2
	- contracts/deployment/CMTAT_TP_FACTORY.sol#2
	- contracts/interfaces/ICCIPToken.sol#3
	- contracts/interfaces/ICMTATSnapshot.sol#3
	- contracts/interfaces/IDebtGlobal.sol#3
	- contracts/interfaces/draft-IERC1404/draft-IERC1404.sol#3
	- contracts/interfaces/draft-IERC1404/draft-IERC1404EnumCode.sol#3
	- contracts/interfaces/draft-IERC1404/draft-IERC1404Wrapper.sol#3
	- contracts/interfaces/engine/IAuthorizationEngine.sol#3
	- contracts/interfaces/engine/IRuleEngine.sol#3
	- contracts/libraries/Errors.sol#3
	- contracts/mocks/AuthorizationEngineMock.sol#3
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
	- contracts/modules/wrapper/extensions/DebtModule/CreditEventsModule.sol#3
	- contracts/modules/wrapper/extensions/DebtModule/DebtBaseModule.sol#3
	- contracts/modules/wrapper/extensions/ERC20SnapshotModule.sol#3
	- contracts/modules/wrapper/extensions/MetaTxModule.sol#3
	- contracts/test/proxy/CMTAT_PROXY.sol#3
	- openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol#4
	- openzeppelin-contracts-upgradeable/contracts/metatx/ERC2771ContextUpgradeable.sol#4
	- openzeppelin-contracts-upgradeable/contracts/metatx/ERC2771ForwarderUpgradeable.sol#4
	- openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol#4
	- openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol#4
	- openzeppelin-contracts-upgradeable/contracts/utils/ContextUpgradeable.sol#4
	- openzeppelin-contracts-upgradeable/contracts/utils/NoncesUpgradeable.sol#3
	- openzeppelin-contracts-upgradeable/contracts/utils/PausableUpgradeable.sol#4
	- openzeppelin-contracts-upgradeable/contracts/utils/cryptography/EIP712Upgradeable.sol#4
	- openzeppelin-contracts-upgradeable/contracts/utils/introspection/ERC165Upgradeable.sol#4

## naming-convention

> It is not really necessary to rename all the variables. It will generate a lot of work for a minor improvement.

Impact: Informational
Confidence: High

 - [ ] ID-24
Enum [IERC1404EnumCode.REJECTED_CODE_BASE](contracts/interfaces/draft-IERC1404/draft-IERC1404EnumCode.sol#L9-L14) is not in CapWords

contracts/interfaces/draft-IERC1404/draft-IERC1404EnumCode.sol#L9-L14


 - [ ] ID-25
Variable [CreditEventsModule.__gap](contracts/modules/wrapper/extensions/DebtModule/CreditEventsModule.sol#L83) is not in mixedCase

contracts/modules/wrapper/extensions/DebtModule/CreditEventsModule.sol#L83


 - [ ] ID-26
Parameter [RuleEngineMock.detectTransferRestriction(address,address,uint256)._amount](contracts/mocks/RuleEngine/RuleEngineMock.sol#L42) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L42


 - [ ] ID-27
Contract [CMTAT_PROXY](contracts/CMTAT_PROXY.sol#L7-L21) is not in CapWords

contracts/CMTAT_PROXY.sol#L7-L21


 - [ ] ID-28
Function [PauseModule.__PauseModule_init_unchained()](contracts/modules/wrapper/core/PauseModule.sol#L26-L28) is not in mixedCase

contracts/modules/wrapper/core/PauseModule.sol#L26-L28


 - [ ] ID-29
Function [CreditEventsModule.__CreditEvents_init_unchained()](contracts/modules/wrapper/extensions/DebtModule/CreditEventsModule.sol#L28-L30) is not in mixedCase

contracts/modules/wrapper/extensions/DebtModule/CreditEventsModule.sol#L28-L30


 - [ ] ID-30
Variable [CMTAT_BASE.__gap](contracts/modules/CMTAT_BASE.sol#L249) is not in mixedCase

contracts/modules/CMTAT_BASE.sol#L249


 - [ ] ID-31
Function [EnforcementModuleInternal.__Enforcement_init_unchained()](contracts/modules/internal/EnforcementModuleInternal.sol#L40-L42) is not in mixedCase

contracts/modules/internal/EnforcementModuleInternal.sol#L40-L42


 - [ ] ID-32
Variable [ValidationModuleInternal.__gap](contracts/modules/internal/ValidationModuleInternal.sol#L68) is not in mixedCase

contracts/modules/internal/ValidationModuleInternal.sol#L68


 - [ ] ID-33
Function [ERC20BurnModule.__ERC20BurnModule_init_unchained()](contracts/modules/wrapper/core/ERC20BurnModule.sol#L19-L21) is not in mixedCase

contracts/modules/wrapper/core/ERC20BurnModule.sol#L19-L21


 - [ ] ID-34
Function [ValidationModuleInternal.__Validation_init_unchained(IRuleEngine)](contracts/modules/internal/ValidationModuleInternal.sol#L24-L31) is not in mixedCase

contracts/modules/internal/ValidationModuleInternal.sol#L24-L31


 - [ ] ID-35
Variable [BaseModule.__gap](contracts/modules/wrapper/core/BaseModule.sol#L94) is not in mixedCase

contracts/modules/wrapper/core/BaseModule.sol#L94


 - [ ] ID-36
Variable [ValidationModule.__gap](contracts/modules/wrapper/controllers/ValidationModule.sol#L136) is not in mixedCase

contracts/modules/wrapper/controllers/ValidationModule.sol#L136


 - [ ] ID-37
Variable [EnforcementModule.__gap](contracts/modules/wrapper/core/EnforcementModule.sol#L55) is not in mixedCase

contracts/modules/wrapper/core/EnforcementModule.sol#L55


 - [ ] ID-38
Contract [CMTAT_STANDALONE](contracts/CMTAT_STANDALONE.sol#L7-L53) is not in CapWords

contracts/CMTAT_STANDALONE.sol#L7-L53


 - [ ] ID-39
Variable [DebtBaseModule.__gap](contracts/modules/wrapper/extensions/DebtModule/DebtBaseModule.sol#L232) is not in mixedCase

contracts/modules/wrapper/extensions/DebtModule/DebtBaseModule.sol#L232


 - [ ] ID-40
Variable [AuthorizationModule.__gap](contracts/modules/security/AuthorizationModule.sol#L85) is not in mixedCase

contracts/modules/security/AuthorizationModule.sol#L85


 - [ ] ID-41
Parameter [RuleEngineMock.operateOnTransfer(address,address,uint256)._to](contracts/mocks/RuleEngine/RuleEngineMock.sol#L74) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L74


 - [ ] ID-42
Parameter [RuleEngineMock.validateTransfer(address,address,uint256)._amount](contracts/mocks/RuleEngine/RuleEngineMock.sol#L64) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L64


 - [ ] ID-43
Parameter [RuleEngineMock.operateOnTransfer(address,address,uint256)._from](contracts/mocks/RuleEngine/RuleEngineMock.sol#L73) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L73


 - [ ] ID-44
Parameter [RuleMock.validateTransfer(address,address,uint256)._to](contracts/mocks/RuleEngine/RuleMock.sol#L14) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L14


 - [ ] ID-45
Parameter [RuleEngineMock.operateOnTransfer(address,address,uint256)._amount](contracts/mocks/RuleEngine/RuleEngineMock.sol#L75) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L75


 - [ ] ID-46
Variable [EnforcementModuleInternal.__gap](contracts/modules/internal/EnforcementModuleInternal.sol#L87) is not in mixedCase

contracts/modules/internal/EnforcementModuleInternal.sol#L87


 - [ ] ID-47
Parameter [RuleMock.canReturnTransferRestrictionCode(uint8)._restrictionCode](contracts/mocks/RuleEngine/RuleMock.sol#L35) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L35


 - [ ] ID-48
Variable [SnapshotModuleBase.__gap](contracts/modules/internal/base/SnapshotModuleBase.sol#L404) is not in mixedCase

contracts/modules/internal/base/SnapshotModuleBase.sol#L404


 - [ ] ID-49
Parameter [RuleEngineMock.validateTransfer(address,address,uint256)._to](contracts/mocks/RuleEngine/RuleEngineMock.sol#L63) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L63


 - [ ] ID-50
Function [BaseModule.__Base_init_unchained(string,string,string,uint256)](contracts/modules/wrapper/core/BaseModule.sol#L40-L50) is not in mixedCase

contracts/modules/wrapper/core/BaseModule.sol#L40-L50


 - [ ] ID-51
Function [AuthorizationModule.__AuthorizationModule_init_unchained(address,IAuthorizationEngine)](contracts/modules/security/AuthorizationModule.sol#L22-L33) is not in mixedCase

contracts/modules/security/AuthorizationModule.sol#L22-L33


 - [ ] ID-52
Parameter [RuleEngineMock.validateTransfer(address,address,uint256)._from](contracts/mocks/RuleEngine/RuleEngineMock.sol#L62) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L62


 - [ ] ID-53
Parameter [RuleMock.validateTransfer(address,address,uint256)._amount](contracts/mocks/RuleEngine/RuleMock.sol#L15) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L15


 - [ ] ID-54
Variable [PauseModule.__gap](contracts/modules/wrapper/core/PauseModule.sol#L83) is not in mixedCase

contracts/modules/wrapper/core/PauseModule.sol#L83


 - [ ] ID-55
Function [CMTAT_BASE.__CMTAT_init_unchained()](contracts/modules/CMTAT_BASE.sol#L148-L150) is not in mixedCase

contracts/modules/CMTAT_BASE.sol#L148-L150


 - [ ] ID-56
Variable [ERC20SnapshotModule.__gap](contracts/modules/wrapper/extensions/ERC20SnapshotModule.sol#L77) is not in mixedCase

contracts/modules/wrapper/extensions/ERC20SnapshotModule.sol#L77


 - [ ] ID-57
Parameter [RuleMock.detectTransferRestriction(address,address,uint256)._amount](contracts/mocks/RuleEngine/RuleMock.sol#L26) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L26


 - [ ] ID-58
Function [ERC20BaseModule.__ERC20BaseModule_init_unchained(uint8)](contracts/modules/wrapper/core/ERC20BaseModule.sol#L28-L32) is not in mixedCase

contracts/modules/wrapper/core/ERC20BaseModule.sol#L28-L32


 - [ ] ID-59
Parameter [RuleMock.messageForTransferRestriction(uint8)._restrictionCode](contracts/mocks/RuleEngine/RuleMock.sol#L41) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L41


 - [ ] ID-60
Function [CMTAT_BASE.__CMTAT_init(address,IAuthorizationEngine,string,string,uint8,string,string,IRuleEngine,string,uint256)](contracts/modules/CMTAT_BASE.sol#L87-L146) is not in mixedCase

contracts/modules/CMTAT_BASE.sol#L87-L146


 - [ ] ID-61
Function [ERC20MintModule.__ERC20MintModule_init_unchained()](contracts/modules/wrapper/core/ERC20MintModule.sol#L17-L19) is not in mixedCase

contracts/modules/wrapper/core/ERC20MintModule.sol#L17-L19


 - [ ] ID-62
Parameter [RuleEngineMock.detectTransferRestriction(address,address,uint256)._to](contracts/mocks/RuleEngine/RuleEngineMock.sol#L41) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L41


 - [ ] ID-63
Variable [MetaTxModule.__gap](contracts/modules/wrapper/extensions/MetaTxModule.sol#L22) is not in mixedCase

contracts/modules/wrapper/extensions/MetaTxModule.sol#L22


 - [ ] ID-64
Function [SnapshotModuleBase.__SnapshotModuleBase_init_unchained()](contracts/modules/internal/base/SnapshotModuleBase.sol#L64-L67) is not in mixedCase

contracts/modules/internal/base/SnapshotModuleBase.sol#L64-L67


 - [ ] ID-65
Variable [ERC20BurnModule.__gap](contracts/modules/wrapper/core/ERC20BurnModule.sol#L113) is not in mixedCase

contracts/modules/wrapper/core/ERC20BurnModule.sol#L113


 - [ ] ID-66
Variable [ERC20BaseModule.__gap](contracts/modules/wrapper/core/ERC20BaseModule.sol#L113) is not in mixedCase

contracts/modules/wrapper/core/ERC20BaseModule.sol#L113


 - [ ] ID-67
Contract [CMTAT_BEACON_FACTORY](contracts/deployment/CMTAT_BEACON_FACTORY.sol#L15-L93) is not in CapWords

contracts/deployment/CMTAT_BEACON_FACTORY.sol#L15-L93


 - [ ] ID-68
Contract [CMTAT_BASE](contracts/modules/CMTAT_BASE.sol#L29-L250) is not in CapWords

contracts/modules/CMTAT_BASE.sol#L29-L250


 - [ ] ID-69
Parameter [RuleEngineMock.messageForTransferRestriction(uint8)._restrictionCode](contracts/mocks/RuleEngine/RuleEngineMock.sol#L84) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L84


 - [ ] ID-70
Variable [ERC20MintModule.__gap](contracts/modules/wrapper/core/ERC20MintModule.sol#L73) is not in mixedCase

contracts/modules/wrapper/core/ERC20MintModule.sol#L73


 - [ ] ID-71
Function [ValidationModule.__ValidationModule_init_unchained()](contracts/modules/wrapper/controllers/ValidationModule.sol#L26-L28) is not in mixedCase

contracts/modules/wrapper/controllers/ValidationModule.sol#L26-L28


 - [ ] ID-72
Function [DebtBaseModule.__DebtBaseModule_init_unchained()](contracts/modules/wrapper/extensions/DebtModule/DebtBaseModule.sol#L60-L62) is not in mixedCase

contracts/modules/wrapper/extensions/DebtModule/DebtBaseModule.sol#L60-L62


 - [ ] ID-73
Parameter [RuleEngineMock.detectTransferRestriction(address,address,uint256)._from](contracts/mocks/RuleEngine/RuleEngineMock.sol#L40) is not in mixedCase

contracts/mocks/RuleEngine/RuleEngineMock.sol#L40


 - [ ] ID-74
Function [ERC20SnapshotModule.__ERC20SnasphotModule_init_unchained()](contracts/modules/wrapper/extensions/ERC20SnapshotModule.sol#L20-L22) is not in mixedCase

contracts/modules/wrapper/extensions/ERC20SnapshotModule.sol#L20-L22


 - [ ] ID-75
Variable [ERC20SnapshotModuleInternal.__gap](contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L140) is not in mixedCase

contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L140


 - [ ] ID-76
Function [EnforcementModule.__EnforcementModule_init_unchained()](contracts/modules/wrapper/core/EnforcementModule.sol#L25-L27) is not in mixedCase

contracts/modules/wrapper/core/EnforcementModule.sol#L25-L27


 - [ ] ID-77
Function [ERC20SnapshotModuleInternal.__ERC20Snapshot_init_unchained()](contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L27-L30) is not in mixedCase

contracts/modules/internal/ERC20SnapshotModuleInternal.sol#L27-L30


 - [ ] ID-78
Contract [CMTAT_TP_FACTORY](contracts/deployment/CMTAT_TP_FACTORY.sol#L11-L78) is not in CapWords

contracts/deployment/CMTAT_TP_FACTORY.sol#L11-L78


 - [ ] ID-79
Parameter [RuleMock.validateTransfer(address,address,uint256)._from](contracts/mocks/RuleEngine/RuleMock.sol#L13) is not in mixedCase

contracts/mocks/RuleEngine/RuleMock.sol#L13


 - [ ] ID-80
Variable [CMTAT_PROXY.__gap](contracts/CMTAT_PROXY.sol#L20) is not in mixedCase

contracts/CMTAT_PROXY.sol#L20

