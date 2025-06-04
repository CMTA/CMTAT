const { expect } = require('chai')
const {
  deployCMTATDebtProxy,
  fixture,
  loadFixture

} = require('../../deploymentUtils')
const {
  ZERO_ADDRESS
} = require('../../utils')
// Core
const ERC20BaseModuleCommon = require('../../common/ERC20BaseModuleCommon')
const ERC20MintModuleCommon = require('../../common/ERC20MintModuleCommon')
const ERC20BurnModuleCommon = require('../../common/ERC20BurnModuleCommon')
const EnforcementModuleCommon = require('../../common/EnforcementModuleCommon')
const BaseModuleCommon = require('../../common/BaseModuleCommon')
const PauseModuleCommon = require('../../common/PauseModuleCommon')
const ValidationModuleCommonCore = require('../../common/ValidationModule/ValidationModuleCommonCore')
// Extensions
const ERC20EnforcementModuleCommon = require('../../common/ERC20EnforcementModuleCommon')
const DocumentModuleCommon = require('../../common/DocumentModule/DocumentModuleCommon')
const ExtraInfoModuleCommon = require('../../common/ExtraInfoModuleCommon')
// debt
const DebtModuleCommon = require('../../common/DebtModule/DebtModuleCommon')
const DebtModuleSetDebtEngineCommon = require('../../common/DebtModule/DebtModuleSetDebtEngineCommon')
const DebtEngineModuleCommon = require('../../common/DebtModule/DebtEngineModuleCommon')

describe('CMTAT Debt - Upgradeable', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATDebtProxy(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
    this.debtEngineMock = await ethers.deployContract('DebtEngineMock')
    this.core = true
    this.dontCheckTimestamp = true
  })
  ExtraInfoModuleCommon()
  BaseModuleCommon()
  PauseModuleCommon()
  ERC20BaseModuleCommon()
  ERC20BurnModuleCommon()
  ERC20MintModuleCommon()
  EnforcementModuleCommon()
  ValidationModuleCommonCore()

  // Extensions
  ERC20EnforcementModuleCommon
  DocumentModuleCommon()
  ExtraInfoModuleCommon()

  // options
  DebtModuleCommon()
  DebtEngineModuleCommon()
  DebtModuleSetDebtEngineCommon()
})
