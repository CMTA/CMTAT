const { expect } = require('chai')
const {
  ZERO_ADDRESS,
  DOCUMENT_ROLE,
  DOCUMENT_ENGINE_ROLE
} = require('../../utils')

function DocumentModuleCommon () {
  context('Document Module Test', function () {
    beforeEach(async function () {
      const hasDocumentEngine =
        this.cmtat.interface.hasFunction('documentEngine()')
      this.documentRole = hasDocumentEngine
        ? DOCUMENT_ENGINE_ROLE
        : DOCUMENT_ROLE
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
      // Only meaningful when the contract exposes documentEngine() and it is
      // wired at deployment
      if (
        !(
          this.cmtat.interface.hasFunction('documentEngine()') &&
          this.definedAtDeployment
        )
      ) {
        this.skip()
      }
      const documentEngine = await this.cmtat.documentEngine()
      expect(this.documentEngineMock.target).to.equal(documentEngine)
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
        .withArgs(this.address1.address, this.documentRole)
    })

    it('testCanUpdateADocument', async function () {
      const name = ethers.encodeBytes32String('doc1')
      const uri1 = 'https://github.com/CMTA/CMTAT'
      const documentHash1 = ethers.encodeBytes32String('hash1')

      const uri2 = 'https://github.com/CMTA/CMTAT/V2'
      const documentHash2 = ethers.encodeBytes32String('hash2')

      await this.cmtat
        .connect(this.admin)
        .setDocument(name, uri1, documentHash1)
      await this.cmtat
        .connect(this.admin)
        .setDocument(name, uri2, documentHash2)

      const doc = await this.cmtat.getDocument(name)
      expect(doc.uri).to.equal(uri2)
      expect(doc.documentHash).to.equal(documentHash2)
      expect(doc.lastModified).to.be.gt(0)
    })

    it('testSetDocumentEmitsDocumentUpdated', async function () {
      const name = ethers.encodeBytes32String('doc1')
      const uri = 'https://github.com/CMTA/CMTAT'
      const documentHash = ethers.encodeBytes32String('hash1')

      // ERC-1643: setDocument MUST emit DocumentUpdated on create/update.
      // On the DocumentEngine variant the token re-emits the event on its own address.
      await expect(
        this.cmtat.connect(this.admin).setDocument(name, uri, documentHash)
      )
        .to.emit(this.cmtat, 'DocumentUpdated')
        .withArgs(name, uri, documentHash)
    })

    it('testRemoveDocumentEmitsDocumentRemoved', async function () {
      const name = ethers.encodeBytes32String('doc1')
      const uri = 'https://github.com/CMTA/CMTAT'
      const documentHash = ethers.encodeBytes32String('hash1')
      await this.cmtat.connect(this.admin).setDocument(name, uri, documentHash)

      // ERC-1643: removeDocument MUST emit DocumentRemoved with the removed metadata.
      await expect(this.cmtat.connect(this.admin).removeDocument(name))
        .to.emit(this.cmtat, 'DocumentRemoved')
        .withArgs(name, uri, documentHash)
    })

    it('testCannotSetDocumentWithZeroName', async function () {
      const uri = 'https://github.com/CMTA/CMTAT'
      const documentHash = ethers.encodeBytes32String('hash1')

      // ERC-1643 (rework): setDocument SHOULD revert on name == bytes32(0) with ERC1643InvalidName.
      await expect(
        this.cmtat
          .connect(this.admin)
          .setDocument(ethers.ZeroHash, uri, documentHash)
      ).to.be.revertedWithCustomError(this.cmtat, 'ERC1643InvalidName')
    })

    it('testCannotRemoveMissingDocument', async function () {
      const name = ethers.encodeBytes32String('unknown')

      // ERC-1643: removeDocument MUST revert if the named document does not exist
      // (ERC1643MissingDocument).
      await expect(
        this.cmtat.connect(this.admin).removeDocument(name)
      ).to.be.revertedWithCustomError(this.cmtat, 'ERC1643MissingDocument')
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

      await expect(this.cmtat.connect(this.address1).removeDocument(name))
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, this.documentRole)
    })

    it('testCanReturnAllDocumentNames', async function () {
      const name1 = ethers.encodeBytes32String('doc1')
      const uri1 = 'https://github.com/CMTA/CMTAT'
      const documentHash1 = ethers.encodeBytes32String('hash1')

      const name2 = ethers.encodeBytes32String('doc2')
      const uri2 = 'https://github.com/CMTA/CMTAT/V2'
      const documentHash2 = ethers.encodeBytes32String('hash2')

      await this.cmtat
        .connect(this.admin)
        .setDocument(name1, uri1, documentHash1)
      await this.cmtat
        .connect(this.admin)
        .setDocument(name2, uri2, documentHash2)

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

      await this.cmtat
        .connect(this.admin)
        .setDocument(name1, uri1, documentHash1)
      await this.cmtat
        .connect(this.admin)
        .setDocument(name2, uri2, documentHash2)

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
