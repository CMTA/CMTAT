const AuthorizationModuleSetAuthorizationEngineCommon = require('../../../common/AuthorizationModule/AuthorizationModuleSetAuthorizationEngineCommon')
const {
  deployCMTATStandaloneWithParameter,
  fixture,
  loadFixture
} = require('../../../deploymentUtils')

const { ZERO_ADDRESS } = require('../../../utils')

describe('Proxy - AuthorizationModule - Constructor', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.authorizationEngineMock = await ethers.deployContract(
      'AuthorizationEngineMock'
    )
    const DECIMAL = 0
    this.definedAtDeployment = true
    this.cmtat = await deployCMTATStandaloneWithParameter(
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
