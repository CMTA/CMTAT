const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { DEBT_CREDIT_EVENT_ROLE } = require('../utils')
const { should } = require('chai').should()

function CreditEventsModuleCommon (owner, attacker) {
  context('AdminSetCreditEvents', function () {
    it('testAdminCanSetCreditEvents', async function () {
      // Arrange
      (await this.cmtat.creditEvents()).flagDefault.should.equal(false);
      (await this.cmtat.creditEvents()).flagRedeemed.should.equal(false);
      (await this.cmtat.creditEvents()).rating.should.equal('')

      // Act
      await this.cmtat.setCreditEvents(true, true, 'B++', { from: owner });
      
      // Assert
      (await this.cmtat.creditEvents()).flagDefault.should.equal(true);
      (await this.cmtat.creditEvents()).flagRedeemed.should.equal(true);
      (await this.cmtat.creditEvents()).rating.should.equal('B++')
    })

    it('testAdminCanSetFlagDefault', async function () {
      // Arrange
      (await this.cmtat.creditEvents()).flagDefault.should.equal(false);
      // Act
      ({ logs: this.logs } = await this.cmtat.setFlagDefault(true, { from: owner }));
      // Assert
      (await this.cmtat.creditEvents()).flagDefault.should.equal(true)
      expectEvent.inLogs(this.logs, 'FlagDefault', {
        newFlagDefault: true
      })
    })

    it('testAdminCanSetFlagRedeemed', async function () {
      // Arrange
      (await this.cmtat.creditEvents()).flagRedeemed.should.equal(false);
      // Act
      ({ logs: this.logs } = await this.cmtat.setFlagRedeemed(true, { from: owner }));
      // Assert
      (await this.cmtat.creditEvents()).flagRedeemed.should.equal(true)
      expectEvent.inLogs(this.logs, 'FlagRedeemed', {
        newFlagRedeemed: true
      })
    })

    it('testAdminCanSetRating', async function () {
      // Arrange
      (await this.cmtat.creditEvents()).rating.should.equal('');
      // Act
      ({ logs: this.logs } = await this.cmtat.setRating('B++', { from: owner }));
      // Assert
      (await this.cmtat.creditEvents()).rating.should.equal('B++')
      expectEvent.inLogs(this.logs, 'Rating', {
        newRatingIndexed: web3.utils.sha3('B++'),
        newRating: 'B++'
      })
    })
  })

  context('NonAdminCannotSetDebt', function () {
    it('testCannotNonAdminSetCreditEvents', async function () {
      // Act
      await expectRevert(
        this.cmtat.setCreditEvents(true, true, 'B++', { from: attacker }),
        'AccessControl: account ' +
            attacker.toLowerCase() +
              ' is missing role ' +
              DEBT_CREDIT_EVENT_ROLE)
    })

    it('testCannotNonAdminSetFlagDefault', async function () {
      // Act
      await expectRevert(
        this.cmtat.setFlagDefault(true, { from: attacker }),
        'AccessControl: account ' +
          attacker.toLowerCase() +
            ' is missing role ' +
            DEBT_CREDIT_EVENT_ROLE)
    })

    it('testCannotNonAdminSetFlagRedeemed', async function () {
      // Act
      await expectRevert(
        this.cmtat.setFlagRedeemed(true, { from: attacker }),
        'AccessControl: account ' +
          attacker.toLowerCase() +
            ' is missing role ' +
            DEBT_CREDIT_EVENT_ROLE)
    })

    it('testCannotNonAdminSetRating', async function () {
      // Act
      await expectRevert(
        this.cmtat.setRating('B++', { from: attacker }),
        'AccessControl: account ' +
          attacker.toLowerCase() +
            ' is missing role ' +
            DEBT_CREDIT_EVENT_ROLE)
    })
  })
}
module.exports = CreditEventsModuleCommon
