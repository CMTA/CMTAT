const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { DEFAULT_ADMIN_ROLE } = require('../utils')
const { should } = require('chai').should()

function BaseModuleCommon (owner, attacker) {
  context('AdminSetDebt', function () {
    it('testAdminCanSetDebt', async function () {
      // Arrange
      (await this.cmtat.debt()).guarantor.should.equal('');
      (await this.cmtat.debt()).bondHolder.should.equal('');
      (await this.cmtat.debt()).maturityDate.should.equal('');
      (await this.cmtat.debt()).interestRate.should.be.bignumber.equal('0');
      (await this.cmtat.debt()).parValue.should.be.bignumber.equal('0');
      (await this.cmtat.debt()).interestScheduleFormat.should.equal('');
      (await this.cmtat.debt()).interestPaymentDate.should.equal('');
      (await this.cmtat.debt()).dayCountConvention.should.equal('');
      (await this.cmtat.debt()).businessDayConvention.should.equal('');
      (await this.cmtat.debt()).publicHolidayCalendar.should.equal('')

      // Act
      await this.cmtat.setDebt(1, 2, 'guarantor', 'bondHolder', 'maturityDate', 'interestScheduleFormat',
        'interestPaymentDate', 'dayCountConvention', 'businessDayConvention', 'publicHolidayCalendar', { from: owner });
      // Assert
      (await this.cmtat.debt()).interestRate.should.be.bignumber.equal('1');
      (await this.cmtat.debt()).parValue.should.be.bignumber.equal('2');
      (await this.cmtat.debt()).guarantor.should.equal('guarantor');
      (await this.cmtat.debt()).bondHolder.should.equal('bondHolder');
      (await this.cmtat.debt()).maturityDate.should.equal('maturityDate');
      (await this.cmtat.debt()).interestScheduleFormat.should.equal('interestScheduleFormat');
      (await this.cmtat.debt()).interestPaymentDate.should.equal('interestPaymentDate');
      (await this.cmtat.debt()).dayCountConvention.should.equal('dayCountConvention');
      (await this.cmtat.debt()).businessDayConvention.should.equal('businessDayConvention');
      (await this.cmtat.debt()).publicHolidayCalendar.should.equal('publicHolidayCalendar')
    })

    it('testAdminCanSetInterestRate', async function () {
      // Arrange
      (await this.cmtat.debt()).interestRate.should.be.bignumber.equal('0');
      // Act
      ({ logs: this.logs } = await this.cmtat.setInterestRate(7, { from: owner }));
      // Assert
      (await this.cmtat.debt()).interestRate.should.be.bignumber.equal('7')
      expectEvent.inLogs(this.logs, 'InterestRateSet', {
        newInterestRate: '7'
      })
    })

    it('testAdminCanSetParValue', async function () {
      // Arrange
      (await this.cmtat.debt()).parValue.should.be.bignumber.equal('0');
      // Act
      ({ logs: this.logs } = await this.cmtat.setParValue(7, { from: owner }));
      // Assert
      (await this.cmtat.debt()).parValue.should.be.bignumber.equal('7')
      expectEvent.inLogs(this.logs, 'ParValueSet', {
        newParValue: '7'
      })
    })

    it('testAdminCanSetGuarantor', async function () {
      // Arrange
      (await this.cmtat.debt()).guarantor.should.equal('');
      // Act
      ({ logs: this.logs } = await this.cmtat.setGuarantor('Test', { from: owner }));
      // Assert
      (await this.cmtat.debt()).guarantor.should.equal('Test')
      expectEvent.inLogs(this.logs, 'GuarantorSet', {
        newGuarantor: 'Test'
      })
    })

    it('testAdminCanSetBonHolder', async function () {
      // Arrange
      (await this.cmtat.debt()).bondHolder.should.equal('');
      // Act
      ({ logs: this.logs } = await this.cmtat.setBondHolder('Test', { from: owner }));
      // Assert
      (await this.cmtat.debt()).bondHolder.should.equal('Test')
      expectEvent.inLogs(this.logs, 'BondHolderSet', {
        newBondHolder: 'Test'
      })
    })

    it('testAdminCanSetMaturityDate', async function () {
      // Arrange
      (await this.cmtat.debt()).maturityDate.should.equal('');
      // Act
      ({ logs: this.logs } = await this.cmtat.setMaturityDate('Test', { from: owner }));
      // Assert
      (await this.cmtat.debt()).maturityDate.should.equal('Test')
      expectEvent.inLogs(this.logs, 'MaturityDateSet', {
        newMaturityDate: 'Test'
      })
    })

    it('testAdminCanSetInterestScheduleFormat', async function () {
      // Arrange
      (await this.cmtat.debt()).interestScheduleFormat.should.equal('');
      // Act
      ({ logs: this.logs } = await this.cmtat.setInterestScheduleFormat('Test', { from: owner }));
      // Assert
      (await this.cmtat.debt()).interestScheduleFormat.should.equal('Test')
      expectEvent.inLogs(this.logs, 'InterestScheduleFormatSet', {
        newInterestScheduleFormat: 'Test'
      })
    })

    it('testAdminCanSetInterestPaymentDate', async function () {
      // Arrange
      (await this.cmtat.debt()).interestPaymentDate.should.equal('');
      // Act
      ({ logs: this.logs } = await this.cmtat.setInterestPaymentDate('Test', { from: owner }));
      // Assert
      (await this.cmtat.debt()).interestPaymentDate.should.equal('Test')
      expectEvent.inLogs(this.logs, 'InterestPaymentDateSet', {
        newInterestPaymentDate: 'Test'
      })
    })

    it('testAdminCanSetDayCountConvention', async function () {
      // Arrange
      (await this.cmtat.debt()).dayCountConvention.should.equal('');
      // Act
      ({ logs: this.logs } = await this.cmtat.setDayCountConvention('Test', { from: owner }));
      // Assert
      (await this.cmtat.debt()).dayCountConvention.should.equal('Test')
      expectEvent.inLogs(this.logs, 'DayCountConventionSet', {
        newDayCountConvention: 'Test'
      })
    })

    it('testAdminCanSetBusinessDayConvention', async function () {
      // Arrange
      (await this.cmtat.debt()).businessDayConvention.should.equal('');
      // Act
      ({ logs: this.logs } = await this.cmtat.setBusinessDayConvention('Test', { from: owner }));
      // Assert
      (await this.cmtat.debt()).businessDayConvention.should.equal('Test')
      expectEvent.inLogs(this.logs, 'BusinessDayConventionSet', {
        newBusinessDayConvention: 'Test'
      })
    })

    it('testAdminCanSetPublicHolidaysCalendar', async function () {
      // Arrange
      (await this.cmtat.debt()).publicHolidayCalendar.should.equal('');
      // Act
      ({ logs: this.logs } = await this.cmtat.setPublicHolidaysCalendar('Test', { from: owner }));
      // Assert
      (await this.cmtat.debt()).publicHolidayCalendar.should.equal('Test')
      expectEvent.inLogs(this.logs, 'PublicHolidaysCalendarSet', {
        newPublicHolidaysCalendar: 'Test'
      })
    })
  })

  context('NonAdminCannotSetDebt', function () {
    it('testCannotNonAdminSetDebt', async function () {
      // Act
      await expectRevert(
        this.cmtat.setDebt(1, 2, 'guarantor', 'bondHolder', 'maturityDate', 'interestScheduleFormat',
          'interestPaymentDate', 'dayCountConvention', 'businessDayConvention', 'publicHolidayCalendar', { from: attacker }),
        'AccessControl: account ' +
            attacker.toLowerCase() +
              ' is missing role ' +
              DEFAULT_ADMIN_ROLE)
    })

    it('testCannotNonAdminSetInterestRate', async function () {
      // Act
      await expectRevert(
        this.cmtat.setInterestRate(7, { from: attacker }),
        'AccessControl: account ' +
          attacker.toLowerCase() +
            ' is missing role ' +
            DEFAULT_ADMIN_ROLE)
    })

    it('testCannotNonAdminSetParValue', async function () {
      // Act
      await expectRevert(
        this.cmtat.setParValue(7, { from: attacker }),
        'AccessControl: account ' +
          attacker.toLowerCase() +
            ' is missing role ' +
            DEFAULT_ADMIN_ROLE)
    })

    it('testCannotNonAdminSetGuarantor', async function () {
      // Act
      await expectRevert(
        this.cmtat.setGuarantor('Test', { from: attacker }),
        'AccessControl: account ' +
          attacker.toLowerCase() +
            ' is missing role ' +
            DEFAULT_ADMIN_ROLE)
    })

    it('testCannotNonAdminSetBondHolder', async function () {
      // Act
      await expectRevert(
        this.cmtat.setBondHolder('Test', { from: attacker }),
        'AccessControl: account ' +
          attacker.toLowerCase() +
            ' is missing role ' +
            DEFAULT_ADMIN_ROLE)
    })
  })

  it('testCannotNonAdminSetMaturityDate', async function () {
    // Act
    await expectRevert(
      this.cmtat.setMaturityDate('Test', { from: attacker }),
      'AccessControl: account ' +
        attacker.toLowerCase() +
          ' is missing role ' +
          DEFAULT_ADMIN_ROLE)
  })

  it('testCannotNonAdminSetInterestScheduleFormat', async function () {
    // Act
    await expectRevert(
      this.cmtat.setInterestScheduleFormat('Test', { from: attacker }),
      'AccessControl: account ' +
        attacker.toLowerCase() +
          ' is missing role ' +
          DEFAULT_ADMIN_ROLE)
  })

  it('testCannotNonAdminSetInterestPaymentDate', async function () {
    // Act
    await expectRevert(
      this.cmtat.setInterestPaymentDate('Test', { from: attacker }),
      'AccessControl: account ' +
        attacker.toLowerCase() +
          ' is missing role ' +
          DEFAULT_ADMIN_ROLE)
  })

  it('testCannotNonAdminSetDayCountConvention', async function () {
    // Act
    await expectRevert(
      this.cmtat.setDayCountConvention('Test', { from: attacker }),
      'AccessControl: account ' +
        attacker.toLowerCase() +
          ' is missing role ' +
          DEFAULT_ADMIN_ROLE)
  })

  it('testCannotNonAdminSetBusinessDayConvention', async function () {
    // Act
    await expectRevert(
      this.cmtat.setBusinessDayConvention('Test', { from: attacker }),
      'AccessControl: account ' +
        attacker.toLowerCase() +
          ' is missing role ' +
          DEFAULT_ADMIN_ROLE)
  })

  it('testCannotNonAdminSetPublicHolidaysCalendar', async function () {
    // Act
    await expectRevert(
      this.cmtat.setPublicHolidaysCalendar('Test', { from: attacker }),
      'AccessControl: account ' +
        attacker.toLowerCase() +
          ' is missing role ' +
          DEFAULT_ADMIN_ROLE)
  })
}
module.exports = BaseModuleCommon
