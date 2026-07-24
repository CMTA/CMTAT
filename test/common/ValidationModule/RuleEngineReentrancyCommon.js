const { expect } = require('chai')

/*
 * NM-7 / NM-9 / NM-11 / NM-16 / NM-18 (Nethermind AuditAgent v3.3.0-rc2).
 *
 * `_checkTransferred` performs the active-balance (frozen) check and then calls
 * `ruleEngine.transferred(...)` BEFORE `ERC20Upgradeable._transfer` moves any balance.
 * A rule engine that reenters the token during that callback is validated against the
 * same pre-transfer snapshot, so without a guard the outer and inner transfers each pass
 * the frozen-balance check and together move more than the unfrozen amount, breaking the
 * `frozenTokens <= balanceOf` invariant.
 *
 * Reproduced before the fix: balance 100 / frozen 60 / active 40, an outer transferFrom of
 * 40 plus a nested transferFrom of 40 moved 80 and left frozen(60) > balance(20).
 *
 * The RuleEngine is a trusted, admin-set component, so this is defence in depth rather than
 * a live vulnerability — but the guard makes the invariant hold even if a rule engine is
 * compromised or hands control to untrusted code.
 */
function RuleEngineReentrancyCommon () {
  context('RuleEngine reentrancy (NM-7 cluster)', function () {
    const BALANCE = 100n
    const FROZEN = 60n
    const ACTIVE = BALANCE - FROZEN // 40

    beforeEach(async function () {
      this.attackEngine = await ethers.deployContract('RuleEngineReentrantMock')

      await this.cmtat.connect(this.admin).mint(this.address1, BALANCE)
      await this.cmtat
        .connect(this.admin)
        .setFrozenTokens(this.address1, FROZEN)

      // The attacker is an approved spender for the full balance
      await this.cmtat.connect(this.address1).approve(this.address2, BALANCE)
      // NM-9 precondition: the rule engine itself holds an allowance from the holder, so its
      // nested transferFrom is authorized. (Equivalently, an engine that calls attacker-controlled
      // code lets the attacker's own allowance be used - NM-16.)
      await this.cmtat
        .connect(this.address1)
        .approve(this.attackEngine.target, BALANCE)

      await this.cmtat
        .connect(this.admin)
        .setRuleEngine(this.attackEngine.target)

      this.arm = async () =>
        this.attackEngine.arm(
          this.cmtat.target,
          this.address1.address,
          this.address2.address,
          ACTIVE
        )
    })

    it('testFrozenTokensCannotBeDrainedByReentrantRuleEngine', async function () {
      await this.arm()

      // Outer transfer of exactly the unfrozen amount; the engine attempts a second one
      await this.cmtat
        .connect(this.address2)
        .transferFrom(this.address1, this.address2, ACTIVE)

      // Only the legitimate unfrozen amount moved - not twice it
      expect(await this.cmtat.balanceOf(this.address2)).to.equal(ACTIVE)
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(
        BALANCE - ACTIVE
      )
      // The freeze invariant holds
      expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal(FROZEN)
      expect(await this.cmtat.getFrozenTokens(this.address1)).to.be.lte(
        await this.cmtat.balanceOf(this.address1)
      )
    })

    it('testReentrantRuleEngineCallbackIsRejected', async function () {
      await this.arm()

      await this.cmtat
        .connect(this.address2)
        .transferFrom(this.address1, this.address2, ACTIVE)

      // The engine did attempt the nested call, and the guard rejected it
      expect(await this.attackEngine.reentered()).to.equal(true)
      expect(await this.attackEngine.reentrySucceeded()).to.equal(false)
    })

    it('testReentrantCallRevertsWithDedicatedError', async function () {
      await this.arm()
      // Let the nested revert bubble up instead of being swallowed by the engine
      await this.attackEngine.setBubbleRevert(true)

      await expect(
        this.cmtat
          .connect(this.address2)
          .transferFrom(this.address1, this.address2, ACTIVE)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'ReentrancyGuardReentrantCall'
      )

      // Nothing moved
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(BALANCE)
      expect(await this.cmtat.balanceOf(this.address2)).to.equal(0n)
    })

    it('testReentrancyIsAlsoBlockedOnTransfer', async function () {
      // Same guard on the direct transfer path (spender == address(0), 3-arg callback)
      await this.arm()
      await this.attackEngine.setBubbleRevert(true)

      await expect(
        this.cmtat.connect(this.address1).transfer(this.address3, 1n)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'ReentrancyGuardReentrantCall'
      )
    })

    it('testNonReentrantRuleEngineTransferStillWorks', async function () {
      // Engine left unarmed: a normal transfer through the same engine must be unaffected
      await expect(
        this.cmtat
          .connect(this.address2)
          .transferFrom(this.address1, this.address2, ACTIVE)
      ).to.not.be.reverted

      expect(await this.cmtat.balanceOf(this.address1)).to.equal(
        BALANCE - ACTIVE
      )
      expect(await this.cmtat.balanceOf(this.address2)).to.equal(ACTIVE)
    })

    it('testConsecutiveTransfersAreNotBlockedByTheGuard', async function () {
      // The guard must be released after each callback, not leak across calls
      await this.cmtat
        .connect(this.address2)
        .transferFrom(this.address1, this.address2, 10n)
      await expect(
        this.cmtat
          .connect(this.address2)
          .transferFrom(this.address1, this.address2, 10n)
      ).to.not.be.reverted
      expect(await this.cmtat.balanceOf(this.address2)).to.equal(20n)
    })

    it('testBatchOperationsAreNotBlockedByTheGuard', async function () {
      // batchMint invokes the hook once per item in a single transaction
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchMint(
            [this.address2.address, this.address3.address],
            [10n, 20n]
          )
      ).to.not.be.reverted
    })
  })
}
module.exports = RuleEngineReentrancyCommon
