const { expect } = require('chai')
const ValidationModuleProxyCommon = require('../common/ValidationModule/proxy/ValidationModuleProxyCommon')
const SnapshotModuleProxyCommon = require('../common/SnapshotModuleCommon/proxy/SnapshotModuleProxyCommon')
describe('CMTAT ERC1363 - Proxy - ValidationModule', function () {
  beforeEach(async function () {
    
  })
  ValidationModuleProxyCommon()
  SnapshotModuleProxyCommon()
})


