const { expectEvent } = require('@openzeppelin/test-helpers')
const {
  expectRevertCustomError
} = require('../../../openzeppelin-contracts-upgradeable/test/helpers/customError.js')
const { DEFAULT_ADMIN_ROLE } = require('../../utils')
const { should } = require('chai').should()

function ValidationModuleSetRuleEngineCommon (admin, address1, ruleEngine) {
  context('RuleEngineSetTest', function () {
    it('testCanBeSetByAdmin', async function () {
      // Act
      this.logs = await this.cmtat.connect(this.admin).setRuleEngine(ruleEngine)
      // Assert
      // emits a RuleEngineSet event
      expectEvent(this.logs, 'RuleEngine', {
        newRuleEngine: ruleEngine
      })
    })

    it('testCanNotBeSetByAdminWithTheSameValue', async function () {
      // Act
      await expectRevertCustomError(
        this.cmtat.connect(this.admin).setRuleEngine(await this.cmtat.ruleEngine()),
        'CMTAT_ValidationModule_SameValue',
        []
      )
    })

    it('testCannotBeSetByNonAdmin', async function () {
      // Act
      await expectRevertCustomError(
        this.cmtat.connect(address1).setRuleEngine(ruleEngine),
        'AccessControlUnauthorizedAccount',
        [address1, DEFAULT_ADMIN_ROLE]
      )
    })

    it('testCanReturnMessageWithNoRuleEngine&UnknownRestrictionCode', async function () {
      // Act + Assert
      (await this.cmtat.messageForTransferRestriction(254)).should.equal(
        'Unknown code'
      )
    })

    it('testCanDetectTransferRestrictionValidTransferWithoutRuleEngine', async function () {
      // Act + Assert
      (
        await this.cmtat.detectTransferRestriction(address1, admin, 11)
      ).should.be.bignumber.equal('0')
    })
  })
}
module.exports = ValidationModuleSetRuleEngineCommon
