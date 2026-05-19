const { expect } = require('chai')
const { DOCUMENT_ROLE, ZERO_ADDRESS } = require('../../utils.js')
const { ethers, upgrades } = require('hardhat')

function DocumentModuleSetDocumentEngineCommon () {
  context('DocumentEngineInitializerTest', function () {
    it('testCanInitializeWithDocumentEngine', async function () {
      // Deploy a document engine mock
      const documentEngineMock = await ethers.deployContract('DocumentEngineMock')

      // Deploy CMTATDocumentEngineModuleMock via proxy
      const ETHERS_CMTAT_PROXY_FACTORY = await ethers.getContractFactory(
        'CMTATDocumentEngineModuleMock'
      )
      const engineMock = await upgrades.deployProxy(
        ETHERS_CMTAT_PROXY_FACTORY,
        [this.admin.address, ['CMTA Token', 'CMTAT', 0], documentEngineMock.target],
        {
          initializer: 'initialize(address,(string,string,uint8),address)',
          from: this.deployerAddress.address,
          unsafeAllow: ['missing-initializer', 'missing-initializer-call']
        }
      )

      // Verify document engine was set
      expect(await engineMock.documentEngine()).to.equal(
        documentEngineMock.target
      )
    })
  })

  context('DocumentEngineSetTest', function () {
    beforeEach(async function () {
      this.documentEngineMock = await ethers.deployContract(
        'DocumentEngineMock'
      )
      const ETHERS_CMTAT_PROXY_FACTORY = await ethers.getContractFactory(
        'CMTATDocumentEngineModuleMock'
      )
      this.cmtat = await upgrades.deployProxy(
        ETHERS_CMTAT_PROXY_FACTORY,
        [this.admin.address, ['CMTA Token', 'CMTAT', 0], ZERO_ADDRESS],
        {
          initializer: 'initialize(address,(string,string,uint8),address)',
          from: this.deployerAddress.address,
          unsafeAllow: ['missing-initializer', 'missing-initializer-call']
        }
      )
    })

    it('testCanBeSetByAdmin', async function () {
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .setDocumentEngine(this.documentEngineMock.target)
      // Assert
      // emits a DocumentEngine event
      await expect(this.logs)
        .to.emit(this.cmtat, 'DocumentEngine')
        .withArgs(this.documentEngineMock.target)
    })

    it('testCanNotBeSetByAdminWithTheSameValue', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .setDocumentEngine(this.documentEngineMock.target)

      // Act
      await expect(
        this.cmtat
          .connect(this.admin)
          .setDocumentEngine(this.documentEngineMock.target)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_DocumentEngineModule_SameValue'
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
      // Act
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
