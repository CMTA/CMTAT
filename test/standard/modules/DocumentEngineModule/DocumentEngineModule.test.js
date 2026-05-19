const DocumentModuleSetDocumentEngineCommon = require('../../../common/DocumentModule/DocumentModuleSetDocumentEngineCommon')
const DocumentModuleCommon = require('../../../common/DocumentModule/DocumentModuleCommon')
const { fixture, loadFixture } = require('../../../deploymentUtils')
const { ethers, upgrades } = require('hardhat')
const { ZERO_ADDRESS } = require('../../../utils')

describe('Standard - DocumentEngineModule', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    const factory = await ethers.getContractFactory('CMTATDocumentEngineModuleMock')
    this.cmtat = await upgrades.deployProxy(
      factory,
      [this.admin.address, ['CMTA Token', 'CMTAT', 0], ZERO_ADDRESS],
      {
        initializer: 'initialize',
        from: this.deployerAddress.address,
        unsafeAllow: ['missing-initializer']
      }
    )
  })

  DocumentModuleCommon()
  DocumentModuleSetDocumentEngineCommon()
})
