const CMTAT_BEACON_FACTORY = artifacts.require(
  'CMTAT_BEACON_FACTORY')
const { should } = require('chai').should()
const {
  expectRevertCustomError
} = require('../../../openzeppelin-contracts-upgradeable/test/helpers/customError.js')
const CMTAT = artifacts.require('CMTAT_PROXY')
const { DEFAULT_ADMIN_ROLE, PAUSER_ROLE } = require('../../utils')
const { ZERO_ADDRESS } = require('../../utils')
const DECIMAL = 0
const { deployCMTATProxy, DEPLOYMENT_FLAG } = require('../../deploymentUtils')
const { upgrades } = require('hardhat')
const DEPLOYMENT_DECIMAL = 0
contract(
  'Proxy - Security Test',
  function ([_, admin, attacker, deployerAddress]) {
    beforeEach(async function () {
      this.CMTAT_PROXY = await deployCMTATProxy(_, admin, deployerAddress)
      this.FACTORY = await CMTAT_BEACON_FACTORY.new(this.CMTAT_PROXY.address, admin, admin)
    })

    context('Attacker', function () {
      // Here the argument to indicate if it is deployed with a proxy, set at false by the attacker
      it('testCannotBeDeployedByAttacker', async function () {

      })
    })

    context('Deploy CMTAT with Factory', function () {
      // Here the argument to indicate if it is deployed with a proxy, set at false by the attacker
      it('testCanDeployCMTATWithFactory', async function () {
        const cmtat = await this.FACTORY.deployCMTAT(
          _,
          admin,
          ZERO_ADDRESS,
          'CMTA Token',
          'CMTAT',
          DEPLOYMENT_DECIMAL,
          'CMTAT_ISIN',
          'https://cmta.ch',
          ZERO_ADDRESS,
          'CMTAT_info',
          DEPLOYMENT_FLAG, {
            from: admin
          })
        const CMTAT_ADDRESS = cmtat.logs[0].args[0]
        const CMTAT_TRUFFLE = await CMTAT.at(CMTAT_ADDRESS)
        await CMTAT_TRUFFLE.mint(admin, 100, {
          from: admin
        })
      })
    })
  }
)
