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
      expectEvent.inLogs(this.logs, 'RuleEngineSet', {
        newRuleEngine: ruleEngine
      })
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
  })
}
module.exports = ValidationModuleSetRuleEngineCommon
