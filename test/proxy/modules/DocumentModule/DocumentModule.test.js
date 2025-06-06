const DocumentModuleSetDocumentEngineCommon = require('../../../common/DocumentModule/DocumentModuleSetDocumentEngineCommon')
const DocumentModuleCommon = require('../../../common/DocumentModule/DocumentModuleCommon')
const {
  deployCMTATProxy,
  fixture,
  loadFixture
} = require('../../../deploymentUtils')
describe('Proxy - DocumentModule', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATProxy(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
  })
  DocumentModuleCommon()
  DocumentModuleSetDocumentEngineCommon()
})
