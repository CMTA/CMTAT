const { expectEvent } = require('@openzeppelin/test-helpers')
const { expectRevertCustomError } = require('../../../openzeppelin-contracts-upgradeable/test/helpers/customError.js')
const { DEFAULT_ADMIN_ROLE } = require('../../utils')
const { should } = require('chai').should()

function ValidationModuleSetRuleEngineCommon (admin, address1, ruleEngine) {
  context('RuleEngineSetTest', function () {
    it('testCanBeSetByAdmin', async function () {
      // Act
      this.logs = await this.cmtat.setRuleEngine(ruleEngine, {
        from: admin
      })
      // Assert
      // emits a RuleEngineSet event
     expectEvent(this.logs, 'RuleEngine', {
        newRuleEngine: ruleEngine
      })
    })

    it('testCanNotBeSetByAdminWithTheSameValue', async function () {
      // Act
      await expectRevertCustomError(
        this.cmtat.setRuleEngine(await this.cmtat.ruleEngine(), { from: admin }),
        'CMTAT_ValidationModule_SameValue',
        []
      )
    })

    it('testCannotBeSetByNonAdmin', async function () {
      // Act
      await expectRevertCustomError(
        this.cmtat.setRuleEngine(ruleEngine, { from: address1 }),
        'AccessControlUnauthorizedAccount',
        [address1, DEFAULT_ADMIN_ROLE]
      );
    })

    it('testCanReturnMessageWithNoRuleEngine&UnknownRestrictionCode', async function () {
      // Act + Assert
      (await this.cmtat.messageForTransferRestriction(254)).should.equal(
        'Unknown code'
      )
    })
  })
}
module.exports = ValidationModuleSetRuleEngineCommon
