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
})
