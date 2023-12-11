const { expect } = require('chai')
const { ethers, upgrades } = require('hardhat')
const { MINTER_ROLE } = require('../../utils')
const { ZERO_ADDRESS } = require('../../utils')

describe('Proxy - MintModule', function () {
  let admin, account1, account2, cmtat

  beforeEach(async function () {
    [admin, account1, account2] = await ethers.getSigners()

    const flag = 5
    const CMTAT_BASE = await ethers.getContractFactory('CMTAT_BASE')
    cmtat = await upgrades.deployProxy(CMTAT_BASE, [admin.address, 'CMTA Token', 'CMTAT', 18, 'CMTAT_ISIN', 'https://cmta.ch', 'CMTAT_info', flag], { initializer: 'initialize' })
  })

  context('Minting', function () {
    /**
     * The admin is assigned the MINTER role when the contract is deployed
     */
    it('testCanBeMintedByAdmin', async function () {
      // Arrange - Assert
      await expect(await cmtat.balanceOf(admin.address)).to.equal(0)

      // Act
      // Issue 20 and check balances and total supply
      const tx1 = await cmtat.connect(admin).mint(account1.address, 20)

      // Assert
      await expect(await cmtat.balanceOf(account1.address)).to.equal(20)
      await expect(await cmtat.totalSupply()).to.equal(20)

      // Assert event
      // emits a Transfer event
      await expect(tx1).to.emit(cmtat, 'Transfer').withArgs(ZERO_ADDRESS, account1.address, 20)

      // Act
      // Issue 50 and check intermediate balances and total supply
      const tx2 = await cmtat.connect(admin).mint(account2.address, 50)

      // Assert
      await expect(await cmtat.balanceOf(account2.address)).to.equal(50)
      await expect(await cmtat.totalSupply()).to.equal(70)

      // Assert event
      // emits a Transfer event
      await expect(tx2).to.emit(cmtat, 'Transfer').withArgs(ZERO_ADDRESS, account2.address, 50)
    })

    it('testCanBeMintedByANewMinter', async function () {
      // Arrange
      const MINTER_ROLE = await cmtat.MINTER_ROLE()
      await cmtat.connect(admin).grantRole(MINTER_ROLE, account1.address)

      // Arrange - Assert
      await expect(await cmtat.balanceOf(admin.address)).to.equal(0)

      // Act
      // Issue 20
      const tx1 = await cmtat.connect(account1).mint(account1.address, 20)

      // Assert
      await expect(await cmtat.balanceOf(account1.address)).to.equal(20)
      await expect(await cmtat.totalSupply()).to.equal(20)

      // Assert event
      // emits a Transfer event
      await expect(tx1).to.emit(cmtat, 'Transfer').withArgs(ZERO_ADDRESS, account1.address, 20)
    })

    // reverts when issuing by a non-minter
    it('testCannotIssuingByNonMinter', async function () {
      await expect(
        cmtat.connect(account2).mint(account1.address, 20)
      ).to.be.revertedWith(`AccessControl: account ${account2.address.toLowerCase()} is missing role ${MINTER_ROLE}`)
    })
  })
})
