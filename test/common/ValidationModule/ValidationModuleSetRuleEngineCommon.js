const { expect } = require('chai')
const { DEFAULT_ADMIN_ROLE, ZERO_ADDRESS } = require('../../utils')

function ValidationModuleSetRuleEngineCommon () {
  context('RuleEngineSetTest', function () {
    it('testCanBeSetByAdmin', async function () {
      // Assert
      expect(await this.cmtat.ruleEngine()).to.equal(ZERO_ADDRESS)
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .setRuleEngine(this.ruleEngine)
      // Assert
      // emits a RuleEngineSet event
      await expect(this.logs)
        .to.emit(this.cmtat, 'RuleEngine')
        .withArgs(this.ruleEngine)
      expect(await this.cmtat.ruleEngine()).to.equal(this.ruleEngine)
    })

    it('testCanNotBeSetByAdminWithTheSameValue', async function () {
      // Act
      await expect(
        this.cmtat
          .connect(this.admin)
          .setRuleEngine(await this.cmtat.ruleEngine())
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_ValidationModule_SameValue'
      )
    })

    it('testCannotBeSetByNonAdmin', async function () {
      // Act
      await expect(
        this.cmtat.connect(this.address1).setRuleEngine(this.ruleEngine)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, DEFAULT_ADMIN_ROLE)
    })

    it('testCanReturnMessageWithNoRuleEngine&UnknownRestrictionCode', async function () {
      // Act + Assert
      expect(await this.cmtat.messageForTransferRestriction(254)).to.equal(
        'Unknown code'
      )
    })

    it('testCanDetectTransferRestrictionValidTransferWithoutRuleEngine', async function () {
      // Act + Assert
      expect(
        await this.cmtat.detectTransferRestriction(
          this.address1,
          this.admin,
          11
        )
      ).to.equal('0')
    })
  })
}
module.exports = ValidationModuleSetRuleEngineCommon
