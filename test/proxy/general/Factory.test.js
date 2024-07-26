const { ethers, upgrades } = require('hardhat')
const { expect } = require('chai')
const { CMTAT_DEPLOYER_ROLE, MINTER_ROLE } = require('../../utils.js')

describe('Proxy - Factory', function () {
  let admin, attacker, minter, holder, cmtatImplementation, cmtatFactory, deployedCMTAT, deployedFactory, proxyAdminContract, CMTATData

  beforeEach(async function () {
    [admin, attacker, minter, holder] = await ethers.getSigners()

    cmtatImplementation = await ethers.getContractFactory('CMTAT_BASE')
    cmtatFactory = await ethers.getContractFactory('CMTAT_FACTORY')

    deployedCMTAT = await cmtatImplementation.deploy()
    deployedFactory = await cmtatFactory.deploy(
      deployedCMTAT,
      admin
    )

    CMTATData = [
      admin.address,
      'CMTA Token',
      'CMTAT',
      18,
      'CMTAT_ISIN',
      'https://cmta.ch',
      'CMTAT_info',
      5
    ]

    proxyAdminContract = await upgrades.deployProxyAdmin(admin)
  })

  context('Deploy CMTAT from Factory', function () {
    it('testCannotBeDeployedByAttacker', async function () {
      await expect(
        deployedFactory.connect(attacker).deployCMTAT(
          ethers.encodeBytes32String('test'),
          admin.address,
          CMTATData
        )
      ).to.be.revertedWith('AccessControl: account ' + attacker.address.toLowerCase() + ' is missing role ' + CMTAT_DEPLOYER_ROLE)
    })

    it('testCannotDeployCMTATWithFactoryWithSaltAlreadyUsed', async function () {
      const salt = ethers.encodeBytes32String('test')

      await deployedFactory.connect(admin).deployCMTAT(
        salt,
        admin,
        CMTATData
      )

      await expect(
        deployedFactory.connect(admin).deployCMTAT(
          salt,
          admin,
          CMTATData
        )
      ).to.be.revertedWithCustomError(
        cmtatFactory,
        'CMTAT_Factory_SaltAlreadyUsed'
      )
    })

    it('testCanDeployCMTATsWithFactory', async function () {
      const salt0 = ethers.encodeBytes32String('test0')
      const salt1 = ethers.encodeBytes32String('test1')

      let computedCMTATAddress = await deployedFactory.connect(admin).computeProxyAddress(
        salt0,
        proxyAdminContract,
        CMTATData
      )
      await deployedFactory.connect(admin).deployCMTAT(
        salt0,
        proxyAdminContract,
        CMTATData
      )

      const proxy0 = await deployedFactory.connect(admin).cmtats(0)
      expect(proxy0).to.be.equal(computedCMTATAddress)

      const deployedCMTATContract = cmtatImplementation.attach(computedCMTATAddress)
      expect(await deployedCMTATContract.connect(admin).decimals()).to.be.equal(18)
      await deployedCMTATContract.connect(admin).grantRole(MINTER_ROLE, minter)
      await deployedCMTATContract.connect(minter).mint(holder, 10)
      expect(await deployedCMTATContract.connect(holder).balanceOf(holder)).to.be.equal(10)

      computedCMTATAddress = await deployedFactory.connect(admin).computeProxyAddress(
        salt1,
        proxyAdminContract,
        CMTATData
      )
      await deployedFactory.connect(admin).deployCMTAT(
        salt1,
        proxyAdminContract,
        CMTATData
      )

      const proxy1 = await deployedFactory.connect(admin).cmtats(1)
      expect(proxy1).to.be.equal(computedCMTATAddress)
    })

    it('testEmitCMTATDeployedEvent', async function () {
      await expect(
        await deployedFactory.connect(admin).deployCMTAT(
          ethers.encodeBytes32String('test'),
          admin,
          CMTATData
        )
      ).to.emit(
        await deployedFactory.connect(admin), 'CMTATdeployed'
      ).withArgs(
        await deployedFactory.connect(admin).cmtats(0), 0
      )
    })
  })
})
