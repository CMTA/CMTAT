const {
  ERC20ENFORCER_ROLE,
  DEFAULT_ADMIN_ROLE,
  ZERO_ADDRESS,
  REJECTED_CODE_BASE_TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE
} = require('../utils')
const { expect } = require('chai')

const REASON_FREEZE_STRING = 'testFreeze'
const REASON_FREEZE_EVENT = ethers.toUtf8Bytes(REASON_FREEZE_STRING)
const reasonFreeze = ethers.Typed.bytes(REASON_FREEZE_EVENT)
const REASON_FREEZE_EMPTY = ethers.Typed.bytes(ethers.toUtf8Bytes(''))

const REASON_STRING = 'testUnfreeze'
const REASON_UNFREEZE_EVENT = ethers.toUtf8Bytes(REASON_STRING)
const reasonUnfreeze = ethers.Typed.bytes(REASON_UNFREEZE_EVENT)
const REASON_EMPTY = ethers.Typed.bytes(ethers.toUtf8Bytes(''))
const REASON_EMPTY_EVENT = ethers.toUtf8Bytes('')

const REASON_EVENT = ethers.toUtf8Bytes(REASON_STRING)
const REASON = ethers.Typed.bytes(REASON_EVENT)

const FREEZE_AMOUNT = 20
const UNFREEZE_AMOUNT = 10
const INITIAL_BALANCE = 50
function ERC20EnforcementModuleCommon () {
  context('Enforcement', function () {
    beforeEach(async function () {
      await this.cmtat.connect(this.admin).mint(this.address1, 50)
    })

    it('testCanForceTransferFromAddress1ToAddress2AsAdmin', async function () {
      const AMOUNT_TO_TRANSFER = 20
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .forcedTransfer(
          this.address1,
          this.address2,
          AMOUNT_TO_TRANSFER,
          REASON
        )
      // Assert
      expect(await this.cmtat.balanceOf(this.address1)).to.equal('30')
      expect(await this.cmtat.balanceOf(this.address2)).to.equal('20')
      // Events
      await expect(this.logs)
        .to.emit(this.cmtat, 'Enforcement')
        .withArgs(this.admin, this.address1, AMOUNT_TO_TRANSFER, REASON_EVENT)
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(this.address1, this.address2, AMOUNT_TO_TRANSFER)
    })

    it('testCanForceTransferFromAddress1ToAddress2AsAdminAndUnfreezeTokens', async function () {
      const AMOUNT_TO_TRANSFER = 20
      const AMOUNT_TO_FREEZE = 40
      this.logs = await this.cmtat
        .connect(this.admin)
        .freezePartialTokens(this.address1, AMOUNT_TO_FREEZE)

      expect(await this.cmtat.getActiveBalanceOf(this.address1)).to.equal('10')
      expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal('40')

      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .forcedTransfer(
          this.address1,
          this.address2,
          AMOUNT_TO_TRANSFER,
          REASON
        )
      // Assert
      expect(await this.cmtat.getActiveBalanceOf(this.address1)).to.equal('0')
      expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal('30')
      expect(await this.cmtat.balanceOf(this.address1)).to.equal('30')
      expect(await this.cmtat.balanceOf(this.address2)).to.equal('20')
      // Events
      await expect(this.logs)
        .to.emit(this.cmtat, 'Enforcement')
        .withArgs(this.admin, this.address1, AMOUNT_TO_TRANSFER, REASON_EVENT)
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(this.address1, this.address2, AMOUNT_TO_TRANSFER)
      await expect(this.logs)
        .to.emit(this.cmtat, 'TokensUnfrozen')
        .withArgs(this.address1, '10', REASON_EVENT)
    })

    it('testCanForceTransferFromAddress1ToAddress2AsAdminWithoutUnfreezeTokens', async function () {
      const AMOUNT_TO_TRANSFER = 20
      const AMOUNT_TO_FREEZE = 5
      this.logs = await this.cmtat
        .connect(this.admin)
        .freezePartialTokens(this.address1, AMOUNT_TO_FREEZE)

      expect(await this.cmtat.getActiveBalanceOf(this.address1)).to.equal('45')
      expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal('5')

      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .forcedTransfer(
          this.address1,
          this.address2,
          AMOUNT_TO_TRANSFER,
          REASON
        )
      // Assert
      expect(await this.cmtat.getActiveBalanceOf(this.address1)).to.equal('25')
      expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal('5')
      expect(await this.cmtat.balanceOf(this.address1)).to.equal('30')
      expect(await this.cmtat.balanceOf(this.address2)).to.equal('20')
      // Events
      await expect(this.logs)
        .to.emit(this.cmtat, 'Enforcement')
        .withArgs(this.admin, this.address1, AMOUNT_TO_TRANSFER, REASON_EVENT)
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(this.address1, this.address2, AMOUNT_TO_TRANSFER)
    })

    it('testCanForceTransferBurnFromAddress1ToAddress2AsAdminAndUnfreezeTokens', async function () {
      const initTotalSupply = await this.cmtat.totalSupply()
      const AMOUNT_TO_TRANSFER = 20
      const AMOUNT_TO_TRANSFER_BIG = 20n
      const AMOUNT_TO_FREEZE = 40
      this.logs = await this.cmtat
        .connect(this.admin)
        .freezePartialTokens(this.address1, AMOUNT_TO_FREEZE)

      expect(await this.cmtat.getActiveBalanceOf(this.address1)).to.equal('10')
      expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal('40')

      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .forcedTransfer(
          this.address1,
          ZERO_ADDRESS,
          AMOUNT_TO_TRANSFER,
          REASON
        )
      // Assert
      const totalSupplyAfter = await this.cmtat.totalSupply()
      expect(totalSupplyAfter).to.equal(
        initTotalSupply - AMOUNT_TO_TRANSFER_BIG
      )
      expect(await this.cmtat.getActiveBalanceOf(this.address1)).to.equal('0')
      expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal('30')
      expect(await this.cmtat.balanceOf(this.address1)).to.equal('30')
      // Events
      await expect(this.logs)
        .to.emit(this.cmtat, 'Enforcement')
        .withArgs(this.admin, this.address1, AMOUNT_TO_TRANSFER, REASON_EVENT)
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(this.address1, ZERO_ADDRESS, AMOUNT_TO_TRANSFER)
      await expect(this.logs)
        .to.emit(this.cmtat, 'TokensUnfrozen')
        .withArgs(this.address1, '10', REASON_EVENT)
    })

    it('testCanForceTransferFromAddress1ToAddress2AsAdminAndReduceAllowanceToZero', async function () {
      const AMOUNT_TO_TRANSFER = 20
      const AMOUNT_TO_APPROVE = 10
      await this.cmtat
        .connect(this.address1)
        .approve(this.address2, AMOUNT_TO_APPROVE)
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .forcedTransfer(
          this.address1,
          this.address2,
          AMOUNT_TO_TRANSFER,
          REASON
        )
      // Assert
      expect(await this.cmtat.allowance(this.address1, this.address2)).to.equal(
        '0'
      )
      expect(await this.cmtat.balanceOf(this.address1)).to.equal('30')
      expect(await this.cmtat.balanceOf(this.address2)).to.equal('20')
      // Events
      await expect(this.logs)
        .to.emit(this.cmtat, 'Enforcement')
        .withArgs(this.admin, this.address1, AMOUNT_TO_TRANSFER, REASON_EVENT)
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(this.address1, this.address2, AMOUNT_TO_TRANSFER)
    })

    it('testCanForceTransferFromAddress1ToAddress2AsAdminAndReduceAllowance', async function () {
      const AMOUNT_TO_TRANSFER = 20
      const AMOUNT_TO_APPROVE = 30
      await this.cmtat
        .connect(this.address1)
        .approve(this.address2, AMOUNT_TO_APPROVE)
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .forcedTransfer(
          this.address1,
          this.address2,
          AMOUNT_TO_TRANSFER,
          REASON
        )
      // Assert
      expect(await this.cmtat.allowance(this.address1, this.address2)).to.equal(
        '10'
      )
      expect(await this.cmtat.balanceOf(this.address1)).to.equal('30')
      expect(await this.cmtat.balanceOf(this.address2)).to.equal('20')
      // Events
      await expect(this.logs)
        .to.emit(this.cmtat, 'Enforcement')
        .withArgs(this.admin, this.address1, AMOUNT_TO_TRANSFER, REASON_EVENT)
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(this.address1, this.address2, AMOUNT_TO_TRANSFER)
    })

    it('testCanForceBurnWithForceTransferAsAdmin', async function () {
      const AMOUNT_TO_TRANSFER = 20
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .forcedTransfer(
          this.address1,
          ZERO_ADDRESS,
          AMOUNT_TO_TRANSFER,
          REASON
        )
      // Assert
      expect(await this.cmtat.balanceOf(this.address1)).to.equal('30')
      // Events
      await expect(this.logs)
        .to.emit(this.cmtat, 'Enforcement')
        .withArgs(this.admin, this.address1, AMOUNT_TO_TRANSFER, REASON_EVENT)
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(this.address1, ZERO_ADDRESS, AMOUNT_TO_TRANSFER)
    })

    it('testCanForceTransferFromAddress1ToAddress2AsAdminWithoutReason', async function () {
      const AMOUNT_TO_TRANSFER = 20
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .forcedTransfer(this.address1, this.address2, AMOUNT_TO_TRANSFER)
      // Assert
      expect(await this.cmtat.balanceOf(this.address1)).to.equal('30')
      expect(await this.cmtat.balanceOf(this.address2)).to.equal('20')
      // Events
      await expect(this.logs)
        .to.emit(this.cmtat, 'Enforcement')
        .withArgs(this.admin, this.address1, AMOUNT_TO_TRANSFER, '0x')
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(this.address1, this.address2, AMOUNT_TO_TRANSFER)
    })

    it('testCannotForceTransferFromAddress1ToAddress2IfBalanceNotEnough', async function () {
      const AMOUNT_TO_TRANSFER = 100000
      // Assert
      await expect(
        this.cmtat
          .connect(this.admin)
          .forcedTransfer(this.address1, this.address2, AMOUNT_TO_TRANSFER)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_ERC20EnforcementModule_ValueExceedsAvailableBalance'
      )
    })

    it('testCannotNonAdminTransferFunds', async function () {
      // Act
      await expect(
        this.cmtat
          .connect(this.address2)
          .forcedTransfer(this.address1, this.address2, 20, REASON)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, DEFAULT_ADMIN_ROLE)

      // Act
      await expect(
        this.cmtat
          .connect(this.address2)
          .forcedTransfer(this.address1, this.address2, 20)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, DEFAULT_ADMIN_ROLE)
    })
  })
  async function testFreeze (sender) {
    // Arrange - Assert
    expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal(0)
    expect(await this.cmtat.getActiveBalanceOf(this.address1)).to.equal(
      INITIAL_BALANCE
    )
    // Act
    this.logs = await this.cmtat
      .connect(sender)
      .freezePartialTokens(this.address1, FREEZE_AMOUNT)
    // Assert
    expect(
      await this.cmtat.canTransfer(
        this.address1,
        this.address2,
        INITIAL_BALANCE - FREEZE_AMOUNT + 1
      )
    ).to.equal(false)
    expect(
      await this.cmtat.canTransfer(
        this.address1,
        this.address2,
        INITIAL_BALANCE - FREEZE_AMOUNT
      )
    ).to.equal(true)
    expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal(
      FREEZE_AMOUNT
    )
    expect(await this.cmtat.getActiveBalanceOf(this.address1)).to.equal(
      INITIAL_BALANCE - FREEZE_AMOUNT
    )
    // emits a Freeze event
    await expect(this.logs)
      .to.emit(this.cmtat, 'TokensFrozen')
      .withArgs(this.address1, FREEZE_AMOUNT, REASON_EMPTY_EVENT)
  }

  async function testFreezeReason (sender) {
    // Arrange - Assert
    expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal(0)
    expect(await this.cmtat.getActiveBalanceOf(this.address1)).to.equal(
      INITIAL_BALANCE
    )
    // Act
    this.logs = await this.cmtat
      .connect(sender)
      .freezePartialTokens(this.address1, FREEZE_AMOUNT, REASON)
    // Assert
    expect(
      await this.cmtat.canTransfer(
        this.address1,
        this.address2,
        INITIAL_BALANCE - FREEZE_AMOUNT + 1
      )
    ).to.equal(false)
    expect(
      await this.cmtat.canTransfer(
        this.address1,
        this.address2,
        INITIAL_BALANCE - FREEZE_AMOUNT
      )
    ).to.equal(true)
    expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal(
      FREEZE_AMOUNT
    )
    expect(await this.cmtat.getActiveBalanceOf(this.address1)).to.equal(
      INITIAL_BALANCE - FREEZE_AMOUNT
    )
    // emits a Freeze event
    await expect(this.logs)
      .to.emit(this.cmtat, 'TokensFrozen')
      .withArgs(this.address1, FREEZE_AMOUNT, REASON_EVENT)
  }

  async function testUnfreeze (sender) {
    // Arrange
    const bindTest = await testFreeze.bind(this)
    await bindTest(sender)

    // Act
    this.logs = await this.cmtat
      .connect(sender)
      .unfreezePartialTokens(this.address1, UNFREEZE_AMOUNT)
    // Assert
    // False because amount <  active balance
    // active balance = 50 - 20 (freeze) + 10 (unfreeze) = 40
    expect(
      await this.cmtat.canTransfer(
        this.address1,
        this.address2,
        INITIAL_BALANCE - FREEZE_AMOUNT + UNFREEZE_AMOUNT + 1
      )
    ).to.equal(false)
    // True because <= active balance
    expect(
      await this.cmtat.canTransfer(
        this.address1,
        this.address2,
        INITIAL_BALANCE - FREEZE_AMOUNT + UNFREEZE_AMOUNT
      )
    ).to.equal(true)
    expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal(
      FREEZE_AMOUNT - UNFREEZE_AMOUNT
    )
    expect(await this.cmtat.getActiveBalanceOf(this.address1)).to.equal(
      INITIAL_BALANCE - FREEZE_AMOUNT + UNFREEZE_AMOUNT
    )
    // emits a Freeze event
    await expect(this.logs)
      .to.emit(this.cmtat, 'TokensUnfrozen')
      .withArgs(this.address1, UNFREEZE_AMOUNT, REASON_EMPTY_EVENT)
  }

  async function testUnfreezeReason (sender) {
    // Arrange
    const bindTest = await testFreeze.bind(this)
    await bindTest(sender)

    // Act
    this.logs = await this.cmtat
      .connect(sender)
      .unfreezePartialTokens(this.address1, UNFREEZE_AMOUNT, REASON)
    // Assert
    // False because amount <  active balance
    // active balance = 50 - 20 (freeze) + 10 (unfreeze) = 40
    expect(
      await this.cmtat.canTransfer(
        this.address1,
        this.address2,
        INITIAL_BALANCE - FREEZE_AMOUNT + UNFREEZE_AMOUNT + 1
      )
    ).to.equal(false)
    // True because <= active balance
    expect(
      await this.cmtat.canTransfer(
        this.address1,
        this.address2,
        INITIAL_BALANCE - FREEZE_AMOUNT + UNFREEZE_AMOUNT
      )
    ).to.equal(true)
    expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal(
      FREEZE_AMOUNT - UNFREEZE_AMOUNT
    )
    expect(await this.cmtat.getActiveBalanceOf(this.address1)).to.equal(
      INITIAL_BALANCE - FREEZE_AMOUNT + UNFREEZE_AMOUNT
    )
    // emits a Freeze event
    await expect(this.logs)
      .to.emit(this.cmtat, 'TokensUnfrozen')
      .withArgs(this.address1, UNFREEZE_AMOUNT, REASON_EVENT)
  }

  context('Freeze', function () {
    beforeEach(async function () {
      await this.cmtat.connect(this.admin).mint(this.address1, INITIAL_BALANCE)
    })

    it('testAdminCanFreezeAddress', async function () {
      const bindTest = await testFreeze.bind(this)
      await bindTest(this.admin)
    })

    it('testEnforcerRoleCanFreezeAddress', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(ERC20ENFORCER_ROLE, this.address2)

      const bindTest = await testFreeze.bind(this)
      await bindTest(this.address2)
    })

    it('testAdminCanUnfreezeAddress', async function () {
      // Arrange
      const bindTest = await testUnfreeze.bind(this)
      await bindTest(this.admin)
    })

    it('testEnforcerRoleCanUnfreezeAddress', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(ERC20ENFORCER_ROLE, this.address2)

      const bindTest = await testUnfreeze.bind(this)
      await bindTest(this.address2)
    })

    it('testAdminCanFreezeAddressReason', async function () {
      const bindTest = await testFreezeReason.bind(this)
      await bindTest(this.admin)
    })

    it('testEnforcerRoleCanFreezeAddressReason', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(ERC20ENFORCER_ROLE, this.address2)

      const bindTest = await testFreezeReason.bind(this)
      await bindTest(this.address2)
    })

    it('testAdminCanUnfreezeAddressReason', async function () {
      // Arrange
      const bindTest = await testUnfreezeReason.bind(this)
      await bindTest(this.admin)
    })

    it('testEnforcerRoleCanUnfreezeAddressReason', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(ERC20ENFORCER_ROLE, this.address2)

      const bindTest = await testUnfreezeReason.bind(this)
      await bindTest(this.address2)
    })

    it('testCannotNonEnforcerFreezeAddress', async function () {
      // Act
      await expect(
        this.cmtat
          .connect(this.address2)
          .freezePartialTokens(this.address1, FREEZE_AMOUNT)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, ERC20ENFORCER_ROLE)
      // Assert
      expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal(0)
    })

    it('testCannotNonEnforcerUnfreezeAddress', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .freezePartialTokens(this.address1, FREEZE_AMOUNT)
      // Act
      await expect(
        this.cmtat
          .connect(this.address2)
          .unfreezePartialTokens(this.address1, FREEZE_AMOUNT)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, ERC20ENFORCER_ROLE)
      // Assert
      expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal(
        FREEZE_AMOUNT
      )
    })

    it('testCannotTransferMoreThanActiveBalance', async function () {
      const AMOUNT_TO_TRANSFER = INITIAL_BALANCE - FREEZE_AMOUNT + 1
      // Act
      await this.cmtat
        .connect(this.admin)
        .freezePartialTokens(this.address1, FREEZE_AMOUNT)
      if (!this.erc1404) {
        // Assert
        expect(
          await this.cmtat.detectTransferRestriction(
            this.address1,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal(
          REJECTED_CODE_BASE_TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE
        )
        expect(
          await this.cmtat.messageForTransferRestriction(
            REJECTED_CODE_BASE_TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE
          )
        ).to.equal('AddrFrom:insufficientActiveBalance')
      }

      await expect(
        this.cmtat
          .connect(this.address1)
          .transfer(this.address2, AMOUNT_TO_TRANSFER)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_ERC20EnforcementModule_ValueExceedsActiveBalance'
      )
    })

    it('testCanTransferTokenIfActiveBalanceIsEnough', async function () {
      const AMOUNT_TO_TRANSFER = INITIAL_BALANCE - FREEZE_AMOUNT
      // Arrange
      // Define allowance
      await this.cmtat.connect(this.address3).approve(this.address1, 20)
      // Act
      await this.cmtat
        .connect(this.admin)
        .freezePartialTokens(this.address1, FREEZE_AMOUNT)

      // Assert
      expect(
        await this.cmtat.canTransfer(
          this.address1,
          this.address2,
          AMOUNT_TO_TRANSFER
        )
      ).to.equal(true)

      expect(
        await this.cmtat.canTransferFrom(
          this.address3,
          this.address1,
          this.address2,
          AMOUNT_TO_TRANSFER
        )
      ).to.equal(true)

      if (!this.erc1404) {
        expect(
          await this.cmtat.detectTransferRestriction(
            this.address1,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal('0')

        expect(
          await this.cmtat.detectTransferRestrictionFrom(
            this.address3,
            this.address1,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal('0')
      }
    })

    it('testCannotTransferFromTokenIfActiveBalanceIsNotEnough', async function () {
      const AMOUNT_TO_TRANSFER = INITIAL_BALANCE - FREEZE_AMOUNT + 1
      // Arrange
      // Define allowance
      await this.cmtat
        .connect(this.address1)
        .approve(this.address3, AMOUNT_TO_TRANSFER)
      // Act
      await this.cmtat
        .connect(this.admin)
        .freezePartialTokens(this.address1, FREEZE_AMOUNT)

      // Assert
      expect(
        await this.cmtat.canTransfer(
          this.address1,
          this.address2,
          AMOUNT_TO_TRANSFER
        )
      ).to.equal(false)
      expect(
        await this.cmtat.canTransferFrom(
          this.address3,
          this.address1,
          this.address2,
          AMOUNT_TO_TRANSFER
        )
      ).to.equal(false)

      if (!this.erc1404) {
        expect(
          await this.cmtat.detectTransferRestriction(
            this.address1,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal(
          REJECTED_CODE_BASE_TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE
        )

        expect(
          await this.cmtat.detectTransferRestrictionFrom(
            this.address3,
            this.address1,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal(
          REJECTED_CODE_BASE_TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE
        )
        expect(
          await this.cmtat.messageForTransferRestriction(
            REJECTED_CODE_BASE_TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE
          )
        ).to.equal('AddrFrom:insufficientActiveBalance')
      }

      await expect(
        this.cmtat
          .connect(this.address3)
          .transferFrom(this.address1, this.address2, AMOUNT_TO_TRANSFER)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_ERC20EnforcementModule_ValueExceedsActiveBalance'
      )
    })

    it('testCannotTransferFromTokenIfActiveBalanceIsNotEnough', async function () {
      const AMOUNT_TO_TRANSFER = INITIAL_BALANCE - FREEZE_AMOUNT + 1
      // Arrange
      // Define allowance
      await this.cmtat
        .connect(this.address1)
        .approve(this.address3, AMOUNT_TO_TRANSFER)
      // Act
      await this.cmtat
        .connect(this.admin)
        .freezePartialTokens(this.address1, FREEZE_AMOUNT)

      // Assert
      expect(
        await this.cmtat.canTransfer(
          this.address1,
          this.address2,
          AMOUNT_TO_TRANSFER
        )
      ).to.equal(false)

      expect(
        await this.cmtat.canTransferFrom(
          this.address3,
          this.address1,
          this.address2,
          AMOUNT_TO_TRANSFER
        )
      ).to.equal(false)

      if (!this.erc1404) {
        expect(
          await this.cmtat.detectTransferRestriction(
            this.address1,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal(
          REJECTED_CODE_BASE_TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE
        )
        expect(
          await this.cmtat.detectTransferRestrictionFrom(
            this.address3,
            this.address1,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal(
          REJECTED_CODE_BASE_TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE
        )
        expect(
          await this.cmtat.messageForTransferRestriction(
            REJECTED_CODE_BASE_TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE
          )
        ).to.equal('AddrFrom:insufficientActiveBalance')
        expect(
          await this.cmtat.detectTransferRestrictionFrom(
            this.address3,
            this.address1,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal(
          REJECTED_CODE_BASE_TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE
        )
      }

      await expect(
        this.cmtat
          .connect(this.address3)
          .transferFrom(this.address1, this.address2, AMOUNT_TO_TRANSFER)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_ERC20EnforcementModule_ValueExceedsActiveBalance'
      )
    })
  })
}
module.exports = ERC20EnforcementModuleCommon
