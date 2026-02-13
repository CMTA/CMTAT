const FixDescriptorModuleSetFixDescriptorEngineCommon = require('../../../common/FixDescriptorModule/FixDescriptorModuleSetFixDescriptorEngineCommon')
const FixDescriptorModuleCommon = require('../../../common/FixDescriptorModule/FixDescriptorModuleCommon')
const {
  deployCMTATStandalone,
  fixture,
  loadFixture
} = require('../../../deploymentUtils')
describe('Standard - FixDescriptorModule', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.cmtat = await deployCMTATStandalone(
      this._.address,
      this.admin.address,
      this.deployerAddress.address
    )
  })
  FixDescriptorModuleCommon()
  FixDescriptorModuleSetFixDescriptorEngineCommon()
})
