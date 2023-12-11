const { expect } = require('chai')
const { ethers, upgrades } = require('hardhat')
const { ZERO_ADDRESS } = require('../utils')

const errorAddressZeroNotAllowed = 'AddressZeroNotAllowed'

describe('CMTAT_BASE Deployment', function () {
  it('should not allow deployment with admin set to address zero', async function () {
    const flag = 5
    const CMTAT_BASE = await ethers.getContractFactory('CMTAT_BASE')
    // Act + Assert
    await expect(
      upgrades.deployProxy(
        CMTAT_BASE,
        [ZERO_ADDRESS, 'CMTA Token', 'CMTAT', 18, 'CMTAT_ISIN', 'https://cmta.ch', 'CMTAT_info', flag],
        { initializer: 'initialize' }
      )
    ).to.be.revertedWithCustomError(CMTAT_BASE, errorAddressZeroNotAllowed)
  })
})
