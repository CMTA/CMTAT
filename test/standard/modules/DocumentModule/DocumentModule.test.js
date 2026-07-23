const { expect } = require('chai')
const DocumentModuleSetDocumentEngineCommon = require('../../../common/DocumentModule/DocumentModuleSetDocumentEngineCommon')
const DocumentModuleCommon = require('../../../common/DocumentModule/DocumentModuleCommon')
const {
  deployCMTATStandalone,
  fixture,
  loadFixture
} = require('../../../deploymentUtils')
describe('Standard - DocumentModule', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATStandalone(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
  })
  DocumentModuleCommon()
  DocumentModuleSetDocumentEngineCommon()

  it('testCannotRemoveAMissingDocumentWithATypedError', async function () {
    const name = ethers.encodeBytes32String('missing')
    await expect(
      this.cmtat.connect(this.admin).removeDocument(name)
    ).to.be.revertedWithCustomError(this.cmtat, 'ERC1643MissingDocument')
  })

  it('testCannotSetADocumentWithTheZeroName', async function () {
    const zeroName = ethers.encodeBytes32String('')
    const uri = 'https://github.com/CMTA/CMTAT'
    const documentHash = ethers.encodeBytes32String('hash1')
    await expect(
      this.cmtat.connect(this.admin).setDocument(zeroName, uri, documentHash)
    ).to.be.revertedWithCustomError(this.cmtat, 'ERC1643InvalidName')
  })

  it('testGetDocumentDecodesAsTheFlatERC1643ABI', async function () {
    const name = ethers.encodeBytes32String('doc1')
    const uri = 'https://github.com/CMTA/CMTAT'
    const documentHash = ethers.encodeBytes32String('hash1')
    await this.cmtat.connect(this.admin).setDocument(name, uri, documentHash)

    // Decode the raw returndata against the spec's flat signature (string, bytes32, uint256).
    // A Document-struct return would prepend a 32-byte struct offset and mis-parse here.
    const data = this.cmtat.interface.encodeFunctionData('getDocument', [name])
    const raw = await ethers.provider.call({ to: this.cmtat.target, data })
    const [decodedUri, decodedHash, decodedLastModified] =
      ethers.AbiCoder.defaultAbiCoder().decode(
        ['string', 'bytes32', 'uint256'],
        raw
      )
    expect(decodedUri).to.equal(uri)
    expect(decodedHash).to.equal(documentHash)
    expect(decodedLastModified).to.be.gt(0)
  })

  // Regression: the DocumentEngineMock previously used a swap-pop that did not
  // update the moved name's key, so removing a document that had been moved into
  // another slot reverted with an out-of-bounds panic. Since the mock now reuses
  // DocumentERC1643Module, removing a moved document must succeed and enumeration
  // must stay consistent.
  it('DocumentEngineMock removes a moved document without corrupting enumeration', async function () {
    const engine = await ethers.deployContract('DocumentEngineMock')
    const [a, b, c] = ['a', 'b', 'c'].map((n) => ethers.encodeBytes32String(n))
    const uri = 'ipfs://doc'
    const documentHash = ethers.encodeBytes32String('hash')

    await engine.setDocument(a, uri, documentHash)
    await engine.setDocument(b, uri, documentHash)
    await engine.setDocument(c, uri, documentHash)

    // Remove the first (non-last) entry: this moves `c` into `a`'s slot.
    await engine.removeDocument(a)
    // Removing the moved entry must not revert (was out-of-bounds before the fix).
    await engine.removeDocument(c)

    const names = await engine.getAllDocuments()
    expect(names.length).to.equal(1)
    expect(names[0]).to.equal(b)
  })

  it('DocumentEngineMock emits the standard flat DocumentUpdated/DocumentRemoved events', async function () {
    const engine = await ethers.deployContract('DocumentEngineMock')
    const name = ethers.encodeBytes32String('doc1')
    const uri = 'ipfs://doc'
    const documentHash = ethers.encodeBytes32String('hash')

    await expect(engine.setDocument(name, uri, documentHash))
      .to.emit(engine, 'DocumentUpdated')
      .withArgs(name, uri, documentHash)
    await expect(engine.removeDocument(name))
      .to.emit(engine, 'DocumentRemoved')
      .withArgs(name, uri, documentHash)
  })
})
