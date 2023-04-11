const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { DEFAULT_ADMIN_ROLE, DEBT_ROLE } = require('../utils')
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
      (await this.cmtat.debt()).publicHolidayCalendar.should.equal('');
      (await this.cmtat.debt()).issuanceDate.should.equal('');
      (await this.cmtat.debt()).couponFrequency.should.equal('')

      // Act
      await this.cmtat.setDebt(1, 2, 'guarantor', 'bondHolder', 'maturityDate', 'interestScheduleFormat',
        'interestPaymentDate', 'dayCountConvention', 'businessDayConvention', 'publicHolidayCalendar', 'issuanceDate', 'couponFrequency', { from: owner });
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
      (await this.cmtat.debt()).publicHolidayCalendar.should.equal('publicHolidayCalendar');
      (await this.cmtat.debt()).issuanceDate.should.equal('issuanceDate');
      (await this.cmtat.debt()).couponFrequency.should.equal('couponFrequency')
    })

    it('testAdminCanSetInterestRate', async function () {
      // Arrange
      (await this.cmtat.debt()).interestRate.should.be.bignumber.equal('0');
      // Act
      ({ logs: this.logs } = await this.cmtat.setInterestRate(7, { from: owner }));
      // Assert
      (await this.cmtat.debt()).interestRate.should.be.bignumber.equal('7')
      expectEvent.inLogs(this.logs, 'InterestRate', {
        newInterestRate: '7'
      })
    })

    it('testAdminCanNotSetInterestRateWithTheSameValue', async function () {
      // Arrange
      (await this.cmtat.debt()).interestRate.should.be.bignumber.equal('0')
      // Act + Assert
      await expectRevert(this.cmtat.setInterestRate(0, { from: owner }),
        'Same value'
      )
    })

    it('testAdminCanSetParValue', async function () {
      // Arrange
      (await this.cmtat.debt()).parValue.should.be.bignumber.equal('0');
      // Act
      ({ logs: this.logs } = await this.cmtat.setParValue(7, { from: owner }));
      // Assert
      (await this.cmtat.debt()).parValue.should.be.bignumber.equal('7')
      expectEvent.inLogs(this.logs, 'ParValue', {
        newParValue: '7'
      })
    })

    it('testAdminCanNotSetParValueWithTheSameValue', async function () {
      // Arrange
      (await this.cmtat.debt()).parValue.should.be.bignumber.equal('0')
      // Act + Assert
      await expectRevert(this.cmtat.setParValue(0, { from: owner }),
        'Same value'
      )
    })

    it('testAdminCanSetGuarantor', async function () {
      // Arrange
      (await this.cmtat.debt()).guarantor.should.equal('');
      // Act
      ({ logs: this.logs } = await this.cmtat.setGuarantor('Test', { from: owner }));
      // Assert
      (await this.cmtat.debt()).guarantor.should.equal('Test')
      expectEvent.inLogs(this.logs, 'Guarantor', {
        newGuarantorIndexed: web3.utils.sha3('Test'),
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
      expectEvent.inLogs(this.logs, 'BondHolder', {
        newBondHolderIndexed: web3.utils.sha3('Test'),
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
      expectEvent.inLogs(this.logs, 'MaturityDate', {
        newMaturityDateIndexed: web3.utils.sha3('Test'),
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
      expectEvent.inLogs(this.logs, 'InterestScheduleFormat', {
        newInterestScheduleFormatIndexed: web3.utils.sha3('Test'),
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
      expectEvent.inLogs(this.logs, 'InterestPaymentDate', {
        newInterestPaymentDateIndexed: web3.utils.sha3('Test'),
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
      expectEvent.inLogs(this.logs, 'DayCountConvention', {
        newDayCountConventionIndexed: web3.utils.sha3('Test'),
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
      expectEvent.inLogs(this.logs, 'BusinessDayConvention', {
        newBusinessDayConventionIndexed: web3.utils.sha3('Test'),
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
      expectEvent.inLogs(this.logs, 'PublicHolidaysCalendar', {
        newPublicHolidaysCalendarIndexed: web3.utils.sha3('Test'),
        newPublicHolidaysCalendar: 'Test'
      })
    })

    it('testAdminCanSetIssuanceDate', async function () {
      // Arrange
      (await this.cmtat.debt()).issuanceDate.should.equal('');
      // Act
      ({ logs: this.logs } = await this.cmtat.setIssuanceDate('Test', { from: owner }));
      // Assert
      (await this.cmtat.debt()).issuanceDate.should.equal('Test')
      expectEvent.inLogs(this.logs, 'IssuanceDate', {
        newIssuanceDateIndexed: web3.utils.sha3('Test'),
        newIssuanceDate: 'Test'
      })
    })

    it('testAdminCanSetCouponFrequency', async function () {
      // Arrange
      (await this.cmtat.debt()).couponFrequency.should.equal('');
      // Act
      ({ logs: this.logs } = await this.cmtat.setCouponFrequency('Test', { from: owner }));
      // Assert
      (await this.cmtat.debt()).couponFrequency.should.equal('Test')
      expectEvent.inLogs(this.logs, 'CouponFrequency', {
        newCouponFrequencyIndexed: web3.utils.sha3('Test'),
        newCouponFrequency: 'Test'
      })
    })
  })

  context('NonAdminCannotSetDebt', function () {
    it('testCannotNonAdminSetDebt', async function () {
      // Act
      await expectRevert(
        this.cmtat.setDebt(1, 2, 'guarantor', 'bondHolder', 'maturityDate', 'interestScheduleFormat',
          'interestPaymentDate', 'dayCountConvention', 'businessDayConvention', 'publicHolidayCalendar', 'issuanceDate', 'couponFrequency', { from: attacker }),
        'AccessControl: account ' +
            attacker.toLowerCase() +
              ' is missing role ' +
              DEBT_ROLE)
    })

    it('testCannotNonAdminSetInterestRate', async function () {
      // Act
      await expectRevert(
        this.cmtat.setInterestRate(7, { from: attacker }),
        'AccessControl: account ' +
          attacker.toLowerCase() +
            ' is missing role ' +
            DEBT_ROLE)
    })

    it('testCannotNonAdminSetParValue', async function () {
      // Act
      await expectRevert(
        this.cmtat.setParValue(7, { from: attacker }),
        'AccessControl: account ' +
          attacker.toLowerCase() +
            ' is missing role ' +
            DEBT_ROLE)
    })

    it('testCannotNonAdminSetGuarantor', async function () {
      // Act
      await expectRevert(
        this.cmtat.setGuarantor('Test', { from: attacker }),
        'AccessControl: account ' +
          attacker.toLowerCase() +
            ' is missing role ' +
            DEBT_ROLE)
    })

    it('testCannotNonAdminSetBondHolder', async function () {
      // Act
      await expectRevert(
        this.cmtat.setBondHolder('Test', { from: attacker }),
        'AccessControl: account ' +
          attacker.toLowerCase() +
            ' is missing role ' +
            DEBT_ROLE)
    })
  })

  it('testCannotNonAdminSetMaturityDate', async function () {
    // Act
    await expectRevert(
      this.cmtat.setMaturityDate('Test', { from: attacker }),
      'AccessControl: account ' +
        attacker.toLowerCase() +
          ' is missing role ' +
          DEBT_ROLE)
  })

  it('testCannotNonAdminSetInterestScheduleFormat', async function () {
    // Act
    await expectRevert(
      this.cmtat.setInterestScheduleFormat('Test', { from: attacker }),
      'AccessControl: account ' +
        attacker.toLowerCase() +
          ' is missing role ' +
          DEBT_ROLE)
  })

  it('testCannotNonAdminSetInterestPaymentDate', async function () {
    // Act
    await expectRevert(
      this.cmtat.setInterestPaymentDate('Test', { from: attacker }),
      'AccessControl: account ' +
        attacker.toLowerCase() +
          ' is missing role ' +
          DEBT_ROLE)
  })

  it('testCannotNonAdminSetDayCountConvention', async function () {
    // Act
    await expectRevert(
      this.cmtat.setDayCountConvention('Test', { from: attacker }),
      'AccessControl: account ' +
        attacker.toLowerCase() +
          ' is missing role ' +
          DEBT_ROLE)
  })

  it('testCannotNonAdminSetBusinessDayConvention', async function () {
    // Act
    await expectRevert(
      this.cmtat.setBusinessDayConvention('Test', { from: attacker }),
      'AccessControl: account ' +
        attacker.toLowerCase() +
          ' is missing role ' +
          DEBT_ROLE)
  })

  it('testCannotNonAdminSetPublicHolidaysCalendar', async function () {
    // Act
    await expectRevert(
      this.cmtat.setPublicHolidaysCalendar('Test', { from: attacker }),
      'AccessControl: account ' +
        attacker.toLowerCase() +
          ' is missing role ' +
          DEBT_ROLE)
  })

  // 'issuanceDate', 'couponFrequency'
  it('testCannotNonAdminSetIssuanceDate', async function () {
    // Act
    await expectRevert(
      this.cmtat.setIssuanceDate('Test', { from: attacker }),
      'AccessControl: account ' +
        attacker.toLowerCase() +
          ' is missing role ' +
          DEBT_ROLE)
  })

  it('testCannotNonAdminSetCouponFrequency', async function () {
    // Act
    await expectRevert(
      this.cmtat.setCouponFrequency('Test', { from: attacker }),
      'AccessControl: account ' +
        attacker.toLowerCase() +
          ' is missing role ' +
          DEBT_ROLE)
  })
}
module.exports = BaseModuleCommon
