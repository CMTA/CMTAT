const { expect } = require('chai');
const {
  expectRevertCustomError
} = require('../../../openzeppelin-contracts-upgradeable/test/helpers/customError.js')
const { DOCUMENT_ROLE } = require('../../utils.js')

function DocumentModuleSetDocumentEngineCommon () {
  context('DocumentEngineSetTest', function () {
    it('testCanBeSetByAdmin', async function () {
      // Act
      this.logs = await this.cmtat.connect(this.admin).setDocumentEngine(this.documentEngineMock.target)
      // Assert
      // emits a DocumentEngineSet event
      await expect(this.logs)
      .to.emit(this.cmtat, "DocumentEngine")
      .withArgs(this.documentEngineMock.target);
    })

    it('testCanNotBeSetByAdminWithTheSameValue', async function () {
      // Act
      await expectRevertCustomError(
        this.cmtat.connect(this.admin).setDocumentEngine(await this.cmtat.documentEngine()),
        'CMTAT_DocumentModule_SameValue',
        []
      )
    })

    it('testCannotBeSetByNonAdmin', async function () {
      // Act
      await expectRevertCustomError(
        this.cmtat.connect(this.address1).setDocumentEngine(this.documentEngineMock.target),
        'AccessControlUnauthorizedAccount',
        [this.address1.address, DOCUMENT_ROLE]
      )
    })
  })
}
module.exports = DocumentModuleSetDocumentEngineCommon
