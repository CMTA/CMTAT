const { expect } = require('chai');
const {
  expectRevertCustomError
} = require('../../../../openzeppelin-contracts-upgradeable/test/helpers/customError.js')
const { ZERO_ADDRESS, CMTAT_DEPLOYER_ROLE } = require('../../../utils.js')
const {
  DEPLOYMENT_FLAG,
  deployCMTATProxyImplementation,
    fixture, loadFixture 
} = require('../../../deploymentUtils.js')
const { ethers } = require('hardhat')
const DEPLOYMENT_DECIMAL = 0
describe(
  'Deploy TP with Factory - Salt',
  function () {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture));
      this.CMTAT_PROXY_IMPL = await deployCMTATProxyImplementation(
        this._.address,
        this.deployerAddress.address
      )
      this.FACTORY =  await ethers.deployContract('CMTAT_TP_FACTORY',[
        this.CMTAT_PROXY_IMPL.target,
        this.admin,
        true
      ])
      this.CMTATArg = [
        this.admin,
        ['CMTA Token',
        'CMTAT',
        DEPLOYMENT_DECIMAL],
        ['CMTAT_ISIN',
        'https://cmta.ch',
        'CMTAT_info'],
        [ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS]
      ]
    })

    context('FactoryDeployment', function () {
      it('testCanReturnTheRightImplementation', async function () {
        // Act + Assert
        expect(await this.FACTORY.logic()).to.equal(
          this.CMTAT_PROXY_IMPL.target
        )
      })
    })

    context('Deploy CMTAT with Factory', function () {
      it('testCannotBeDeployedByAttacker', async function () {
        // Act
        await expectRevertCustomError(
          this.FACTORY.connect(this.attacker).deployCMTAT(
            ethers.encodeBytes32String('test'),
            this.admin,
            this.CMTATArg
          ),
          'AccessControlUnauthorizedAccount',
          [this.attacker.address, CMTAT_DEPLOYER_ROLE]
        )
      })
      it('testCanDeployCMTATWithFactory', async function () {
        // Act
        this.logs = await this.FACTORY.connect(this.admin).deployCMTAT(
          ethers.encodeBytes32String('test'),
          this.admin,
          this.CMTATArg,
        )
        // Assert
        // Check  Id
        const receipt = await this.logs.wait();
        const filter = this.FACTORY.filters.CMTAT;
        let events = await this.FACTORY.queryFilter(filter, -1);
        let args = events[0].args;
        expect(args[1]).to.equal(0)
        const CMTAT_ADDRESS = args[0];
        const MyContract = await ethers.getContractFactory("CMTAT_PROXY");
        const CMTAT_PROXY = MyContract.attach(
          CMTAT_ADDRESS
        )
        // Check address with ID
        expect((await this.FACTORY.CMTATProxyAddress(0))).to.equal(CMTAT_ADDRESS)
        await CMTAT_PROXY.connect(this.admin).mint(this.admin, 100)
        // Second deployment
        this.logs = await this.FACTORY.connect(this.admin).deployCMTAT(
          ethers.encodeBytes32String('test2'),
          this.admin,
          this.CMTATArg,
        )
        // Check Id increment
        events = await this.FACTORY.queryFilter(filter, -1);
        args = events[0].args;
        expect(args[1]).to.equal(1)
        // Revert
        await expectRevertCustomError(this.FACTORY.connect(this.admin).deployCMTAT(
          ethers.encodeBytes32String('test'),
          this.admin,
          this.CMTATArg,
        ),
        'CMTAT_Factory_SaltAlreadyUsed',
        [])
      })
      it('testCannotDeployCMTATWithFactoryWithSaltAlreadyUsed', async function () {
        // Arrange
        await this.FACTORY.connect(this.admin).deployCMTAT(
          ethers.encodeBytes32String('test'),
          this.admin,
          this.CMTATArg
        )
       
        // Act with Revert
        await expectRevertCustomError(this.FACTORY.connect(this.admin).deployCMTAT(
          ethers.encodeBytes32String('test'),
          this.admin,
          this.CMTATArg
        ),
        'CMTAT_Factory_SaltAlreadyUsed',
        [])
      })
    })
  }
)
