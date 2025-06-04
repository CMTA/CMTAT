const { expect } = require('chai')
const { ZERO_ADDRESS } = require('../../utils')

function DebtEngineModuleCommon () {
  context('Debt Engine test', function () {
    let debtBase, creditEvents

    beforeEach(async function () {
      this.debtEngineMock = await ethers.deployContract('DebtEngineMock')
      if ((await this.cmtat.debtEngine()) === ZERO_ADDRESS) {
        await this.cmtat
          .connect(this.admin)
          .setDebtEngine(this.debtEngineMock.target)
      }
      debtIdentifier = {
        issuerName: 'CMTA',
        issuerDescription: 'Capital Market',
        guarantor: 'Guarantor A',
        debtHolder: 'debtHolder A'
      }
      debtInstrument = {
        interestRate: 500, // Example: 5.00%
        parValue: 1000000, // Example: 1,000,000
        minimumDenomination: 200,
        maturityDate: '2025-12-31',
        interestScheduleFormat: 'Semi-Annual',
        interestPaymentDate: '2024-06-30',
        dayCountConvention: '30/360',
        businessDayConvention: 'Following',
        issuanceDate: '2024-01-01',
        couponPaymentFrequency: 'Semi-Annual',
        currencyContract: ethers.Typed.address('0x000000000000000000000000000000000000dEaD'),
        currency: 'USDC'
      }
      debtBase = {
        debtIdentifier,
        debtInstrument
      }
      creditEvents = {
        flagDefault: false,
        flagRedeemed: false,
        rating: 'AAA'
      }
    })

    it('testCanReturnTheRightAddressIfSet', async function () {
      if (this.definedAtDeployment) {
        expect(this.debtEngineMock.target).to.equal(
          await this.cmtat.debtEngine()
        )
      }
    })

    it('testCanSetAndGetDebtCorrectly', async function () {
      await this.debtEngineMock.setDebt(debtBase)
      const debt = await this.cmtat.debt()
      // debt identifier
      expect(debt.debtIdentifier.issuerName).to.equal(debtBase.debtIdentifier.issuerName)
      expect(debt.debtIdentifier.issuerDescription).to.equal(debtBase.debtIdentifier.issuerDescription)
      expect(debt.debtIdentifier.guarantor).to.equal(debtBase.debtIdentifier.guarantor)
      expect(debt.debtIdentifier.debtHolder).to.equal(debtBase.debtIdentifier.debtHolder)

      // debt instrument
      expect(debt.debtInstrument.interestRate).to.equal(debtBase.debtInstrument.interestRate)
      expect(debt.debtInstrument.parValue).to.equal(debtBase.debtInstrument.parValue)
      expect(debt.debtInstrument.minimumDenomination).to.equal(debtBase.debtInstrument.minimumDenomination)
      expect(debt.debtInstrument.maturityDate).to.equal(debtBase.debtInstrument.maturityDate)
      expect(debt.debtInstrument.interestScheduleFormat).to.equal(
        debtBase.debtInstrument.interestScheduleFormat
      )
      expect(debt.debtInstrument.interestPaymentDate).to.equal(debtBase.debtInstrument.interestPaymentDate)
      expect(debt.debtInstrument.dayCountConvention).to.equal(debtBase.debtInstrument.dayCountConvention)
      expect(debt.debtInstrument.businessDayConvention).to.equal(
        debtBase.debtInstrument.businessDayConvention
      )
      expect(debt.debtInstrument.issuanceDate).to.equal(debtBase.debtInstrument.issuanceDate)
      expect(debt.debtInstrument.couponPaymentFrequency).to.equal(debtBase.debtInstrument.couponPaymentFrequency)
    })

    it('testCanSetAndGetCreditEventsCorrectly', async function () {
      await this.debtEngineMock.setCreditEvents(creditEvents)

      const events = await this.cmtat.creditEvents()
      expect(events.flagDefault).to.equal(creditEvents.flagDefault)
      expect(events.flagRedeemed).to.equal(creditEvents.flagRedeemed)
      expect(events.rating).to.equal(creditEvents.rating)
    })
  })
}
module.exports = DebtEngineModuleCommon
