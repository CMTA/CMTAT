const AuthorizationModuleCommon = require('../../../common/AuthorizationModule/AuthorizationModuleCommon')
const AuthorizationModuleSetAuthorizationEngineCommon = require('../../../common/AuthorizationModule/AuthorizationModuleSetAuthorizationEngineCommon')
const { deployCMTATProxy } = require('../../../deploymentUtils')
const AuthorizationEngineMock = artifacts.require('AuthorizationEngineMock')
contract(
  'Proxy - AuthorizationModule',
  function ([_, admin, address1, address2, deployerAddress]) {
    beforeEach(async function () {
      this.cmtat = await deployCMTATProxy(_, admin, deployerAddress)
      this.authorizationEngineMock = await AuthorizationEngineMock.new({
        from: admin
      })
    })

    AuthorizationModuleCommon(admin, address1, address2)
    AuthorizationModuleSetAuthorizationEngineCommon(admin, address1)
  }
)
