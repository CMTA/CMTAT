const { expect } = require('chai')

describe('Standard - RuleEngineMock - Stateful Holder Rule', function () {
  beforeEach(async function () {
    [this.admin, this.address1, this.address2] = await ethers.getSigners()
    this.ruleEngineMock = await ethers.deployContract('RuleEngineMock', [
      this.admin.address
    ])
    const holderTrackerRuleAddress =
      await this.ruleEngineMock.holderTrackerRule()
    this.holderTrackerRule = await ethers.getContractAt(
      'RuleTokenHolderTracker',
      holderTrackerRuleAddress
    )
  })

  it('tracks holder balances through spender-aware transferred hook', async function () {
    // Mint-like flow: from == address(0)
    await this.ruleEngineMock['transferred(address,address,address,uint256)'](
      this.admin.address,
      ethers.ZeroAddress,
      this.address1.address,
      10n
    )

    // Transfer-like flow
    await this.ruleEngineMock['transferred(address,address,address,uint256)'](
      this.admin.address,
      this.address1.address,
      this.address2.address,
      6n
    )

    // Burn-like flow: to == address(0)
    await this.ruleEngineMock['transferred(address,address,address,uint256)'](
      this.admin.address,
      this.address2.address,
      ethers.ZeroAddress,
      2n
    )

    expect(
      await this.holderTrackerRule.trackedBalance(this.address1.address)
    ).to.equal(4n)
    expect(
      await this.holderTrackerRule.trackedBalance(this.address2.address)
    ).to.equal(4n)
    expect(
      await this.holderTrackerRule.isHolder(this.address1.address)
    ).to.equal(true)
    expect(
      await this.holderTrackerRule.isHolder(this.address2.address)
    ).to.equal(true)
    expect(await this.holderTrackerRule.holdersCount()).to.equal(2n)
  })

  it('removes holder status when tracked balance returns to zero', async function () {
    await this.ruleEngineMock['transferred(address,address,address,uint256)'](
      this.admin.address,
      ethers.ZeroAddress,
      this.address1.address,
      10n
    )

    await this.ruleEngineMock['transferred(address,address,address,uint256)'](
      this.admin.address,
      this.address1.address,
      this.address2.address,
      6n
    )

    await this.ruleEngineMock['transferred(address,address,address,uint256)'](
      this.admin.address,
      this.address2.address,
      ethers.ZeroAddress,
      6n
    )

    expect(
      await this.holderTrackerRule.trackedBalance(this.address2.address)
    ).to.equal(0n)
    expect(
      await this.holderTrackerRule.isHolder(this.address2.address)
    ).to.equal(false)
    expect(await this.holderTrackerRule.holdersCount()).to.equal(1n)
  })
})
