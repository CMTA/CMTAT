const {
  ERC20ENFORCER_ROLE,
  DEFAULT_ADMIN_ROLE,
  ZERO_ADDRESS,
  REJECTED_CODE_BASE_TRANSFER_OK,
  REJECTED_CODE_BASE_TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE
} = require('../utils')
const { expect } = require('chai')

const REASON_STRING = 'testUnfreeze'

const REASON_EVENT = ethers.toUtf8Bytes(REASON_STRING)
const REASON = ethers.Typed.bytes(REASON_EVENT)

const FREEZE_AMOUNT = 20
const UNFREEZE_AMOUNT = 10
const INITIAL_BALANCE = 50

function supportsReasonedEnforcement (ctx) {
  return !!ctx.erc7551
}

async function getActiveBalance (ctx, account) {
  if (supportsReasonedEnforcement(ctx)) {
    return await ctx.cmtat.getActiveBalanceOf(account)
  }

  const balance = await ctx.cmtat.balanceOf(account)
  const frozen = await ctx.cmtat.getFrozenTokens(account)
  if (frozen >= balance) {
    return '0'
  }
  return balance - frozen
}

async function forcedTransferCompat (ctx, sender, from, to, value, reason) {
  const contract = ctx.cmtat.connect(sender)
  if (supportsReasonedEnforcement(ctx)) {
    return contract.forcedTransfer(from, to, value, reason)
  }
  return contract.forcedTransfer(from, to, value)
}

async function freezePartialTokensCompat (ctx, sender, account, value, reason) {
  const contract = ctx.cmtat.connect(sender)
  if (reason !== undefined && supportsReasonedEnforcement(ctx)) {
    return contract.freezePartialTokens(account, value, reason)
  }
  return contract.freezePartialTokens(account, value)
}

async function unfreezePartialTokensCompat (
  ctx,
  sender,
  account,
  value,
  reason
) {
  const contract = ctx.cmtat.connect(sender)
  if (reason !== undefined && supportsReasonedEnforcement(ctx)) {
    return contract.unfreezePartialTokens(account, value, reason)
  }
  return contract.unfreezePartialTokens(account, value)
}

async function assertReasonedForcedTransferEvent (
  ctx,
  logs,
  from,
  to,
  value,
  reason
) {
  if (!supportsReasonedEnforcement(ctx)) {
    return
  }
  await expect(logs)
    .to.emit(ctx.cmtat, 'ForcedTransfer(address,address,address,uint256,bytes)')
    .withArgs(ctx.admin, from, to, value, reason)
}

