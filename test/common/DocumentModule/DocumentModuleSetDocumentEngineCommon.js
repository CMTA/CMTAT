const { expect } = require('chai');
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
      await expect(this.cmtat.connect(this.admin).setDocumentEngine(await this.cmtat.documentEngine()))
      .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_DocumentModule_SameValue')
    })

    it('testCannotBeSetByNonAdmin', async function () {
      // Act
      await expect( this.cmtat.connect(this.address1).setDocumentEngine(this.documentEngineMock.target))
      .to.be.revertedWithCustomError(this.cmtat, 'AccessControlUnauthorizedAccount')
      .withArgs(this.address1.address, DOCUMENT_ROLE)
    })
  })
}
module.exports = DocumentModuleSetDocumentEngineCommon
