const { expect } = require('chai')
const { ethers, upgrades } = require('hardhat')

describe('Proxy - Upgrade', function () {
  let admin, address1, CMTAT_BASE, upgradeableCMTATV2Instance

  before(async function () {
    [admin, address1] = await ethers.getSigners()
  })

  it('testKeepStorageForTokens', async function () {
    const flag = 5

    const CMTAT1 = await ethers.getContractFactory('CMTAT_BASE')
    CMTAT_BASE = await upgrades.deployProxy(CMTAT1, [admin.address, 'CMTA Token', 'CMTAT', 18, 'CMTAT_ISIN', 'https://cmta.ch', 'CMTAT_info', flag], { initializer: 'initialize' })

    await expect(await CMTAT_BASE.balanceOf(admin.address)).to.equal(0n)

    // Issue 20 and check balances and total supply
    await CMTAT_BASE.connect(admin).mint(address1.address, 20n)
    await expect(await CMTAT_BASE.balanceOf(address1.address)).to.equal(20n)
    await expect(await CMTAT_BASE.totalSupply()).to.equal(20n)

    const CMTAT2 = await ethers.getContractFactory('CMTAT_BASE') // Assuming V2 has the same name
    upgradeableCMTATV2Instance = await upgrades.upgradeProxy((await CMTAT_BASE.getAddress()), CMTAT2)

    // Keep the storage
    await expect(await upgradeableCMTATV2Instance.balanceOf(address1.address)).to.equal(20n)

    // Issue 20 more and check balances and total supply
    await upgradeableCMTATV2Instance.connect(admin).mint(address1.address, 20n)
    await expect(await upgradeableCMTATV2Instance.balanceOf(address1.address)).to.equal(40n)
    await expect(await upgradeableCMTATV2Instance.totalSupply()).to.equal(40n)
  })
})
