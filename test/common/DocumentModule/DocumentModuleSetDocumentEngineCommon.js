const { expect } = require('chai')
const {
  DOCUMENT_ENGINE_ROLE,
  ZERO_ADDRESS,
  IERC1643_INTERFACEID,
  IERC165_INTERFACEID
} = require('../../utils.js')
const { ethers, upgrades } = require('hardhat')

function DocumentModuleSetDocumentEngineCommon () {
  context('DocumentEngineInitializerTest', function () {
    it('testCanInitializeWithDocumentEngine', async function () {
      // Deploy a document engine mock
      const documentEngineMock = await ethers.deployContract(
        'DocumentEngineMock'
      )

      // Deploy CMTATDocumentEngineModuleMock via proxy
      const ETHERS_CMTAT_PROXY_FACTORY = await ethers.getContractFactory(
        'CMTATDocumentEngineModuleMock'
      )
      const engineMock = await upgrades.deployProxy(
        ETHERS_CMTAT_PROXY_FACTORY,
        [
          this.admin.address,
          ['CMTA Token', 'CMTAT', 0],
          documentEngineMock.target
        ],
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

    it('testCanInitializeWithoutDocumentEngine', async function () {
      const ETHERS_CMTAT_PROXY_FACTORY = await ethers.getContractFactory(
        'CMTATDocumentEngineModuleMock'
      )
      const engineMock = await upgrades.deployProxy(
        ETHERS_CMTAT_PROXY_FACTORY,
        [this.admin.address, ['CMTA Token', 'CMTAT', 0], ZERO_ADDRESS],
        {
          initializer: 'initialize(address,(string,string,uint8),address)',
          from: this.deployerAddress.address,
          unsafeAllow: ['missing-initializer', 'missing-initializer-call']
        }
      )

      expect(await engineMock.documentEngine()).to.equal(ZERO_ADDRESS)
    })

    it('testCannotInitializeTwice', async function () {
      const documentEngineMock = await ethers.deployContract(
        'DocumentEngineMock'
      )
      const ETHERS_CMTAT_PROXY_FACTORY = await ethers.getContractFactory(
        'CMTATDocumentEngineModuleMock'
      )
      const engineMock = await upgrades.deployProxy(
        ETHERS_CMTAT_PROXY_FACTORY,
        [
          this.admin.address,
          ['CMTA Token', 'CMTAT', 0],
          documentEngineMock.target
        ],
        {
          initializer: 'initialize(address,(string,string,uint8),address)',
          from: this.deployerAddress.address,
          unsafeAllow: ['missing-initializer', 'missing-initializer-call']
        }
      )

      await expect(
        engineMock['initialize(address,(string,string,uint8),address)'](
          this.admin.address,
          ['CMTA Token', 'CMTAT', 0],
          documentEngineMock.target
        )
      ).to.be.revertedWithCustomError(engineMock, 'InvalidInitialization')
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
        .withArgs(this.address1.address, DOCUMENT_ENGINE_ROLE)
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

    it('testAdvertisesERC1643Interface', async function () {
      // The engine variant must advertise ERC-1643 (0xecfecec8), matching the
      // in-contract variant, per the ERC-1643 ERC-165 SHOULD.
      expect(await this.cmtat.supportsInterface(IERC1643_INTERFACEID)).to.equal(
        true
      )
      expect(await this.cmtat.supportsInterface(IERC165_INTERFACEID)).to.equal(
        true
      )
    })

    it('testTokenReEmitsStandardDocumentEvents', async function () {
      await this.cmtat
        .connect(this.admin)
        .setDocumentEngine(this.documentEngineMock.target)
      const name = ethers.encodeBytes32String('doc1')
      const uri = 'ipfs://doc'
      const documentHash = ethers.encodeBytes32String('hash')

      // ERC-1643 is a per-contract interface: a subscriber watching the token address
      // must see the events. Since the token delegates to the engine, it re-emits the
      // standard events on its own address (dual emission).
      await expect(
        this.cmtat.connect(this.admin).setDocument(name, uri, documentHash)
      )
        .to.emit(this.cmtat, 'DocumentUpdated')
        .withArgs(name, uri, documentHash)

      await expect(this.cmtat.connect(this.admin).removeDocument(name))
        .to.emit(this.cmtat, 'DocumentRemoved')
        .withArgs(name, uri, documentHash)
    })

    it('testCannotSetDocumentWithoutEngine', async function () {
      const name = ethers.encodeBytes32String('doc1')
      await expect(
        this.cmtat
          .connect(this.admin)
          .setDocument(name, 'ipfs://doc', ethers.encodeBytes32String('hash'))
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_DocumentEngineModule_NoDocumentEngine'
      )
    })
  })
}
module.exports = DocumentModuleSetDocumentEngineCommon
