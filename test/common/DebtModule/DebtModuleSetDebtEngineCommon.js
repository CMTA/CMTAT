const { expect } = require('chai')
const { DEBT_ROLE } = require('../../utils.js')

function DebtModuleSetDebtEngineCommon () {
  context('DebtEngineSetTest', function () {
    beforeEach(async function () {
      this.debtEngineMock = await ethers.deployContract('DebtEngineMock')
    })
    it('testCanBeSetByAdmin', async function () {
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .setDebtEngine(this.debtEngineMock.target)
      // Assert
      // emits a DebtEngineSet event
      await expect(this.logs)
        .to.emit(this.cmtat, 'DebtEngine')
        .withArgs(this.debtEngineMock.target)
    })

    it('testCanNotBeSetByAdminWithTheSameValue', async function () {
      // Act
      await expect(
        this.cmtat
          .connect(this.admin)
          .setDebtEngine(await this.cmtat.debtEngine())
      ).to.be.revertedWithCustomError(this.cmtat, 'CMTAT_DebtEngineModule_SameValue')
    })

    it('testCannotBeSetByNonAdmin', async function () {
      // Act
      await expect(
        this.cmtat
          .connect(this.address1)
          .setDebtEngine(this.debtEngineMock.target)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, DEBT_ROLE)
    })

    it('testGetEmptyDebtIfNoDebtEngine', async function () {
      const debt = await this.cmtat.debt()
      const events = await this.cmtat.creditEvents()

      expect(events.flagDefault).to.equal(false)
      expect(debt.debtInstrument.interestRate).to.equal(0)
    })
  })
}
module.exports = DebtModuleSetDebtEngineCommon
