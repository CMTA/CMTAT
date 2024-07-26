const { ethers } = require('hardhat')
const { expect } = require('chai')
const { ZERO_ADDRESS, CMTAT_DEPLOYER_ROLE } = require('./../utils.js')

describe('CMTAT_FACTORY Deployment', function () {
  let admin, cmtatImplementation, cmtatFactory, deployedCMTAT

  before(async function () {
    [admin] = await ethers.getSigners()

    cmtatImplementation = await ethers.getContractFactory('CMTAT_BASE')
    cmtatFactory = await ethers.getContractFactory('CMTAT_FACTORY')
  })

  beforeEach(async function () {
    deployedCMTAT = await cmtatImplementation.deploy()
  })

  it('testCannotDeployIfImplementationIsZero', async function () {
    await expect(
      cmtatFactory.deploy(ZERO_ADDRESS, admin)
    ).to.be.revertedWithCustomError(
      cmtatFactory,
      'CMTAT_Factory_AddressZeroNotAllowedForLogicContract'
    )
  })

  it('testCannotDeployIfFactoryAdminIsZero', async function () {
    await expect(
      cmtatFactory.deploy(deployedCMTAT, ZERO_ADDRESS)
    ).to.be.revertedWithCustomError(
      cmtatFactory,
      'CMTAT_Factory_AddressZeroNotAllowedForFactoryAdmin'
    )
  })

  context('After succesful deploy', function () {
    let deployedFactory

    beforeEach(async function () {
      deployedFactory = await cmtatFactory.deploy(
        deployedCMTAT,
        admin
      )
    })

    it('testCanReturnTheRightImplementation', async function () {
      expect(
        await deployedFactory.connect(admin).logic()
      ).to.be.equal(await deployedCMTAT.getAddress())
    })

    it('testCanReturnDeployerRole', async function () {
      expect(
        await deployedFactory.connect(admin).CMTAT_DEPLOYER_ROLE()
      ).to.be.equal(CMTAT_DEPLOYER_ROLE)
    })
  })
})
