const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { DEFAULT_ADMIN_ROLE } = require('../../utils')
const { should } = require('chai').should()

function ValidationModuleSetRuleEngineCommon (admin, address1, ruleEngine) {
  context('RuleEngineSetTest', function () {
    it('testCanBeSetByAdmin', async function () {
      // Act
      ({ logs: this.logs } = await this.cmtat.setRuleEngine(ruleEngine, {
        from: admin
      }))
      // Assert
      // emits a RuleEngineSet event
      expectEvent.inLogs(this.logs, 'RuleEngine', {
        newRuleEngine: ruleEngine
      })
    })

    it('testCanNotBeSetByAdminWithTheSameValue', async function () {
      // Act
      await expectRevert(this.cmtat.setRuleEngine(await this.cmtat.ruleEngine(), { from: admin }),
        'Same value'
      )
    })

    it('testCannotBeSetByNonAdmin', async function () {
      // Act
      await expectRevert(
        this.cmtat.setRuleEngine(ruleEngine, { from: address1 }),
        'AccessControl: account ' +
            address1.toLowerCase() +
            ' is missing role ' +
            DEFAULT_ADMIN_ROLE
      )
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
