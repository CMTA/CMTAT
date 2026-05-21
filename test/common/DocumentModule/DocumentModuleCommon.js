const { expect } = require('chai')
const { ZERO_ADDRESS, DOCUMENT_ROLE } = require('../../utils')

function DocumentModuleCommon () {
  context('Document Module Test', function () {
    beforeEach(async function () {
      const hasDocumentEngine = this.cmtat.interface.hasFunction('documentEngine()')
      if (hasDocumentEngine && !this.definedAtDeployment) {
        this.documentEngineMock = await ethers.deployContract(
          'DocumentEngineMock'
        )
      }
      if (
        hasDocumentEngine &&
        (await this.cmtat.documentEngine()) === ZERO_ADDRESS
      ) {
        await this.cmtat
          .connect(this.admin)
          .setDocumentEngine(this.documentEngineMock.target)
      }
    })
    it('testCanReturnTheRightAddressIfSet', async function () {
      if (this.cmtat.interface.hasFunction('documentEngine()') && this.definedAtDeployment) {
        const documentEngine = await this.cmtat.documentEngine()
        expect(this.documentEngineMock.target).to.equal(documentEngine)
      }
    })
    it('testCanSetAndGetADocument', async function () {
      const name = ethers.encodeBytes32String('doc1')
      const uri = 'https://github.com/CMTA/CMTAT'
      const documentHash = ethers.encodeBytes32String('hash1')

      await this.cmtat.connect(this.admin).setDocument(name, uri, documentHash)

      const doc = await this.cmtat.getDocument(name)
      expect(doc.uri).to.equal(uri)
      expect(doc.documentHash).to.equal(documentHash)
      expect(doc.lastModified).to.be.gt(0)
    })

    it('testCannotSetDocumentByNonDocumentRole', async function () {
      const name = ethers.encodeBytes32String('doc1')
      const uri = 'https://github.com/CMTA/CMTAT'
      const documentHash = ethers.encodeBytes32String('hash1')

      await expect(
        this.cmtat.connect(this.address1).setDocument(name, uri, documentHash)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, DOCUMENT_ROLE)
    })

    it('testCanUpdateADocument', async function () {
      const name = ethers.encodeBytes32String('doc1')
      const uri1 = 'https://github.com/CMTA/CMTAT'
      const documentHash1 = ethers.encodeBytes32String('hash1')

      const uri2 = 'https://github.com/CMTA/CMTAT/V2'
      const documentHash2 = ethers.encodeBytes32String('hash2')

      await this.cmtat.connect(this.admin).setDocument(name, uri1, documentHash1)
      await this.cmtat.connect(this.admin).setDocument(name, uri2, documentHash2)

      const doc = await this.cmtat.getDocument(name)
      expect(doc.uri).to.equal(uri2)
      expect(doc.documentHash).to.equal(documentHash2)
      expect(doc.lastModified).to.be.gt(0)
    })

    it('testCanGetNullValueIfNoDocument', async function () {
      const name = ethers.encodeBytes32String('doc1')
      const doc = await this.cmtat.getDocument(name)
      expect(doc.uri).to.equal('')
      expect(doc.documentHash).to.equal(ethers.encodeBytes32String(''))
      expect(doc.lastModified).to.equal(0)
    })

    it('testCanRemoveADocument', async function () {
      const name = ethers.encodeBytes32String('doc1')
      const uri = 'https://github.com/CMTA/CMTAT'
      const documentHash = ethers.encodeBytes32String('hash1')

      await this.cmtat.connect(this.admin).setDocument(name, uri, documentHash)
      await this.cmtat.connect(this.admin).removeDocument(name)

      const doc = await this.cmtat.getDocument(name)
      expect(doc.uri).to.equal('')
      expect(doc.documentHash).to.equal(ethers.encodeBytes32String(''))
      expect(doc.lastModified).to.equal(0)
    })

    it('testCannotRemoveDocumentByNonDocumentRole', async function () {
      const name = ethers.encodeBytes32String('doc1')
      const uri = 'https://github.com/CMTA/CMTAT'
      const documentHash = ethers.encodeBytes32String('hash1')
      await this.cmtat.connect(this.admin).setDocument(name, uri, documentHash)

      await expect(
        this.cmtat.connect(this.address1).removeDocument(name)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, DOCUMENT_ROLE)
    })

    it('testCanReturnAllDocumentNames', async function () {
      const name1 = ethers.encodeBytes32String('doc1')
      const uri1 = 'https://github.com/CMTA/CMTAT'
      const documentHash1 = ethers.encodeBytes32String('hash1')

      const name2 = ethers.encodeBytes32String('doc2')
      const uri2 = 'https://github.com/CMTA/CMTAT/V2'
      const documentHash2 = ethers.encodeBytes32String('hash2')

      await this.cmtat.connect(this.admin).setDocument(name1, uri1, documentHash1)
      await this.cmtat.connect(this.admin).setDocument(name2, uri2, documentHash2)

      const documentNames = await this.cmtat.getAllDocuments()
      expect(documentNames.length).to.equal(2)
      expect(documentNames).to.include(name1)
      expect(documentNames).to.include(name2)
    })

    it('testCanRemoveDocumentAndCompactArrayWhenNotLast', async function () {
      const name1 = ethers.encodeBytes32String('doc1')
      const uri1 = 'https://github.com/CMTA/CMTAT'
      const documentHash1 = ethers.encodeBytes32String('hash1')

      const name2 = ethers.encodeBytes32String('doc2')
      const uri2 = 'https://github.com/CMTA/CMTAT/V2'
      const documentHash2 = ethers.encodeBytes32String('hash2')

      await this.cmtat.connect(this.admin).setDocument(name1, uri1, documentHash1)
      await this.cmtat.connect(this.admin).setDocument(name2, uri2, documentHash2)

      // Remove the first inserted document to execute the internal swap path
      // in removeDocument (index != lastIndex).
      await this.cmtat.connect(this.admin).removeDocument(name1)

      const names = await this.cmtat.getAllDocuments()
      expect(names.length).to.equal(1)
      expect(names[0]).to.equal(name2)

      const removedDoc = await this.cmtat.getDocument(name1)
      expect(removedDoc.uri).to.equal('')
      expect(removedDoc.documentHash).to.equal(ethers.encodeBytes32String(''))
      expect(removedDoc.lastModified).to.equal(0)

      const remainingDoc = await this.cmtat.getDocument(name2)
      expect(remainingDoc.uri).to.equal(uri2)
      expect(remainingDoc.documentHash).to.equal(documentHash2)
      expect(remainingDoc.lastModified).to.be.gt(0)
    })
  })
}
module.exports = DocumentModuleCommon
