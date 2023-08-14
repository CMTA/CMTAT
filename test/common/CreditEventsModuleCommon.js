const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { DEBT_CREDIT_EVENT_ROLE } = require('../utils')
const { expectRevertCustomError } = require('../../openzeppelin-contracts-upgradeable/test/helpers/customError.js');
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
      this.logs = await this.cmtat.setFlagDefault(true, { from: owner });
      // Assert
      (await this.cmtat.creditEvents()).flagDefault.should.equal(true)
      expectEvent(this.logs, 'FlagDefault', {
        newFlagDefault: true
      })
    })

    it('testAdminCanNotSetFlagDefaultWithTheSameValue', async function () {
      // Act + Assert
      await expectRevertCustomError(
        this.cmtat.setFlagDefault(await this.cmtat.creditEvents().flagDefault, { from: owner }),
        'CMTAT_DebtModule_SameValue',
        []
      )
    })

    it('testAdminCanSetFlagRedeemed', async function () {
      // Arrange
      (await this.cmtat.creditEvents()).flagRedeemed.should.equal(false);
      // Act
      this.logs = await this.cmtat.setFlagRedeemed(true, { from: owner });
      // Assert
      (await this.cmtat.creditEvents()).flagRedeemed.should.equal(true)
      expectEvent(this.logs, 'FlagRedeemed', {
        newFlagRedeemed: true
      })
    })

    it('testAdminCanNotSetFlagRedeemedWithTheSameValue', async function () {
      // Act + Assert
      await expectRevertCustomError(
        this.cmtat.setFlagRedeemed(await this.cmtat.creditEvents().flagRedeemed, { from: owner }),
        'CMTAT_DebtModule_SameValue',
        []
      )
    })

    it('testAdminCanSetRating', async function () {
      // Arrange
      (await this.cmtat.creditEvents()).rating.should.equal('');
      // Act
      this.logs = await this.cmtat.setRating('B++', { from: owner });
      // Assert
      (await this.cmtat.creditEvents()).rating.should.equal('B++')
      expectEvent(this.logs, 'Rating', {
        newRatingIndexed: web3.utils.sha3('B++'),
        newRating: 'B++'
      })
    })
  })

  context('NonAdminCannotSetDebt', function () {
    it('testCannotNonAdminSetCreditEvents', async function () {
      // Act
      await expectRevertCustomError(
        this.cmtat.setCreditEvents(true, true, 'B++', { from: attacker }),
        'AccessControlUnauthorizedAccount',
        [attacker, DEBT_CREDIT_EVENT_ROLE]
      )
    })

    it('testCannotNonAdminSetFlagDefault', async function () {
      // Act
      await expectRevertCustomError(
        this.cmtat.setFlagDefault(true, { from: attacker }),
        'AccessControlUnauthorizedAccount',
        [attacker, DEBT_CREDIT_EVENT_ROLE]
      )
    })

    it('testCannotNonAdminSetFlagRedeemed', async function () {
      // Act
      await expectRevertCustomError(
        this.cmtat.setFlagRedeemed(true, { from: attacker }),
        'AccessControlUnauthorizedAccount',
        [attacker, DEBT_CREDIT_EVENT_ROLE]
      )
    })

    it('testCannotNonAdminSetRating', async function () {
      // Act
      await expectRevertCustomError(
        this.cmtat.setRating('B++', { from: attacker }),
        'AccessControlUnauthorizedAccount',
        [attacker, DEBT_CREDIT_EVENT_ROLE]
      )
    })
  })
}
module.exports = CreditEventsModuleCommon