function ERC20EnforcementModuleCommon () {
  context('Enforcement', function () {
    beforeEach(async function () {
      await this.cmtat.connect(this.admin).mint(this.address1, 50)
    })

    it('testCanForceTransferFromAddress1ToAddress2AsAdmin', async function () {
      const AMOUNT_TO_TRANSFER = 20
      // Act
      this.logs = await forcedTransferCompat(
        this,
        this.admin,
        this.address1,
        this.address2,
        AMOUNT_TO_TRANSFER,
        REASON
      )
      // Assert
      expect(await this.cmtat.balanceOf(this.address1)).to.equal('30')
      expect(await this.cmtat.balanceOf(this.address2)).to.equal('20')
      // Events
      await assertReasonedForcedTransferEvent(
        this,
        this.logs,
        this.address1,
        this.address2,
        AMOUNT_TO_TRANSFER,
        REASON_EVENT
      )
      await expect(this.logs)
        .to.emit(this.cmtat, 'ForcedTransfer(address,address,uint256)')
        .withArgs(this.address1, this.address2, AMOUNT_TO_TRANSFER)
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

      expect(await getActiveBalance(this, this.address1)).to.equal('10')
      expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal('40')

      // Act
      this.logs = await forcedTransferCompat(
        this,
        this.admin,
        this.address1,
        this.address2,
        AMOUNT_TO_TRANSFER,
        REASON
      )
      // Assert
      expect(await getActiveBalance(this, this.address1)).to.equal('0')
      expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal('30')
      expect(await this.cmtat.balanceOf(this.address1)).to.equal('30')
      expect(await this.cmtat.balanceOf(this.address2)).to.equal('20')
      // Events
      await assertReasonedForcedTransferEvent(
        this,
        this.logs,
        this.address1,
        this.address2,
        AMOUNT_TO_TRANSFER,
        REASON_EVENT
      )
      await expect(this.logs)
        .to.emit(this.cmtat, 'ForcedTransfer(address,address,uint256)')
        .withArgs(this.address1, this.address2, AMOUNT_TO_TRANSFER)
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(this.address1, this.address2, AMOUNT_TO_TRANSFER)
      if (supportsReasonedEnforcement(this)) {
        await expect(this.logs)
          .to.emit(this.cmtat, 'TokensUnfrozen(address,uint256,bytes)')
          .withArgs(this.address1, '10', REASON_EVENT)
      } else {
        await expect(this.logs)
          .to.emit(this.cmtat, 'TokensUnfrozen(address,uint256)')
          .withArgs(this.address1, '10')
      }
      await expect(this.logs)
        .to.emit(this.cmtat, 'Frozen')
        .withArgs(this.address1, '30')
    })

    it('testCanForceTransferFromAddress1ToAddress2AsAdminWithoutUnfreezeTokens', async function () {
      const AMOUNT_TO_TRANSFER = 20
      const AMOUNT_TO_FREEZE = 5
      this.logs = await this.cmtat
        .connect(this.admin)
        .freezePartialTokens(this.address1, AMOUNT_TO_FREEZE)

      expect(await getActiveBalance(this, this.address1)).to.equal('45')
      expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal('5')

      // Act
      this.logs = await forcedTransferCompat(
        this,
        this.admin,
        this.address1,
        this.address2,
        AMOUNT_TO_TRANSFER,
        REASON
      )
      // Assert
      expect(await getActiveBalance(this, this.address1)).to.equal('25')
      expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal('5')
      expect(await this.cmtat.balanceOf(this.address1)).to.equal('30')
      expect(await this.cmtat.balanceOf(this.address2)).to.equal('20')
      // Events
      await assertReasonedForcedTransferEvent(
        this,
        this.logs,
        this.address1,
        this.address2,
        AMOUNT_TO_TRANSFER,
        REASON_EVENT
      )
      await expect(this.logs)
        .to.emit(this.cmtat, 'ForcedTransfer(address,address,uint256)')
        .withArgs(this.address1, this.address2, AMOUNT_TO_TRANSFER)
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

      expect(await getActiveBalance(this, this.address1)).to.equal('10')
      expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal('40')

      // Act
      this.logs = await forcedTransferCompat(
        this,
        this.admin,
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
      expect(await getActiveBalance(this, this.address1)).to.equal('0')
      expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal('30')
      expect(await this.cmtat.balanceOf(this.address1)).to.equal('30')
      // Events
      await assertReasonedForcedTransferEvent(
        this,
        this.logs,
        this.address1,
        ZERO_ADDRESS,
        AMOUNT_TO_TRANSFER,
        REASON_EVENT
      )
      await expect(this.logs)
        .to.emit(this.cmtat, 'ForcedTransfer(address,address,uint256)')
        .withArgs(this.address1, ZERO_ADDRESS, AMOUNT_TO_TRANSFER)
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(this.address1, ZERO_ADDRESS, AMOUNT_TO_TRANSFER)
      if (supportsReasonedEnforcement(this)) {
        await expect(this.logs)
          .to.emit(this.cmtat, 'TokensUnfrozen(address,uint256,bytes)')
          .withArgs(this.address1, '10', REASON_EVENT)
      } else {
        await expect(this.logs)
          .to.emit(this.cmtat, 'TokensUnfrozen(address,uint256)')
          .withArgs(this.address1, '10')
      }
      await expect(this.logs)
        .to.emit(this.cmtat, 'Frozen')
        .withArgs(this.address1, '30')
    })

    it('testCanForceTransferFromAddress1ToAddress2AsAdminAndReduceAllowanceToZero', async function () {
      const AMOUNT_TO_TRANSFER = 20
      const AMOUNT_TO_APPROVE = 10
      await this.cmtat
        .connect(this.address1)
        .approve(this.address2, AMOUNT_TO_APPROVE)
      // Act
      this.logs = await forcedTransferCompat(
        this,
        this.admin,
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
      await assertReasonedForcedTransferEvent(
        this,
        this.logs,
        this.address1,
        this.address2,
        AMOUNT_TO_TRANSFER,
        REASON_EVENT
      )
      await expect(this.logs)
        .to.emit(this.cmtat, 'ForcedTransfer(address,address,uint256)')
        .withArgs(this.address1, this.address2, AMOUNT_TO_TRANSFER)
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
      this.logs = await forcedTransferCompat(
        this,
        this.admin,
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
      await assertReasonedForcedTransferEvent(
        this,
        this.logs,
        this.address1,
        this.address2,
        AMOUNT_TO_TRANSFER,
        REASON_EVENT
      )
      await expect(this.logs)
        .to.emit(this.cmtat, 'ForcedTransfer(address,address,uint256)')
        .withArgs(this.address1, this.address2, AMOUNT_TO_TRANSFER)
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(this.address1, this.address2, AMOUNT_TO_TRANSFER)
    })

    it('testCanForceBurnWithForceTransferAsAdmin', async function () {
      const AMOUNT_TO_TRANSFER = 20
      // Act
      this.logs = await forcedTransferCompat(
        this,
        this.admin,
        this.address1,
        ZERO_ADDRESS,
        AMOUNT_TO_TRANSFER,
        REASON
      )
      // Assert
      expect(await this.cmtat.balanceOf(this.address1)).to.equal('30')
      // Events
      await assertReasonedForcedTransferEvent(
        this,
        this.logs,
        this.address1,
        ZERO_ADDRESS,
        AMOUNT_TO_TRANSFER,
        REASON_EVENT
      )
      await expect(this.logs)
        .to.emit(this.cmtat, 'ForcedTransfer(address,address,uint256)')
        .withArgs(this.address1, ZERO_ADDRESS, AMOUNT_TO_TRANSFER)
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
        .to.emit(this.cmtat, 'ForcedTransfer(address,address,uint256)')
        .withArgs(this.address1, this.address2, AMOUNT_TO_TRANSFER)
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

    it('testCannotForceTransferToTheSameAddress', async function () {
      // Arrange - freeze the whole balance of address1
      await freezePartialTokensCompat(
        this,
        this.admin,
        this.address1,
        50,
        REASON
      )
      // Act
      await expect(
        forcedTransferCompat(
          this,
          this.admin,
          this.address1,
          this.address1,
          50,
          REASON
        )
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_ERC20EnforcementModule_SelfTransferNotAllowed'
      )
      // Assert - the frozen tokens have not been released
      expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal('50')
      expect(await this.cmtat.balanceOf(this.address1)).to.equal('50')
    })

    it('testCannotNonAdminTransferFunds', async function () {
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
    expect(await getActiveBalance(this, this.address1)).to.equal(
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
    expect(await getActiveBalance(this, this.address1)).to.equal(
      INITIAL_BALANCE - FREEZE_AMOUNT
    )
    // emits a Freeze event
    await expect(this.logs)
      .to.emit(this.cmtat, 'TokensFrozen(address,uint256)')
      .withArgs(this.address1, FREEZE_AMOUNT)

    await expect(this.logs)
      .to.emit(this.cmtat, 'Frozen')
      .withArgs(this.address1, FREEZE_AMOUNT)
  }

  async function testFreezeTwice (sender) {
    // Arrange - Assert
    expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal(0)
    expect(await getActiveBalance(this, this.address1)).to.equal(
      INITIAL_BALANCE
    )
    // Act
    this.logs = await this.cmtat
      .connect(sender)
      .freezePartialTokens(this.address1, FREEZE_AMOUNT)
    this.logs = await this.cmtat
      .connect(sender)
      .freezePartialTokens(this.address1, FREEZE_AMOUNT)

    const frozenTokens = FREEZE_AMOUNT + FREEZE_AMOUNT
    // Assert
    expect(
      await this.cmtat.canTransfer(
        this.address1,
        this.address2,
        INITIAL_BALANCE - frozenTokens + 1
      )
    ).to.equal(false)
    expect(
      await this.cmtat.canTransfer(
        this.address1,
        this.address2,
        INITIAL_BALANCE - frozenTokens
      )
    ).to.equal(true)
    expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal(
      frozenTokens
    )
    expect(await getActiveBalance(this, this.address1)).to.equal(
      INITIAL_BALANCE - frozenTokens
    )
    // emits a Freeze event
    await expect(this.logs)
      .to.emit(this.cmtat, 'TokensFrozen(address,uint256)')
      .withArgs(this.address1, FREEZE_AMOUNT)

    await expect(this.logs)
      .to.emit(this.cmtat, 'Frozen')
      .withArgs(this.address1, frozenTokens)
  }

  async function testSetFrozenTokens_Freeze (sender) {
    // Arrange - Assert
    expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal(0)
    expect(await getActiveBalance(this, this.address1)).to.equal(
      INITIAL_BALANCE
    )
    // Act
    this.logs = await this.cmtat
      .connect(sender)
      .setFrozenTokens(this.address1, FREEZE_AMOUNT)
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
    expect(await getActiveBalance(this, this.address1)).to.equal(
      INITIAL_BALANCE - FREEZE_AMOUNT
    )
    // emits a Freeze event
    await expect(this.logs)
      .to.emit(this.cmtat, 'TokensFrozen(address,uint256)')
      .withArgs(this.address1, FREEZE_AMOUNT)

    await expect(this.logs)
      .to.emit(this.cmtat, 'Frozen')
      .withArgs(this.address1, FREEZE_AMOUNT)
  }

  async function testSetFrozenTokens_FreezeWithTokenFrozen (sender) {
    // Arrange - Assert
    expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal(0)
    expect(await getActiveBalance(this, this.address1)).to.equal(
      INITIAL_BALANCE
    )
    this.logs = await this.cmtat
      .connect(sender)
      .freezePartialTokens(this.address1, FREEZE_AMOUNT)
    // Act
    this.logs = await expect(
      this.cmtat.connect(sender).setFrozenTokens(this.address1, FREEZE_AMOUNT)
    ).to.be.revertedWithCustomError(
      this.cmtat,
      'CMTAT_ERC20EnforcementModule_ValueEqualCurrentFrozenTokens'
    )
  }

  async function testSetFrozenTokens_FreezeWithTokenFrozenDifferentLess (
    sender
  ) {
    const FREEZE_AMOUNT_NEW = FREEZE_AMOUNT - 1
    // Arrange - Assert
    expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal(0)
    expect(await getActiveBalance(this, this.address1)).to.equal(
      INITIAL_BALANCE
    )
    this.logs = await this.cmtat
      .connect(sender)
      .freezePartialTokens(this.address1, FREEZE_AMOUNT)
    // Act
    this.logs = await this.cmtat
      .connect(sender)
      .setFrozenTokens(this.address1, FREEZE_AMOUNT_NEW)
    // Assert
    expect(
      await this.cmtat.canTransfer(
        this.address1,
        this.address2,
        INITIAL_BALANCE - FREEZE_AMOUNT_NEW + 1
      )
    ).to.equal(false)
    expect(
      await this.cmtat.canTransfer(
        this.address1,
        this.address2,
        INITIAL_BALANCE - FREEZE_AMOUNT_NEW
      )
    ).to.equal(true)
    expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal(
      FREEZE_AMOUNT_NEW
    )
    expect(await getActiveBalance(this, this.address1)).to.equal(
      INITIAL_BALANCE - FREEZE_AMOUNT_NEW
    )
    // emits a Freeze event
    await expect(this.logs)
      .to.emit(this.cmtat, 'TokensUnfrozen(address,uint256)')
      .withArgs(this.address1, 1)

    await expect(this.logs)
      .to.emit(this.cmtat, 'Frozen')
      .withArgs(this.address1, FREEZE_AMOUNT_NEW)
  }

  async function testSetFrozenTokens_FreezeWithTokenFrozenDifferentMore (
    sender
  ) {
    const FREEZE_AMOUNT_NEW = FREEZE_AMOUNT + 1
    // Arrange - Assert
    expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal(0)
    expect(await getActiveBalance(this, this.address1)).to.equal(
      INITIAL_BALANCE
    )
    this.logs = await this.cmtat
      .connect(sender)
      .freezePartialTokens(this.address1, FREEZE_AMOUNT)
    // Act
    this.logs = await this.cmtat
      .connect(sender)
      .setFrozenTokens(this.address1, FREEZE_AMOUNT_NEW)
    // Assert
    expect(
      await this.cmtat.canTransfer(
        this.address1,
        this.address2,
        INITIAL_BALANCE - FREEZE_AMOUNT_NEW + 1
      )
    ).to.equal(false)
    expect(
      await this.cmtat.canTransfer(
        this.address1,
        this.address2,
        INITIAL_BALANCE - FREEZE_AMOUNT_NEW
      )
    ).to.equal(true)
    expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal(
      FREEZE_AMOUNT_NEW
    )
    expect(await getActiveBalance(this, this.address1)).to.equal(
      INITIAL_BALANCE - FREEZE_AMOUNT_NEW
    )
    // emits a Freeze event
    await expect(this.logs)
      .to.emit(this.cmtat, 'TokensFrozen(address,uint256)')
      .withArgs(this.address1, 1)

    await expect(this.logs)
      .to.emit(this.cmtat, 'Frozen')
      .withArgs(this.address1, FREEZE_AMOUNT_NEW)
  }

  async function testFreezeReason (sender) {
    // Arrange - Assert
    expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal(0)
    expect(await getActiveBalance(this, this.address1)).to.equal(
      INITIAL_BALANCE
    )
    // Act
    this.logs = await freezePartialTokensCompat(
      this,
      sender,
      this.address1,
      FREEZE_AMOUNT,
      REASON
    )
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
    expect(await getActiveBalance(this, this.address1)).to.equal(
      INITIAL_BALANCE - FREEZE_AMOUNT
    )
    // emits a Freeze event
    if (supportsReasonedEnforcement(this)) {
      await expect(this.logs)
        .to.emit(this.cmtat, 'TokensFrozen(address,uint256,bytes)')
        .withArgs(this.address1, FREEZE_AMOUNT, REASON_EVENT)
    } else {
      await expect(this.logs)
        .to.emit(this.cmtat, 'TokensFrozen(address,uint256)')
        .withArgs(this.address1, FREEZE_AMOUNT)
    }

    await expect(this.logs)
      .to.emit(this.cmtat, 'Frozen')
      .withArgs(this.address1, FREEZE_AMOUNT)
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
    const frozenTokens = FREEZE_AMOUNT - UNFREEZE_AMOUNT
    expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal(
      frozenTokens
    )
    expect(await getActiveBalance(this, this.address1)).to.equal(
      INITIAL_BALANCE - FREEZE_AMOUNT + UNFREEZE_AMOUNT
    )
    // emits a Freeze event
    await expect(this.logs)
      .to.emit(this.cmtat, 'TokensUnfrozen(address,uint256)')
      .withArgs(this.address1, UNFREEZE_AMOUNT)

    await expect(this.logs)
      .to.emit(this.cmtat, 'Frozen')
      .withArgs(this.address1, frozenTokens)
  }

  async function testUnfreezeTotalAndTransferMoreActiveBalance (sender) {
    // Arrange
    const bindTest = await testFreeze.bind(this)
    await bindTest(sender)

    // Act
    this.logs = await this.cmtat
      .connect(sender)
      .unfreezePartialTokens(this.address1, UNFREEZE_AMOUNT)
    this.logs = await this.cmtat
      .connect(sender)
      .unfreezePartialTokens(this.address1, UNFREEZE_AMOUNT)

    const frozenTokens = FREEZE_AMOUNT - UNFREEZE_AMOUNT - UNFREEZE_AMOUNT
    const unfreezeTokensAmount = UNFREEZE_AMOUNT + UNFREEZE_AMOUNT
    // Assert
    // True because
    // We don't check the balance if frozenTokens == 0
    expect(
      await this.cmtat.canTransfer(
        this.address1,
        this.address2,
        // 50 - 20 + 10 + 10 + 1 = 51
        INITIAL_BALANCE - FREEZE_AMOUNT + unfreezeTokensAmount + 1
      )
    ).to.equal(true)
    // True because <= active balance
    expect(
      await this.cmtat.canTransfer(
        this.address1,
        this.address2,
        INITIAL_BALANCE - FREEZE_AMOUNT + unfreezeTokensAmount
      )
    ).to.equal(true)

    expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal(0)
    expect(await getActiveBalance(this, this.address1)).to.equal(
      INITIAL_BALANCE - FREEZE_AMOUNT + unfreezeTokensAmount
    )
    // emits a Freeze event
    await expect(this.logs)
      .to.emit(this.cmtat, 'TokensUnfrozen(address,uint256)')
      .withArgs(this.address1, UNFREEZE_AMOUNT)

    await expect(this.logs)
      .to.emit(this.cmtat, 'Frozen')
      .withArgs(this.address1, frozenTokens)
  }

  async function testUnfreezeTwice (sender) {
    // Arrange
    const bindTest = await testFreeze.bind(this)
    await bindTest(sender)

    const UNFREEZE_AMOUNT_TWICE = UNFREEZE_AMOUNT - 1
    // Act
    this.logs = await this.cmtat
      .connect(sender)
      .unfreezePartialTokens(this.address1, UNFREEZE_AMOUNT)
    this.logs = await this.cmtat
      .connect(sender)
      .unfreezePartialTokens(this.address1, UNFREEZE_AMOUNT_TWICE)

    const frozenTokens =
      FREEZE_AMOUNT - UNFREEZE_AMOUNT - UNFREEZE_AMOUNT_TWICE
    const unfreezeTokensAmount = UNFREEZE_AMOUNT + UNFREEZE_AMOUNT_TWICE
    // Assert
    // False because amount <  active balance
    // active balance = 50 - 20 (freeze) + 19 (unfreeze) = 49
    expect(
      await this.cmtat.canTransfer(
        this.address1,
        this.address2,
        // 50
        INITIAL_BALANCE - FREEZE_AMOUNT + unfreezeTokensAmount + 1
      )
    ).to.equal(false)
    expect(
      await this.cmtat.canTransfer(
        this.address1,
        this.address2,
        // 50
        INITIAL_BALANCE - FREEZE_AMOUNT + unfreezeTokensAmount + 2
      )
    ).to.equal(false)
    // True because <= active balance
    expect(
      await this.cmtat.canTransfer(
        this.address1,
        this.address2,
        INITIAL_BALANCE - FREEZE_AMOUNT + unfreezeTokensAmount
      )
    ).to.equal(true)

    expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal(
      frozenTokens
    )
    expect(await getActiveBalance(this, this.address1)).to.equal(
      INITIAL_BALANCE - FREEZE_AMOUNT + unfreezeTokensAmount
    )
    // emits a Freeze event
    await expect(this.logs)
      .to.emit(this.cmtat, 'TokensUnfrozen(address,uint256)')
      .withArgs(this.address1, UNFREEZE_AMOUNT_TWICE)

    await expect(this.logs)
      .to.emit(this.cmtat, 'Frozen')
      .withArgs(this.address1, frozenTokens)
  }

  async function testUnfreezeReason (sender) {
    const frozenTokens = FREEZE_AMOUNT - UNFREEZE_AMOUNT
    // Arrange
    const bindTest = await testFreeze.bind(this)
    await bindTest(sender)

    // Act
    this.logs = await unfreezePartialTokensCompat(
      this,
      sender,
      this.address1,
      UNFREEZE_AMOUNT,
      REASON
    )
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
      frozenTokens
    )
    expect(await getActiveBalance(this, this.address1)).to.equal(
      INITIAL_BALANCE - FREEZE_AMOUNT + UNFREEZE_AMOUNT
    )
    // emits a Freeze event
    if (supportsReasonedEnforcement(this)) {
      await expect(this.logs)
        .to.emit(this.cmtat, 'TokensUnfrozen(address,uint256,bytes)')
        .withArgs(this.address1, UNFREEZE_AMOUNT, REASON_EVENT)
    } else {
      await expect(this.logs)
        .to.emit(this.cmtat, 'TokensUnfrozen(address,uint256)')
        .withArgs(this.address1, UNFREEZE_AMOUNT)
    }

    await expect(this.logs)
      .to.emit(this.cmtat, 'Frozen')
      .withArgs(this.address1, frozenTokens)
  }

  async function testSetFrozenTokens_Unfreeze (sender) {
    // Arrange
    const bindTest = await testFreeze.bind(this)
    await bindTest(sender)

    const frozenTokens = FREEZE_AMOUNT - UNFREEZE_AMOUNT
    // Act
    this.logs = await this.cmtat
      .connect(sender)
      .setFrozenTokens(this.address1, frozenTokens)
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
      frozenTokens
    )
    expect(await getActiveBalance(this, this.address1)).to.equal(
      INITIAL_BALANCE - FREEZE_AMOUNT + UNFREEZE_AMOUNT
    )
    // emits a Freeze event
    await expect(this.logs)
      .to.emit(this.cmtat, 'TokensUnfrozen(address,uint256)')
      .withArgs(this.address1, UNFREEZE_AMOUNT)

    await expect(this.logs)
      .to.emit(this.cmtat, 'Frozen')
      .withArgs(this.address1, frozenTokens)
  }

  context('Freeze', function () {
    beforeEach(async function () {
      await this.cmtat.connect(this.admin).mint(this.address1, INITIAL_BALANCE)
    })

    it('testAdminCanFreezeAddress', async function () {
      const bindTest = await testFreeze.bind(this)
      await bindTest(this.admin)
    })

    it('testAdminCanFreezeAddressTwice', async function () {
      const bindTest = await testFreezeTwice.bind(this)
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

    it('testAdminCanUnfreezeAddressAndTransferMoreActiveBalance', async function () {
      // Arrange
      const bindTest = await testUnfreezeTotalAndTransferMoreActiveBalance.bind(
        this
      )
      await bindTest(this.admin)
    })

    it('testAdminCanUnfreezeAddressTwice', async function () {
      // Arrange
      const bindTest = await testUnfreezeTwice.bind(this)
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

    it('testCannotFreezeZeroAddress', async function () {
      await expect(
        this.cmtat
          .connect(this.admin)
          .freezePartialTokens(ZERO_ADDRESS, FREEZE_AMOUNT)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_ERC20EnforcementModule_ZeroAddressNotAllowed'
      )
    })

    it('testCannotUnfreezeZeroAddress', async function () {
      await expect(
        this.cmtat
          .connect(this.admin)
          .unfreezePartialTokens(ZERO_ADDRESS, UNFREEZE_AMOUNT)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_ERC20EnforcementModule_ZeroAddressNotAllowed'
      )
    })

    it('testCannotFreezeZeroAddressWithReason', async function () {
      if (!supportsReasonedEnforcement(this)) {
        return
      }
      await expect(
        freezePartialTokensCompat(
          this,
          this.admin,
          ZERO_ADDRESS,
          FREEZE_AMOUNT,
          REASON
        )
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_ERC20EnforcementModule_ZeroAddressNotAllowed'
      )
    })

    it('testCannotFreezeMoreThanAvailableBalance', async function () {
      await expect(
        this.cmtat
          .connect(this.admin)
          .freezePartialTokens(this.address1, INITIAL_BALANCE + 1)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_ERC20EnforcementModule_ValueExceedsAvailableBalance'
      )

      expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal(0)
    })

    it('testCannotUnfreezeZeroAddressWithReason', async function () {
      if (!supportsReasonedEnforcement(this)) {
        return
      }
      await expect(
        unfreezePartialTokensCompat(
          this,
          this.admin,
          ZERO_ADDRESS,
          UNFREEZE_AMOUNT,
          REASON
        )
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_ERC20EnforcementModule_ZeroAddressNotAllowed'
      )
    })

    it('testCannotUnfreezeMoreThanFrozenBalance', async function () {
      // Arrange: freeze a smaller amount than we attempt to unfreeze
      await this.cmtat
        .connect(this.admin)
        .freezePartialTokens(this.address1, FREEZE_AMOUNT)

      // Act + Assert
      await expect(
        this.cmtat
          .connect(this.admin)
          .unfreezePartialTokens(this.address1, FREEZE_AMOUNT + 1)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_ERC20EnforcementModule_ValueExceedsFrozenBalance'
      )

      // Assert: state unchanged on revert
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
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'ERC7943InsufficientUnfrozenBalance'
        )
        .withArgs(
          this.address1,
          AMOUNT_TO_TRANSFER,
          INITIAL_BALANCE - FREEZE_AMOUNT
        )
    })

    it('testCanSetFrozenTokensGreaterThanBalance', async function () {
      const frozenTokens = INITIAL_BALANCE + 1

      await this.cmtat
        .connect(this.admin)
        .setFrozenTokens(this.address1, frozenTokens)

      expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal(
        frozenTokens
      )
      if (!this.erc1404) {
        expect(
          await this.cmtat.detectTransferRestriction(
            this.address1,
            this.address2,
            1
          )
        ).to.equal(
          REJECTED_CODE_BASE_TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE
        )
        expect(
          await this.cmtat.detectTransferRestrictionFrom(
            this.admin,
            this.address1,
            this.address2,
            1
          )
        ).to.equal(
          REJECTED_CODE_BASE_TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE
        )
      }
      expect(await getActiveBalance(this, this.address1)).to.equal('0')
      expect(
        await this.cmtat.canTransfer(this.address1, this.address2, 1)
      ).to.equal(false)

      await expect(this.cmtat.connect(this.address1).transfer(this.address2, 1))
        .to.be.revertedWithCustomError(
          this.cmtat,
          'ERC7943InsufficientUnfrozenBalance'
        )
        .withArgs(this.address1, 1, 0)
    })

    it('testCanTransferZeroWhenFrozenTokensCoverBalance', async function () {
      const frozenTokens = INITIAL_BALANCE + 1

      await this.cmtat
        .connect(this.admin)
        .setFrozenTokens(this.address1, frozenTokens)

      expect(BigInt(await getActiveBalance(this, this.address1))).to.equal(0n)
      expect(
        await this.cmtat.canTransfer(this.address1, this.address2, 0)
      ).to.equal(true)

      // detectTransferRestriction must agree with the enforcement path: a zero-value
      // transfer succeeds, so the predictor must report it as unrestricted, not code 6
      if (!this.erc1404) {
        expect(
          await this.cmtat.detectTransferRestriction(
            this.address1,
            this.address2,
            0
          )
        ).to.equal(REJECTED_CODE_BASE_TRANSFER_OK)
        expect(
          await this.cmtat.detectTransferRestrictionFrom(
            this.admin,
            this.address1,
            this.address2,
            0
          )
        ).to.equal(REJECTED_CODE_BASE_TRANSFER_OK)
      }

      await expect(
        this.cmtat.connect(this.address1).transfer(this.address2, 0)
      ).to.not.be.reverted
    })

    it('testCanSetFrozenTokensToZeroFromNonZero', async function () {
      await this.cmtat
        .connect(this.admin)
        .setFrozenTokens(this.address1, FREEZE_AMOUNT)

      const logs = await this.cmtat
        .connect(this.admin)
        .setFrozenTokens(this.address1, 0)

      expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal(0)
      expect(await getActiveBalance(this, this.address1)).to.equal(
        INITIAL_BALANCE
      )
      expect(
        await this.cmtat.canTransfer(
          this.address1,
          this.address2,
          INITIAL_BALANCE
        )
      ).to.equal(true)

      await expect(logs)
        .to.emit(this.cmtat, 'TokensUnfrozen(address,uint256)')
        .withArgs(this.address1, FREEZE_AMOUNT)
      await expect(logs)
        .to.emit(this.cmtat, 'Frozen')
        .withArgs(this.address1, 0)
    })

    it('testCanForcedTransferWhenFrozenTokensGreaterThanBalance', async function () {
      const frozenTokens = INITIAL_BALANCE + 1
      const amount = 1

      await this.cmtat
        .connect(this.admin)
        .setFrozenTokens(this.address1, frozenTokens)

      await expect(
        forcedTransferCompat(
          this,
          this.admin,
          this.address1,
          this.address2,
          amount,
          REASON
        )
      ).to.not.be.reverted
      expect(await this.cmtat.balanceOf(this.address2)).to.equal(amount)
    })

    it('testCanMintToAccountAfterFrozenTokensGreaterThanBalance', async function () {
      const frozenTokens = INITIAL_BALANCE + 1

      await this.cmtat
        .connect(this.admin)
        .setFrozenTokens(this.address1, frozenTokens)

      await expect(
        this.cmtat.connect(this.admin).mint(this.address1, 2)
      ).to.not.be.reverted

      expect(await this.cmtat.balanceOf(this.address1)).to.equal(
        INITIAL_BALANCE + 2
      )
      expect(await getActiveBalance(this, this.address1)).to.equal(1)
      expect(
        await this.cmtat.canTransfer(this.address1, this.address2, 1)
      ).to.equal(true)
    })

    /*
     * Regression tests for NM-15/NM-17 (Nethermind AuditAgent v3.3.0-rc2).
     *
     * `_setFrozenTokens` must reject the zero address, exactly like
     * `_freezePartialTokens` / `_unfreezePartialTokens` already do. Without the
     * guard, a non-zero frozen amount on address(0) makes
     * `_checkActiveBalance(address(0), value)` return false for every value > 0
     * (balanceOf(address(0)) == 0), which reverts the common mint path used by
     * mint / batchMint / crosschainMint / burnAndMint.
     */
    it('testCannotSetFrozenTokensOnZeroAddress', async function () {
      await expect(
        this.cmtat.connect(this.admin).setFrozenTokens(ZERO_ADDRESS, 1)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_ERC20EnforcementModule_ZeroAddressNotAllowed'
      )

      expect(await this.cmtat.getFrozenTokens(ZERO_ADDRESS)).to.equal(0)
    })

    it('testSetFrozenTokensOnZeroAddressCannotBrickMint', async function () {
      await expect(
        this.cmtat.connect(this.admin).setFrozenTokens(ZERO_ADDRESS, 1)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_ERC20EnforcementModule_ZeroAddressNotAllowed'
      )

      // Issuance must remain fully available
      const balanceBefore = await this.cmtat.balanceOf(this.address2)
      await expect(this.cmtat.connect(this.admin).mint(this.address2, 1)).to.not
        .be.reverted
      expect(await this.cmtat.balanceOf(this.address2)).to.equal(
        balanceBefore + 1n
      )
    })

    it('testSetFrozenTokensOnZeroAddressCannotBrickBatchMint', async function () {
      await expect(
        this.cmtat.connect(this.admin).setFrozenTokens(ZERO_ADDRESS, 1)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_ERC20EnforcementModule_ZeroAddressNotAllowed'
      )

      const balance2Before = await this.cmtat.balanceOf(this.address2)
      const balance3Before = await this.cmtat.balanceOf(this.address3)
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchMint([this.address2.address, this.address3.address], [1, 2])
      ).to.not.be.reverted
      expect(await this.cmtat.balanceOf(this.address2)).to.equal(
        balance2Before + 1n
      )
      expect(await this.cmtat.balanceOf(this.address3)).to.equal(
        balance3Before + 2n
      )
    })

    it('testCannotSetFrozenTokensOnZeroAddressEvenToZero', async function () {
      // The zero address is never a valid target, whatever the value
      await expect(
        this.cmtat.connect(this.admin).setFrozenTokens(ZERO_ADDRESS, 0)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_ERC20EnforcementModule_ZeroAddressNotAllowed'
      )
    })

    it('testSetFrozenTokensStillWorksOnRegularAddress', async function () {
      // The guard must not regress the normal path
      await expect(
        this.cmtat
          .connect(this.admin)
          .setFrozenTokens(this.address1, FREEZE_AMOUNT)
      ).to.not.be.reverted
      expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal(
        FREEZE_AMOUNT
      )
      expect(await getActiveBalance(this, this.address1)).to.equal(
        INITIAL_BALANCE - FREEZE_AMOUNT
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
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'ERC7943InsufficientUnfrozenBalance'
        )
        .withArgs(
          this.address1,
          AMOUNT_TO_TRANSFER,
          INITIAL_BALANCE - FREEZE_AMOUNT
        )
    })
  })

  context('Set Address Frozen', function () {
    beforeEach(async function () {
      await this.cmtat.connect(this.admin).mint(this.address1, INITIAL_BALANCE)
    })

    it('testAdminCanFreezeAddress', async function () {
      const bindTest = await testSetFrozenTokens_Freeze.bind(this)
      await bindTest(this.admin)
    })

    it('testAdminCanFreezeAddressWithTokenFrozen', async function () {
      const bindTest = await testSetFrozenTokens_FreezeWithTokenFrozen.bind(
        this
      )
      await bindTest(this.admin)
    })

    it('testAdminCanFreezeAddressWithTokenFrozenDifferentLess', async function () {
      const bindTest =
        await testSetFrozenTokens_FreezeWithTokenFrozenDifferentLess.bind(this)
      await bindTest(this.admin)
    })

    it('testAdminCanFreezeAddressWithTokenFrozenDifferentMore', async function () {
      const bindTest =
        await testSetFrozenTokens_FreezeWithTokenFrozenDifferentMore.bind(this)
      await bindTest(this.admin)
    })

    it('testEnforcerRoleCanFreezeAddress', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(ERC20ENFORCER_ROLE, this.address2)

      const bindTest = await testSetFrozenTokens_Freeze.bind(this)
      await bindTest(this.address2)
    })

    it('testAdminCanUnfreezeAddress', async function () {
      // Arrange
      const bindTest = await testSetFrozenTokens_Unfreeze.bind(this)
      await bindTest(this.admin)
    })

    it('testEnforcerRoleCanUnfreezeAddress', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(ERC20ENFORCER_ROLE, this.address2)

      const bindTest = await testSetFrozenTokens_Unfreeze.bind(this)
      await bindTest(this.address2)
    })

    it('testCannotNonEnforcersetFrozenTokens', async function () {
      // Act
      await expect(
        this.cmtat
          .connect(this.address2)
          .setFrozenTokens(this.address1, FREEZE_AMOUNT)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, ERC20ENFORCER_ROLE)
      // Assert
      expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal(0)
    })

    it('testCannotTransferMoreThanActiveBalance', async function () {
      const AMOUNT_TO_TRANSFER = INITIAL_BALANCE - FREEZE_AMOUNT + 1
      // Act
      await this.cmtat
        .connect(this.admin)
        .setFrozenTokens(this.address1, FREEZE_AMOUNT)
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
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'ERC7943InsufficientUnfrozenBalance'
        )
        .withArgs(
          this.address1,
          AMOUNT_TO_TRANSFER,
          INITIAL_BALANCE - FREEZE_AMOUNT
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
        .setFrozenTokens(this.address1, FREEZE_AMOUNT)

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
        .setFrozenTokens(this.address1, FREEZE_AMOUNT)

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
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'ERC7943InsufficientUnfrozenBalance'
        )
        .withArgs(
          this.address1,
          AMOUNT_TO_TRANSFER,
          INITIAL_BALANCE - FREEZE_AMOUNT
        )
    })
  })
}
module.exports = ERC20EnforcementModuleCommon
