const { expect } = require('chai')
const { DOCUMENT_ROLE } = require('../../utils.js')

function DocumentModuleSetDocumentEngineCommon () {
  context('DocumentEngineSetTest', function () {
    it('testCanBeSetByAdmin', async function () {
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .setDocumentEngine(this.documentEngineMock.target)
      // Assert
      // emits a DocumentEngineSet event
      await expect(this.logs)
        .to.emit(this.cmtat, 'DocumentEngine')
        .withArgs(this.documentEngineMock.target)
    })

    it('testCanNotBeSetByAdminWithTheSameValue', async function () {
      // Act
      await expect(
        this.cmtat
          .connect(this.admin)
          .setDocumentEngine(await this.cmtat.documentEngine())
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_DocumentModule_SameValue'
      )
    })

    it('testCannotBeSetByNonAdmin', async function () {
      // Act
      await expect(
        this.cmtat
          .connect(this.address1)
          .setDocumentEngine(this.documentEngineMock.target)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, DOCUMENT_ROLE)
    })

    it('testGetEmptyDocumentsIfNoDocumentEngine', async function () {
      const name = ethers.encodeBytes32String('doc1')
      // act
      const doc = await this.cmtat.getDocument(name)
      // Assert
      expect(doc.uri).to.equal('')
      expect(doc.documentHash).to.equal(ethers.encodeBytes32String(''))
      expect(doc.lastModified).to.equal(0)

      // Act
      const documentNames = await this.cmtat.getAllDocuments()
      // Assert
      expect(documentNames.length).to.equal(0)
    })
  })
}
module.exports = DocumentModuleSetDocumentEngineCommon
