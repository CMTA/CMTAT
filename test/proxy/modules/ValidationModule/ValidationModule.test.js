const CMTAT = artifacts.require('CMTAT_PROXY')
const ValidationModuleCommon = require('../../../common/ValidationModule/ValidationModuleSetRuleEngineCommon')
const { deployCMTATProxy, fixture, loadFixture } = require('../../../deploymentUtils')
const ADDRESS1_INITIAL_BALANCE = 31
const ADDRESS2_INITIAL_BALANCE = 32
const ADDRESS3_INITIAL_BALANCE = 33

contract(
  'Proxy - ValidationModule',
  function () {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture));
      this.ruleEngineMock = await ethers.deployContract('RuleEngineMock')
      this.cmtat = await deployCMTATProxy(this._, this.admin, this.deployerAddress)
      await this.cmtat.mint(this.address1, ADDRESS1_INITIAL_BALANCE, {
        from: admin
      })
      await this.cmtat.mint(this.address2, ADDRESS2_INITIAL_BALANCE, {
        from: admin
      })
      await this.cmtat.mint(this.address3, ADDRESS3_INITIAL_BALANCE, {
        from: admin
      })
    })
    ValidationModuleCommon(
      admin,
      address1,
      address2,
      address3,
      ADDRESS1_INITIAL_BALANCE,
      ADDRESS2_INITIAL_BALANCE,
      ADDRESS3_INITIAL_BALANCE
    )
  }
)
