const { expect } = require('chai')
const { CMTAT_DEPLOYER_ROLE } = require('../../../utils.js')
const { ZERO_ADDRESS } = require('../../../utils.js')
const {
  deployCMTATProxyImplementation,
  fixture,
  loadFixture
} = require('../../../deploymentUtils.js')
const DEPLOYMENT_DECIMAL = 0
describe('Deploy Beacon with Factory', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.CMTAT_PROXY_IMPL = await deployCMTATProxyImplementation(
      this.deployerAddress.address,
      this._.address
    )
    this.FACTORY = await ethers.deployContract('CMTAT_BEACON_FACTORY', [
      this.CMTAT_PROXY_IMPL.target,
      this.admin,
      this.admin,
      false
    ])
    this.CMTATArg = [
      this.admin,
      ['CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL],
      ['CMTAT_ISIN', 'https://cmta.ch', 'CMTAT_info'],
      [ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS]
    ]
  })

  context('FactoryDeployment', function () {
    it('testCanReturnTheRightImplementation', async function () {
      // Act + Assert
      expect(await this.FACTORY.implementation()).to.equal(
        this.CMTAT_PROXY_IMPL.target
      )
    })
  })

  context('Deploy CMTAT with Factory', function () {
    it('testCannotBeDeployedByAttacker', async function () {
      // Act
      await expect(
        this.FACTORY.connect(this.attacker).deployCMTAT(
          ethers.encodeBytes32String('test'),
          this.CMTATArg
        )
      )
        .to.be.revertedWithCustomError(
          this.FACTORY,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.attacker.address, CMTAT_DEPLOYER_ROLE)
    })
    it('testCanDeployCMTATWithFactory', async function () {
      let computedCMTATAddress = await this.FACTORY.computedProxyAddress(
        // 0x0 => id counter 0
        ethers.keccak256(ethers.solidityPacked(['uint256'], [0x0])),
        this.CMTATArg
      )
      // Act
      this.logs = await this.FACTORY.connect(this.admin).deployCMTAT(
        ethers.encodeBytes32String('test'),
        this.CMTATArg
      )

      // https://github.com/ethers-io/ethers.js/discussions/4484#discussioncomment-9890653
      const receipt = await this.logs.wait()
      const filter = this.FACTORY.filters.CMTAT
      let events = await this.FACTORY.queryFilter(filter, -1)
      let args = events[0].args
      // Check Id increment
      expect(args[1]).to.equal(0)
      // Assert
      let CMTAT_ADDRESS = args[0]
      // Check address with ID
      expect(await this.FACTORY.CMTATProxyAddress(0)).to.equal(CMTAT_ADDRESS)
      expect(await this.FACTORY.CMTATProxyAddress(0)).to.equal(
        computedCMTATAddress
      )
      const MyContract = await ethers.getContractFactory('CMTAT_PROXY')
      const CMTAT_PROXY = MyContract.attach(CMTAT_ADDRESS)
      // Act + Assert
      await CMTAT_PROXY.connect(this.admin).mint(this.admin, 100)
      // Deploy second contract
      this.logs = await this.FACTORY.connect(this.admin).deployCMTAT(
        ethers.encodeBytes32String('test'),
        this.CMTATArg
      )
      // Check Id increment
      events = await this.FACTORY.queryFilter(filter, -1)
      args = events[0].args
      expect(args[1]).to.equal(1)

      // Check address
      computedCMTATAddress = await this.FACTORY.computedProxyAddress(
        ethers.keccak256(ethers.solidityPacked(['uint256'], [0x1])),
        this.CMTATArg
      )
      CMTAT_ADDRESS = args[0]
      expect(await this.FACTORY.CMTATProxyAddress(1)).to.equal(CMTAT_ADDRESS)
      expect(await this.FACTORY.CMTATProxyAddress(1)).to.equal(
        computedCMTATAddress
      )
    })
  })
})
