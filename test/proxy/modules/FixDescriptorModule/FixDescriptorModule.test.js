const FixDescriptorModuleSetFixDescriptorEngineCommon = require('../../../common/FixDescriptorModule/FixDescriptorModuleSetFixDescriptorEngineCommon')
const FixDescriptorModuleCommon = require('../../../common/FixDescriptorModule/FixDescriptorModuleCommon')
const {
  deployCMTATProxy,
  fixture,
  loadFixture
} = require('../../../deploymentUtils')
describe('Proxy - FixDescriptorModule', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATProxy(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
  })
  FixDescriptorModuleCommon()
  FixDescriptorModuleSetFixDescriptorEngineCommon()
})
