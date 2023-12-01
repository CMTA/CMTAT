const { expect } = require('chai')
const { ethers, upgrades } = require('hardhat')
const { PAUSER_ROLE } = require('../../utils')

describe('Proxy - PauseModule', function () {
  let admin, account1, account2, account3, cmtat

  beforeEach(async function () {
    [admin, account1, account2, account3] = await ethers.getSigners()

    const flag = 5
    const CMTAT_BASE = await ethers.getContractFactory('CMTAT_BASE')
    cmtat = await upgrades.deployProxy(CMTAT_BASE, [admin.address, 'CMTA Token', 'CMTAT', 18, 'CMTAT_ISIN', 'https://cmta.ch', 'CMTAT_info', flag], { initializer: 'initialize' })
    // Mint tokens to test the transfer
    await cmtat.connect(admin).mint(account1.address, 20)
  })

  context('Pause', function () {
    /**
     * The admin is assigned the PAUSER role when the contract is deployed
     */
    it('testCanBePausedByAdmin', async function () {
      // Act
      const tx = await cmtat.connect(admin).pause()
      // Assert
      // emits a Paused event
      await expect(tx).to.emit(cmtat, 'Paused').withArgs(admin.address)
      // Transfer is reverted
      await expect(
        cmtat.connect(account1).transfer(account2.address, 10)
      ).to.be.reverted
    })

    it('testCanBePausedByPauserRole', async function () {
      // Arrange
      await cmtat.connect(admin).grantRole(PAUSER_ROLE, account1.address)
      // Act
      const tx = await cmtat.connect(account1).pause()
      // Assert
      // emits a Paused event
      await expect(tx).to.emit(cmtat, 'Paused').withArgs(account1.address)
      // Transfer is reverted
      await expect(
        cmtat.connect(account1).transfer(account2.address, 10)
      ).to.be.reverted
    })

    it('testCannotBePausedByNonPauser', async function () {
      // Act
      await expect(
        cmtat.connect(account1).pause()
      ).to.be.revertedWith(`AccessControl: account ${account1.address.toLowerCase()} is missing role ${PAUSER_ROLE}`)
    })

    it('testCanBeUnpausedByAdmin', async function () {
      // Arrange
      await cmtat.connect(admin).pause()
      // Act
      const tx = await cmtat.connect(admin).unpause()
      // Assert
      // emits a Unpaused event
      await expect(tx).to.emit(cmtat, 'Unpaused').withArgs(admin.address)
      // Transfer works
      await cmtat.connect(account1).transfer(account2.address, 10)
    })

    it('testCanBeUnpausedByANewPauser', async function () {
      // Arrange
      await cmtat.connect(admin).pause()
      await cmtat.connect(admin).grantRole(PAUSER_ROLE, account1.address)
      // Act
      const tx = await cmtat.connect(account1).unpause()
      // Assert
      // emits a Unpaused event
      await expect(tx).to.emit(cmtat, 'Unpaused').withArgs(account1.address)
      // Transfer works
      await cmtat.connect(account1).transfer(account2.address, 10)
    })

    it('testCannotBeUnpausedByNonPauser', async function () {
      // Arrange
      await cmtat.connect(admin).pause()
      // Act
      await expect(
        cmtat.connect(account1).unpause()
      ).to.be.revertedWith(`AccessControl: account ${account1.address.toLowerCase()} is missing role ${PAUSER_ROLE}`)
    })

    // reverts if account1 transfers tokens to account2 when paused
    it('testCannotTransferTokenWhenPaused_A', async function () {
      // Act
      await cmtat.connect(admin).pause()
      // Assert
      await expect(
        cmtat.connect(account1).transfer(account2.address, 10)
      ).to.be.reverted
    })

    // reverts if account3 transfers tokens from account1 to account2 when paused
    it('testCannotTransferTokenWhenPaused_B', async function () {
      // Arrange
      await cmtat.connect(account1).approve(account3.address, 20)
      // Act
      await cmtat.connect(admin).pause()
      // Assert
      await expect(
        cmtat.connect(account3).transferFrom(account1.address, account2.address, 10)
      ).to.be.reverted
    })
  })
})
