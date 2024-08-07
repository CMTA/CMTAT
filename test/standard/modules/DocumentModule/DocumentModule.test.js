const DocumentModuleSetDocumentEngineCommon = require('../../../common/DocumentModule/DocumentModuleSetDocumentEngineCommon')
const DocumentModuleCommon = require('../../../common/DocumentModule/DocumentModuleCommon')
const { deployCMTATStandalone, fixture, loadFixture } = require('../../../deploymentUtils')
describe(
  'Standard - DocumentModule',
  function () {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture));
      this.cmtat = await deployCMTATStandalone(this._.address, this.admin.address, this.deployerAddress.address)
      this.documentEngineMock = await ethers.deployContract("DocumentEngineMock")

    })
    DocumentModuleCommon()
    DocumentModuleSetDocumentEngineCommon()
  }
)
