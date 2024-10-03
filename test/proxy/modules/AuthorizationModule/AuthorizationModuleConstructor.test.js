const AuthorizationModuleSetAuthorizationEngineCommon = require('../../../common/AuthorizationModule/AuthorizationModuleSetAuthorizationEngineCommon')
const {
  deployCMTATProxyWithParameter,
  fixture,
  loadFixture
} = require('../../../deploymentUtils')
const { ZERO_ADDRESS } = require('../../../utils')
describe('Proxy - AuthorizationModule', function () {
  beforeEach(async function () {
    const DECIMAL = 0
    Object.assign(this, await loadFixture(fixture))
    this.authorizationEngineMock = await ethers.deployContract(
      'AuthorizationEngineMock'
    )
    this.definedAtDeployment = true
    this.cmtat = await deployCMTATProxyWithParameter(
      this.deployerAddress.address,
      this._.address,
      this.admin.address,
      'CMTA Token',
      'CMTAT',
      DECIMAL,
      'CMTAT_ISIN',
      'https://cmta.ch',
      'CMTAT_info',
      [
        ZERO_ADDRESS,
        ZERO_ADDRESS,
        this.authorizationEngineMock.target,
        ZERO_ADDRESS
      ]
    )
  })

  AuthorizationModuleSetAuthorizationEngineCommon()
})
