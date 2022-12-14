const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { DEFAULT_ADMIN_ROLE } = require('../utils')
const { should } = require('chai').should()

const CMTAT = artifacts.require('CMTAT')
const RuleEngineMock = artifacts.require('RuleEngineMock')

function ValidationModuleCommon (admin, address1, address2, address3, fakeRuleEngine) {
  context('RuleEngineSetTest', function () {
    it('testCanBeSetByAdmin', async function () {
      // Act
      ({ logs: this.logs } = await this.cmtat.setRuleEngine(fakeRuleEngine, {
        from: admin
      }))
      // Assert
      // emits a RuleEngineSet event
      expectEvent.inLogs(this.logs, 'RuleEngineSet', {
        newRuleEngine: fakeRuleEngine
      })
    })

    it('testCannotBeSetByNonAdmin', async function () {
      // Act
      await expectRevert(
        this.cmtat.setRuleEngine(fakeRuleEngine, { from: address1 }),
        'AccessControl: account ' +
            address1.toLowerCase() +
            ' is missing role ' +
            DEFAULT_ADMIN_ROLE
      )
    })
  })

  // Transferring with Rule Engine set
  context('RuleEngineTransferTest', function () {
    beforeEach(async function () {
      this.ruleEngineMock = await RuleEngineMock.new({ from: admin })
      await this.cmtat.mint(address1, 31, { from: admin })
      await this.cmtat.mint(address2, 32, { from: admin })
      await this.cmtat.mint(address3, 33, { from: admin })
      await this.cmtat.setRuleEngine(this.ruleEngineMock.address, {
        from: admin
      })
    })

    it('testCanDetectTransferRestrictionValidTransfer', async function () {
      // Act + Assert
      (
        await this.cmtat.detectTransferRestriction(address1, address2, 11)
      ).should.be.bignumber.equal('0')
    })

    it('testCanReturnMessageValidTransfer', async function () {
      // Act + Assert
      (await this.cmtat.messageForTransferRestriction(0)).should.equal(
        'No restriction'
      )
    })

    it('testCanDetectTransferRestrictionWithAmountTooHigh', async function () {
      // Act + Assert
      (
        await this.cmtat.detectTransferRestriction(address1, address2, 21)
      ).should.be.bignumber.equal('10')
    })

    it('testCanReturnMessageWithAmountTooHigh', async function () {
      // Act + Assert
      (await this.cmtat.messageForTransferRestriction(10)).should.equal(
        'Amount too high'
      )
    })

    // ADDRESS1 may transfer tokens to ADDRESS2
    it('testCanTransferAllowedByRule', async function () {
      // Act
      await this.cmtat.transfer(address2, 11, { from: address1 });
      // Assert
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal('20');
      (await this.cmtat.balanceOf(address2)).should.be.bignumber.equal('43');
      (await this.cmtat.balanceOf(address3)).should.be.bignumber.equal('33')
    })

    // reverts if ADDRESS1 transfers more tokens than rule allows
    it('testCannotTransferIfNotAllowedByRule', async function () {
      // Act
      await expectRevert(
        this.cmtat.transfer(address2, 21, { from: address1 }),
        'CMTAT: transfer rejected by validation module'
      )
    })
  })
}
module.exports = ValidationModuleCommon
