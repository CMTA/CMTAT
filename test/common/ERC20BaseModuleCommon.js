const { expect } = require('chai')
const { ERC20ENFORCER_ROLE, DEFAULT_ADMIN_ROLE } = require('../utils')
const REASON_STRING = 'Bad guy'
const REASON_EVENT = ethers.toUtf8Bytes(REASON_STRING)
const REASON = ethers.Typed.bytes(REASON_EVENT)
const REASON_EMPTY = ethers.Typed.bytes(ethers.toUtf8Bytes(''))
function ERC20BaseModuleCommon () {
  context('Token structure', function () {
    it('testHasTheDefinedName', async function () {
      // Act + Assert
      expect(await this.cmtat.name()).to.equal('CMTA Token')
    })
    it('testHasTheDefinedSymbol', async function () {
      // Act + Assert
      expect(await this.cmtat.symbol()).to.equal('CMTAT')
    })
    it('testDecimalsEqual0', async function () {
      // Act + Assert
      expect(await this.cmtat.decimals()).to.equal('0')
    })
  })

  context('Token Name', function () {
    it('testAdminCanUpdateName', async function () {
      const NEW_NAME = 'New Name'
      // Act
      this.logs = await this.cmtat.connect(this.admin).setName(NEW_NAME)
      // Assert
      expect(await this.cmtat.name()).to.equal(NEW_NAME)
      await expect(this.logs)
        .to.emit(this.cmtat, 'Name')
        .withArgs(NEW_NAME, NEW_NAME)
    })
    it('testCannotNonAdminUpdateName', async function () {
      // Act
      await expect(this.cmtat.connect(this.address1).setName('New Name'))
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, DEFAULT_ADMIN_ROLE)
      // Assert
      expect(await this.cmtat.name()).to.equal('CMTA Token')
    })
  })

  context('Token Symbol', function () {
    it('testAdminCanUpdateSymbol', async function () {
      const NEW_SYMBOL = 'New Symbol'
      // Act
      this.logs = await this.cmtat.connect(this.admin).setSymbol(NEW_SYMBOL)
      // Assert
      expect(await this.cmtat.symbol()).to.equal(NEW_SYMBOL)
      await expect(this.logs)
        .to.emit(this.cmtat, 'Symbol')
        .withArgs(NEW_SYMBOL, NEW_SYMBOL)
    })
    it('testCannotNonAdminUpdateName', async function () {
      // Act
      await expect(this.cmtat.connect(this.address1).setSymbol('New Symbol'))
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, DEFAULT_ADMIN_ROLE)
      // Assert
      expect(await this.cmtat.symbol()).to.equal('CMTAT')
    })
  })

  context('Balance', function () {
    const TOKEN_AMOUNTS = [31n, 32n, 33n]
    const TOKEN_INITIAL_SUPPLY = TOKEN_AMOUNTS.reduce((a, b) => {
      return a + b
    })
    beforeEach(async function () {
      await this.cmtat
        .connect(this.admin)
        .mint(this.address1, TOKEN_AMOUNTS[0])
      await this.cmtat
        .connect(this.admin)
        .mint(this.address2, TOKEN_AMOUNTS[1])
      await this.cmtat
        .connect(this.admin)
        .mint(this.address3, TOKEN_AMOUNTS[2])
    })
    it('testHasTheCorrectBalanceBatch', async function () {
      // Act + Assert
      // Assert
      const ADDRESSES = [this.address1, this.address2, this.address3]
      let result = await this.cmtat.batchBalanceOf(ADDRESSES)
      expect(result[0][0]).to.equal(TOKEN_AMOUNTS[0])
      expect(result[0][1]).to.equal(TOKEN_AMOUNTS[1])
      expect(result[1]).to.equal(TOKEN_INITIAL_SUPPLY)

      const ADDRESSES2 = []
      result = await this.cmtat.batchBalanceOf(ADDRESSES2)
      expect(result[0].length).to.equal(0n)
      expect(result[1]).to.equal(TOKEN_INITIAL_SUPPLY)
    })
  })

  context('Allowance', function () {
    // address1 -> address3
    it('testApproveAllowance', async function () {
      const AMOUNT_TO_APPROVE = 20n
      // Arrange - Assert
      expect(await this.cmtat.allowance(this.address1, this.address3)).to.equal(
        '0'
      )
      // Act
      this.logs = await this.cmtat
        .connect(this.address1)
        .approve(this.address3, AMOUNT_TO_APPROVE)
      // Assert
      expect(await this.cmtat.allowance(this.address1, this.address3)).to.equal(
        AMOUNT_TO_APPROVE
      )
      // emits an Approval event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Approval')
        .withArgs(this.address1, this.address3, AMOUNT_TO_APPROVE)
    })

    // ADDRESS1 -> ADDRESS3
    it('testRedefinedAllowanceWithApprove', async function () {
      const AMOUNT_TO_APPROVE = 50n
      const FIRST_AMOUNT_TO_APPROVE = 20n
      // Arrange
      expect(await this.cmtat.allowance(this.address1, this.address3)).to.equal(
        '0'
      )
      await this.cmtat
        .connect(this.address1)
        .approve(this.address3, FIRST_AMOUNT_TO_APPROVE)
      // Arrange - Assert
      expect(await this.cmtat.allowance(this.address1, this.address3)).to.equal(
        FIRST_AMOUNT_TO_APPROVE
      )
      // Act
      this.logs = await this.cmtat
        .connect(this.address1)
        .approve(this.address3, AMOUNT_TO_APPROVE)
      // Assert
      expect(await this.cmtat.allowance(this.address1, this.address3)).to.equal(
        AMOUNT_TO_APPROVE
      )
      // emits an Approval event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Approval')
        .withArgs(this.address1, this.address3, AMOUNT_TO_APPROVE)
    })
  })

  context('Transfer', function () {
    const TOKEN_AMOUNTS = [31n, 32n, 33n]
    const TOKEN_INITIAL_SUPPLY = TOKEN_AMOUNTS.reduce((a, b) => {
      return a + b
    })
    beforeEach(async function () {
      await this.cmtat
        .connect(this.admin)
        .mint(this.address1, TOKEN_AMOUNTS[0])
      await this.cmtat
        .connect(this.admin)
        .mint(this.address2, TOKEN_AMOUNTS[1])
      await this.cmtat
        .connect(this.admin)
        .mint(this.address3, TOKEN_AMOUNTS[2])
    })

    it('testTransferFromOneAccountToAnother', async function () {
      const AMOUNT_TO_TRANSFER = 11n
      // Act
      this.logs = await this.cmtat
        .connect(this.address1)
        .transfer(this.address2, AMOUNT_TO_TRANSFER)
      // Assert
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(
        TOKEN_AMOUNTS[0] - AMOUNT_TO_TRANSFER
      )
      expect(await this.cmtat.balanceOf(this.address2)).to.equal(
        TOKEN_AMOUNTS[1] + AMOUNT_TO_TRANSFER
      )
      expect(await this.cmtat.balanceOf(this.address3)).to.equal(
        TOKEN_AMOUNTS[2]
      )
      expect(await this.cmtat.totalSupply()).to.equal(TOKEN_INITIAL_SUPPLY)
      // emits a Transfer event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(this.address1, this.address2, AMOUNT_TO_TRANSFER)
    })

    // ADDRESS1 -> ADDRESS2
    it('testCannotTransferMoreTokensThanOwn', async function () {
      const ADDRESS1_BALANCE = await this.cmtat.balanceOf(this.address1)
      const AMOUNT_TO_TRANSFER = 50n
      // Act
      await expect(
        this.cmtat
          .connect(this.address1)
          .transfer(this.address2, AMOUNT_TO_TRANSFER)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'ERC20InsufficientBalance')
        .withArgs(this.address1.address, ADDRESS1_BALANCE, AMOUNT_TO_TRANSFER)
    })

    // allows address3 to transfer tokens from address1 to address2 with the right allowance
    // ADDRESS3 : ADDRESS1 -> ADDRESS2
    it('testTransferByAnotherAccountWithTheRightAllowance', async function () {
      const AMOUNT_TO_TRANSFER = 11n
      const AMOUNT_TO_APPROVE = 20
      // Arrange
      await this.cmtat
        .connect(this.address1)
        .approve(this.address3, AMOUNT_TO_APPROVE)
      // Act
      // Transfer
      this.logs = await this.cmtat
        .connect(this.address3)
        .transferFrom(this.address1, this.address2, 11)
      // Assert
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(
        TOKEN_AMOUNTS[0] - AMOUNT_TO_TRANSFER
      )
      expect(await this.cmtat.balanceOf(this.address2)).to.equal(
        TOKEN_AMOUNTS[1] + AMOUNT_TO_TRANSFER
      )
      expect(await this.cmtat.balanceOf(this.address3)).to.equal(
        TOKEN_AMOUNTS[2]
      )
      expect(await this.cmtat.totalSupply()).to.equal(TOKEN_INITIAL_SUPPLY)

      // emits a Transfer event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(this.address1, this.address2, AMOUNT_TO_TRANSFER)
      // emits a Spend event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Spend')
        .withArgs(this.address1, this.address3, AMOUNT_TO_TRANSFER)
    })

    // reverts if address3 transfers more tokens than the allowance from address1 to address2
    it('testCannotTransferByAnotherAccountWithInsufficientAllowance', async function () {
      const AMOUNT_TO_TRANSFER = 31n
      const ALLOWANCE_FOR_ADDRESS3 = 20n
      // Arrange
      // Define allowance
      expect(await this.cmtat.allowance(this.address1, this.address3)).to.equal(
        '0'
      )
      await this.cmtat
        .connect(this.address1)
        .approve(this.address3, ALLOWANCE_FOR_ADDRESS3)
      // Arrange - Assert
      expect(await this.cmtat.allowance(this.address1, this.address3)).to.equal(
        ALLOWANCE_FOR_ADDRESS3
      )
      // Act
      // Transfer
      await expect(
        this.cmtat
          .connect(this.address3)
          .transferFrom(this.address1, this.address2, 31)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'ERC20InsufficientAllowance')
        .withArgs(
          this.address3.address,
          ALLOWANCE_FOR_ADDRESS3,
          AMOUNT_TO_TRANSFER
        )
    })

    // reverts if address3 transfers more tokens than address1 owns from address1 to address2
    it('testCannotTransferByAnotherAccountWithInsufficientBalance', async function () {
      // Arrange
      const AMOUNT_TO_TRANSFER = 50n
      const ADDRESS1_BALANCE = await this.cmtat.balanceOf(this.address1)
      await this.cmtat.connect(this.address1).approve(this.address3, 1000)
      // Act
      await expect(
        this.cmtat
          .connect(this.address3)
          .transferFrom(this.address1, this.address2, AMOUNT_TO_TRANSFER)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'ERC20InsufficientBalance')
        .withArgs(this.address1.address, ADDRESS1_BALANCE, AMOUNT_TO_TRANSFER)
    })
  })

  context('transferFrom', function () {
    const TOKEN_AMOUNTS = [31n, 32n, 33n]
    const TOKEN_INITIAL_SUPPLY = TOKEN_AMOUNTS.reduce((a, b) => {
      return a + b
    })
    beforeEach(async function () {
      await this.cmtat
        .connect(this.admin)
        .mint(this.address1, TOKEN_AMOUNTS[0])
      await this.cmtat
        .connect(this.admin)
        .mint(this.address2, TOKEN_AMOUNTS[1])
      await this.cmtat
        .connect(this.admin)
        .mint(this.address3, TOKEN_AMOUNTS[2])
    })

    it('testTransferFromOneAccountToAnother', async function () {
      const AMOUNT_TO_TRANSFER = 11n
      // Act
      this.logs = await this.cmtat
        .connect(this.address1)
        .transfer(this.address2, AMOUNT_TO_TRANSFER)
      // Assert
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(
        TOKEN_AMOUNTS[0] - AMOUNT_TO_TRANSFER
      )
      expect(await this.cmtat.balanceOf(this.address2)).to.equal(
        TOKEN_AMOUNTS[1] + AMOUNT_TO_TRANSFER
      )
      expect(await this.cmtat.balanceOf(this.address3)).to.equal(
        TOKEN_AMOUNTS[2]
      )
      expect(await this.cmtat.totalSupply()).to.equal(TOKEN_INITIAL_SUPPLY)
      // emits a Transfer event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(this.address1, this.address2, AMOUNT_TO_TRANSFER)
    })

    // ADDRESS1 -> ADDRESS2
    it('testCannotTransferMoreTokensThanOwn', async function () {
      const ADDRESS1_BALANCE = await this.cmtat.balanceOf(this.address1)
      const AMOUNT_TO_TRANSFER = 50n
      // Act
      await expect(
        this.cmtat
          .connect(this.address1)
          .transfer(this.address2, AMOUNT_TO_TRANSFER)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'ERC20InsufficientBalance')
        .withArgs(this.address1.address, ADDRESS1_BALANCE, AMOUNT_TO_TRANSFER)
    })
  })
}
module.exports = ERC20BaseModuleCommon
