const { expect } = require('chai')
const { ethers, upgrades } = require('hardhat')
const { DEFAULT_ADMIN_ROLE } = require('../../utils')

describe('Proxy - Security', function () {
  let admin, attacker, proxyContract, implementationContract

  before(async function () {
    [admin, attacker] = await ethers.getSigners()

    const flag = 5
    const CMTAT_BASE = await ethers.getContractFactory('CMTAT_BASE')
    // Deploy the proxy contract
    proxyContract = await upgrades.deployProxy(CMTAT_BASE, [admin.address, 'CMTA Token', 'CMTAT', 18, 'CMTAT_ISIN', 'https://cmta.ch', 'CMTAT_info', flag], { initializer: 'initialize' })

    if (!proxyContract || !(await proxyContract.getAddress())) {
      throw new Error('proxyContract contract deployment failed')
    }
  })

  beforeEach(async function () {
    // Ensure proxyContract is defined
    if (!proxyContract) {
      throw new Error('proxyContract is undefined')
    }

    const implementationAddress = await upgrades.erc1967.getImplementationAddress((await proxyContract.getAddress()))
    implementationContract = await ethers.getContractAt('CMTAT_BASE', implementationAddress)
  })

  context('Attacker', function () {
    it('testCannotBeTakenControlByAttacker1', async function () {
      await expect(
        implementationContract.connect(attacker).initialize(attacker.address, 'CMTA Token', 'CMTAT', 18, 'CMTAT_ISIN', 'https://cmta.ch', 'CMTAT_info', 5)
      ).to.be.revertedWith('Initializable: contract is already initialized')

      await expect(implementationContract.connect(attacker).setFlag(0)
      ).to.be.revertedWith(`AccessControl: account ${attacker.address.toLowerCase()} is missing role ${DEFAULT_ADMIN_ROLE}`)
    })

    it('testCannotBeTakenControlByAttacker2', async function () {
      await expect(
        implementationContract.connect(attacker).initialize(attacker.address, 'CMTA Token', 'CMTAT', 18, 'CMTAT_ISIN', 'https://cmta.ch', 'CMTAT_info', 5)
      ).to.be.revertedWith('Initializable: contract is already initialized')

      await expect(
        implementationContract.connect(attacker).setFlag(0)
      ).to.be.revertedWith(`AccessControl: account ${attacker.address.toLowerCase()} is missing role ${DEFAULT_ADMIN_ROLE}`)
    })
  })
})
