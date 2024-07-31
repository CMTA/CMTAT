const AuthorizationModuleCommon = require('../../../common/AuthorizationModule/AuthorizationModuleCommon')
const AuthorizationModuleSetAuthorizationEngineCommon = require('../../../common/AuthorizationModule/AuthorizationModuleSetAuthorizationEngineCommon')
const { deployCMTATProxy, fixture, loadFixture } = require('../../../deploymentUtils')

describe(
  'Proxy - AuthorizationModule',
  function () {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture));
      this.cmtat = await deployCMTATProxy(this._.address, this.admin.address, this.deployerAddress.address)
      this.authorizationEngineMock = await ethers.deployContract("AuthorizationEngineMock")
    })

    AuthorizationModuleCommon()
    AuthorizationModuleSetAuthorizationEngineCommon()
  }
)
