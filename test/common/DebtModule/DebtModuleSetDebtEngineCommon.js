const { expect } = require('chai');
const {
  expectRevertCustomError
} = require('../../../openzeppelin-contracts-upgradeable/test/helpers/customError.js')
const { DEBT_ROLE } = require('../../utils.js')

function DebtModuleSetDebtEngineCommon () {
  context('DebtEngineSetTest', function () {
    it('testCanBeSetByAdmin', async function () {
      // Act
      this.logs = await this.cmtat.connect(this.admin).setDebtEngine(this.debtEngineMock.target)
      // Assert
      // emits a DebtEngineSet event
      await expect(this.logs)
      .to.emit(this.cmtat, "DebtEngine")
      .withArgs(this.debtEngineMock.target);
    })

    it('testCanNotBeSetByAdminWithTheSameValue', async function () {
      // Act
      await expectRevertCustomError(
        this.cmtat.connect(this.admin).setDebtEngine(await this.cmtat.debtEngine()),
        'CMTAT_DebtModule_SameValue',
        []
      )
    })

    it('testCannotBeSetByNonAdmin', async function () {
      // Act
      await expectRevertCustomError(
        this.cmtat.connect(this.address1).setDebtEngine(this.debtEngineMock.target),
        'AccessControlUnauthorizedAccount',
        [this.address1.address, DEBT_ROLE]
      )
    })
  })
}
module.exports = DebtModuleSetDebtEngineCommon
