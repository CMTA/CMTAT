const { expect } = require('chai')
const ValidationModuleProxyCommon = require('../../common/ValidationModule/proxy/ValidationModuleProxyCommon')
const SnapshotModuleProxyCommon = require('../../common/SnapshotModuleCommon/proxy/SnapshotModuleProxyCommon')
const {
  deployCMTATERC1363Proxy,
  fixture,
  loadFixture
} = require('../../deploymentUtils')
describe('CMTAT ERC1363 - Proxy - ValidationModule', function () {
  beforeEach(async function () {
    this.CMTATERC1363 = true
  })
  ValidationModuleProxyCommon()
  SnapshotModuleProxyCommon()
})
