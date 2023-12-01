const { ethers, upgrades } = require('hardhat')

describe('Proxy - ERC20BaseModule', function () {
  let admin, account1, account2, account3, cmtat

  beforeEach(async function () {
    [admin, account1, account2, account3] = await ethers.getSigners()

    const flag = 5
    const CMTAT_BASE = await ethers.getContractFactory('CMTAT_BASE')
    cmtat = await upgrades.deployProxy(CMTAT_BASE, [admin.address, 'CMTA Token', 'CMTAT', 18, 'CMTAT_ISIN', 'https://cmta.ch', 'CMTAT_info', flag])
  })

  context('Token structure', function () {
    it('testHasTheDefinedName', async function () {
      // Act + Assert
      await expect(await cmtat.name()).to.equal('CMTA Token')
    })
    it('testHasTheDefinedSymbol', async function () {
      // Act + Assert
      await expect(await cmtat.symbol()).to.equal('CMTAT')
    })
    it('testHasTheDefinedDecimals', async function () {
      // Act + Assert
      await expect(await cmtat.decimals()).to.equal('18')
    })
  })

  context('Allowance', function () {
    // ACCOUNT1 -> ACCOUNT
    it('testApproveAllowance', async function () {
      // Arrange - Assert
      await expect(await cmtat.allowance(account1.address, account3.address)).to.equal(0)
      // Act
      const tx = await cmtat.connect(account1).approve(account3.address, 20)
      // Assert
      await expect(await cmtat.allowance(account1.address, account3.address)).to.equal(20)
      // emits an Approval event
      await expect(tx).to.emit(cmtat, 'Approval').withArgs(account1.address, account3.address, 20)
    })

    // ACCOUNT1 -> ACCOUNT3
    it('testIncreaseAllowance', async function () {
      // Arrange
      await expect(await cmtat.allowance(account1.address, account3.address)).to.equal(0)
      await cmtat.connect(account1).approve(account3.address, 20)
      // Arrange - Assert
      await expect(await cmtat.allowance(account1.address, account3.address)).to.equal(20)
      // Act
      const tx = await cmtat.connect(account1).increaseAllowance(account3.address, 10)
      // Assert
      await expect(await cmtat.allowance(account1.address, account3.address)).to.equal(30)
      // emits an Approval event
      await expect(tx).to.emit(cmtat, 'Approval').withArgs(account1.address, account3.address, 30)
    })

    // ACCOUNT1 -> ACCOUNT3
    it('testDecreaseAllowance', async function () {
      // Arrange
      await expect(await cmtat.allowance(account1.address, account3.address)).to.equal(0)
      await cmtat.connect(account1).approve(account3.address, 20)
      // Arrange - Assert
      await expect(await cmtat.allowance(account1.address, account3.address)).to.equal(20)
      // Act
      const tx = await cmtat.connect(account1).decreaseAllowance(account3.address, 10)
      // Assert
      await expect(await cmtat.allowance(account1.address, account3.address)).to.equal(10)
      // emits an Approval event
      await expect(tx).to.emit(cmtat, 'Approval').withArgs(account1.address, account3.address, 10)
    })

    // ACCOUNT1 -> ACCOUNT3
    it('testRedefinedAllowanceWithApprove', async function () {
      // Arrange
      await expect(await cmtat.allowance(account1.address, account3.address)).to.equal(0)
      await cmtat.connect(account1).approve(account3.address, 20)
      // Arrange - Assert
      await expect(await cmtat.allowance(account1.address, account3.address)).to.equal(20)
      // Act
      const tx = await cmtat.connect(account1).approve(account3.address, 50)
      // Assert
      await expect(await cmtat.allowance(account1.address, account3.address)).to.equal(50)
      // emits an Approval event
      await expect(tx).to.emit(cmtat, 'Approval').withArgs(account1.address, account3.address, 50)
    })
  })

  context('Transfer', function () {
    beforeEach(async function () {
      await cmtat.connect(admin).mint(account1.address, 31)
      await cmtat.connect(admin).mint(account2.address, 32)
      await cmtat.connect(admin).mint(account3.address, 33)
    })

    it('testTransferFromOneAccountToAnother', async function () {
      // Act
      const tx = await cmtat.connect(account1).transfer(account2.address, 11)
      // Assert
      await expect(await cmtat.balanceOf(account1.address)).to.equal(20)
      await expect(await cmtat.balanceOf(account2.address)).to.equal(43)
      await expect(await cmtat.balanceOf(account3.address)).to.equal(33)
      await expect(await cmtat.totalSupply()).to.equal(96)
      // emits a Transfer event
      await expect(tx).to.emit(cmtat, 'Transfer').withArgs(account1.address, account2.address, 11)
    })

    // ACCOUNT1 -> ACCOUNT2
    it('testCannotTransferMoreTokensThanOwn', async function () {
      // Act & Assert
      await expect(
        cmtat.connect(account1).transfer(account2.address, 50)
      ).to.be.revertedWith('ERC20: transfer amount exceeds balance')
    })

    // allows account3 to transfer tokens from account1 to account2 with the right allowance
    // ACCOUNT3 : ACCOUNT1 -> ACCOUNT2
    it('testTransferByAnotherAccountWithTheRightAllowance', async function () {
      // Arrange
      await cmtat.connect(account1).approve(account3.address, 20)
      // Act
      const tx = await cmtat.connect(account3).transferFrom(account1.address, account2.address, 11)
      // Assert
      await expect(await cmtat.balanceOf(account1.address)).to.equal(20)
      await expect(await cmtat.balanceOf(account2.address)).to.equal(43)
      await expect(await cmtat.balanceOf(account3.address)).to.equal(33)
      await expect(await cmtat.totalSupply()).to.equal(96)
      // emits a Transfer event
      await expect(tx).to.emit(cmtat, 'Transfer').withArgs(account1.address, account2.address, 11)
    })

    // reverts if account3 transfers more tokens than the allowance from account1 to account2
    it('testCannotTransferByAnotherAccountWithInsufficientAllowance', async function () {
      // Arrange
      await cmtat.connect(account1).approve(account3.address, 20)
      // Act & Assert
      await expect(
        cmtat.connect(account3).transferFrom(account1.address, account2.address, 31)
      ).to.be.revertedWith('ERC20: insufficient allowance')
    })

    // reverts if account3 transfers more tokens than account1 owns from account1 to account2
    it('testCannotTransferByAnotherAccountWithInsufficientBalance', async function () {
      // Arrange
      await cmtat.connect(account1).approve(account3.address, 1000)
      // Act & Assert
      await expect(
        cmtat.connect(account3).transferFrom(account1.address, account2.address, 50)
      ).to.be.revertedWith('ERC20: transfer amount exceeds balance')
    })
  })
})
