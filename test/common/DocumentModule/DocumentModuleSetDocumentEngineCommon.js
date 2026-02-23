const { expect } = require('chai')
const { DOCUMENT_ROLE, ZERO_ADDRESS } = require('../../utils.js')
const { ethers, upgrades } = require('hardhat')

// hash = keccak256("doc1Hash");
const TERMS = [
  'doc1',
  'https://example.com/doc1',
  '0x6a12eff2f559a5e529ca2c563c53194f6463ed5c61d1ae8f8731137467ab0279'
]

function DocumentModuleSetDocumentEngineCommon () {
  context('DocumentEngineInitializerTest', function () {
    it('testCanInitializeWithDocumentEngine', async function () {
      // Deploy a document engine mock
      const documentEngineMock = await ethers.deployContract('DocumentEngineMock')

      // Deploy CMTATEngineInitializerMock via proxy
      const ETHERS_CMTAT_PROXY_FACTORY = await ethers.getContractFactory(
        'CMTATEngineInitializerMock'
      )
      const engineMock = await upgrades.deployProxy(
        ETHERS_CMTAT_PROXY_FACTORY,
        [
          this.admin.address,
          ['CMTA Token', 'CMTAT', 0],
          ['CMTAT_ISIN', TERMS, 'CMTAT_info'],
          [ZERO_ADDRESS]
        ],
        {
          initializer: 'initialize',
          constructorArgs: [ZERO_ADDRESS],
          from: this.deployerAddress.address,
          unsafeAllow: ['missing-initializer']
        }
      )

      // Call initializeWithEngines to cover __DocumentEngineModule_init_unchained
      await engineMock
        .connect(this.admin)
        .initializeWithEngines(
          ZERO_ADDRESS, // No snapshot engine
          documentEngineMock.target
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
    })
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
