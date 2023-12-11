const { expect } = require('chai')
const { ethers, upgrades } = require('hardhat')
const { BURNER_ROLE } = require('../../utils')
const { ZERO_ADDRESS } = require('../../utils')

describe('Proxy - BurnModule', function () {
  let admin, account1, account2, cmtat

  beforeEach(async function () {
    [admin, account1, account2] = await ethers.getSigners()

    const flag = 5
    const CMTAT_BASE = await ethers.getContractFactory('CMTAT_BASE')
    cmtat = await upgrades.deployProxy(CMTAT_BASE, [admin.address, 'CMTA Token', 'CMTAT', 18, 'CMTAT_ISIN', 'https://cmta.ch', 'CMTAT_info', flag])
  })

  context('Burn', function () {
    beforeEach(async function () {
      await cmtat.connect(admin).mint(account1, 50)
      await expect(await cmtat.totalSupply()).to.equal('50')
    })

    it('testCanBeBurntByAdminWithAllowance', async function () {
      const reason = 'BURN_TEST'

      // Burn 20
      const tx1 = await cmtat.connect(admin).forceBurn(account1.address, 20, reason)
      await expect(tx1).to.emit(cmtat, 'Transfer').withArgs(account1.address, ZERO_ADDRESS, 20)
      await expect(tx1).to.emit(cmtat, 'Burn').withArgs(account1.address, 20, reason)

      await expect(await cmtat.balanceOf(account1.address)).to.equal(30)
      await expect(await cmtat.totalSupply()).to.equal(30)

      // Burn 30
      const tx2 = await cmtat.connect(admin).forceBurn(account1.address, 30, reason)
      await expect(tx2).to.emit(cmtat, 'Transfer').withArgs(account1.address, ZERO_ADDRESS, 30)
      await expect(tx2).to.emit(cmtat, 'Burn').withArgs(account1.address, 30, reason)

      await expect(await cmtat.balanceOf(account1.address)).to.equal(0)
      await expect(await cmtat.totalSupply()).to.equal(0)
    })

    it('testCanBeBurntByBurnerRole', async function () {
      const reason = 'BURN_TEST'

      // Grant the BURNER_ROLE to account2
      await cmtat.connect(admin).grantRole(BURNER_ROLE, account2.address)

      // Burn 20 tokens from account1 by account2
      const tx = await cmtat.connect(account2).forceBurn(account1.address, 20, reason)
      await expect(tx).to.emit(cmtat, 'Transfer').withArgs(account1.address, ZERO_ADDRESS, 20)
      await expect(tx).to.emit(cmtat, 'Burn').withArgs(account1.address, 20, reason)

      // Check balances and total supply
      await expect(await cmtat.balanceOf(account1.address)).to.equal(30)
      await expect(await cmtat.totalSupply()).to.equal(30)
    })

    it('testCannotBeBurntIfBalanceExceeds', async function () {
      // Act
      await expect(cmtat.connect(admin).forceBurn(account1, 200, '')).to.be.revertedWith(
        'ERC20: burn amount exceeds balance'
      )
    })

    it('testCannotBeBurntWithoutBurnerRole', async function () {
      // Act
      await expect(cmtat.connect(account2).forceBurn(account1, 20, '')).to.be.revertedWith(
        'AccessControl: account ' +
              account2.address.toLowerCase() +
              ' is missing role ' +
              BURNER_ROLE
      )
    })
  })
})
