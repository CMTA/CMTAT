const {
  expectRevertCustomError
} = require('../../../openzeppelin-contracts-upgradeable/test/helpers/customError.js')
const { DEFAULT_ADMIN_ROLE, PAUSER_ROLE } = require('../../utils')
const { ZERO_ADDRESS } = require('../../utils')
const DECIMAL = 0
const { deployCMTATProxy, DEPLOYMENT_FLAG,
  fixture,
  loadFixture } = require('../../deploymentUtils')
const { upgrades } = require('hardhat')
describe(
  'Proxy - Security Test',
  function () {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture));
      this.flag = 5
      // Contract to deploy: CMTAT
      this.CMTAT_PROXY = await deployCMTATProxy(this._.address, this.admin.address, this.deployerAddress.address)
      const implementationContractAddress =
        await upgrades.erc1967.getImplementationAddress(
          this.CMTAT_PROXY.target
        )

      const MyContract = await ethers.getContractFactory("CMTAT_PROXY");
      this.implementationContract = MyContract.attach(
        implementationContractAddress
      )
    })

    context('Attacker', function () {
      it('testCannotBeTakenControlByAttacker', async function () {
        // Act
        await expectRevertCustomError(
          this.implementationContract.connect(this.attacker).initialize(
            this.attacker,
            ZERO_ADDRESS,
            'CMTA Token',
            'CMTAT',
            DECIMAL,
            'CMTAT_ISIN',
            'https://cmta.ch',
            ZERO_ADDRESS,
            'CMTAT_info',
            DEPLOYMENT_FLAG
          ),
          'InvalidInitialization',
          []
        )
        // act + assert
        await expectRevertCustomError(
          this.implementationContract.connect(this.attacker).pause(),
          'AccessControlUnauthorizedAccount',
          [this.attacker.address, PAUSER_ROLE]
        )
      })
    })
  }
)
