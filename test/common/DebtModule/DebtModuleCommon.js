const { expect } = require('chai')
const { ZERO_ADDRESS } = require('../../utils')

function DebtModuleCommon () {
  context('Debt Engine test', function () {
    let debtBase, creditEvents

    beforeEach(async function () {
      debtBase = {
        interestRate: 500, // Example: 5.00%
        parValue: 1000000, // Example: 1,000,000
        guarantor: 'Guarantor A',
        bondHolder: 'BondHolder A',
        maturityDate: '2025-12-31',
        interestScheduleFormat: 'Semi-Annual',
        interestPaymentDate: '2024-06-30',
        dayCountConvention: '30/360',
        businessDayConvention: 'Following',
        publicHolidaysCalendar: 'US',
        issuanceDate: '2024-01-01',
        couponFrequency: 'Semi-Annual'
      }

      creditEvents = {
        flagDefault: false,
        flagRedeemed: false,
        rating: 'AAA'
      }
    })

    it('testCanSetAndGetDebtCorrectly', async function () {
      this.logs = await this.cmtat.connect(this.admin).setDebt(debtBase)
      await expect(this.logs)
        .to.emit(this.cmtat, 'Debt')
      const debt = await this.cmtat.debt()

      expect(debt.interestRate).to.equal(debtBase.interestRate)
      expect(debt.parValue).to.equal(debtBase.parValue)
      expect(debt.guarantor).to.equal(debtBase.guarantor)
      expect(debt.bondHolder).to.equal(debtBase.bondHolder)
      expect(debt.maturityDate).to.equal(debtBase.maturityDate)
      expect(debt.interestScheduleFormat).to.equal(
        debtBase.interestScheduleFormat
      )
      expect(debt.interestPaymentDate).to.equal(debtBase.interestPaymentDate)
      expect(debt.dayCountConvention).to.equal(debtBase.dayCountConvention)
      expect(debt.businessDayConvention).to.equal(
        debtBase.businessDayConvention
      )
      expect(debt.publicHolidaysCalendar).to.equal(
        debtBase.publicHolidaysCalendar
      )
      expect(debt.issuanceDate).to.equal(debtBase.issuanceDate)
      expect(debt.couponFrequency).to.equal(debtBase.couponFrequency)
    })
  })
}
module.exports = DebtModuleCommon
