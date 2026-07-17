const { expect } = require('chai')
const { ethers } = require('hardhat')
const {
  deployCMTATStandalone,
  fixture,
  loadFixture
} = require('../deploymentUtils')

const VALUE = 10n

describe('PoC - burnFrom drops operator context before RuleEngine validation', function () {
  async function deployFixture () {
    const accounts = await loadFixture(fixture)
    const cmtat = await deployCMTATStandalone(
      accounts._.address,
      accounts.admin.address,
      accounts.deployerAddress.address
    )

    const holder = accounts.address2
    const recipient = accounts.address3
    const authorizedSpender = accounts.address1
    const unauthorizedBurner = accounts.attacker

    // RuleEngineMock rejects canTransferFrom/transferred(spender, ...) for every
    // non-zero spender except `authorizedSpender`, while allowing the
    // no-operator canTransfer/transferred(from, ...) path for VALUE.
    const RuleEngineMock = await ethers.getContractFactory('RuleEngineMock')
    const ruleEngine = await RuleEngineMock.deploy(authorizedSpender.address)
    await ruleEngine.waitForDeployment()

    await cmtat.connect(accounts.admin).setRuleEngine(await ruleEngine.getAddress())

    const burnerFromRole = await cmtat.BURNER_FROM_ROLE()
    await cmtat.connect(accounts.admin).grantRole(burnerFromRole, unauthorizedBurner.address)

    await cmtat.connect(accounts.admin).mint(holder.address, VALUE)
    await cmtat.connect(holder).approve(unauthorizedBurner.address, VALUE)

    return {
      cmtat,
      ruleEngine,
      holder,
      recipient,
      authorizedSpender,
      unauthorizedBurner
    }
  }

  it('should reject burnFrom when the RuleEngine rejects the actual burner/spender', async function () {
    const {
      cmtat,
      ruleEngine,
      holder,
      recipient,
      unauthorizedBurner
    } = await loadFixture(deployFixture)

    // Sanity check: the configured RuleEngine explicitly rejects this operator.
    expect(
      await ruleEngine.canTransferFrom(
        unauthorizedBurner.address,
        holder.address,
        ethers.ZeroAddress,
        VALUE
      )
    ).to.equal(false)

    // The token's spender-aware pre-check also reports that this burn-from
    // should be non-compliant.
    expect(
      await cmtat.canTransferFrom(
        unauthorizedBurner.address,
        holder.address,
        ethers.ZeroAddress,
        VALUE
      )
    ).to.equal(false)

    // Sibling path check: ordinary transferFrom carries _msgSender() into the
    // validation pipeline, so the same unauthorized operator is rejected.
    await expect(
      cmtat
        .connect(unauthorizedBurner)
        .transferFrom(holder.address, recipient.address, VALUE)
    )
      .to.be.revertedWithCustomError(ruleEngine, 'RuleEngine_InvalidTransfer')
      .withArgs(holder.address, recipient.address, VALUE)

    // Security expectation: burnFrom must be validated with the real spender as
    // well. On vulnerable code this DOES NOT revert: burnFrom spends the
    // allowance and CMTATBaseCommon._burnOverride calls _checkTransferred with
    // spender = address(0), selecting RuleEngine.transferred(from, to, value)
    // instead of transferred(spender, from, to, value).
    await expect(
      cmtat.connect(unauthorizedBurner).burnFrom(holder.address, VALUE)
    )
      .to.be.revertedWithCustomError(ruleEngine, 'RuleEngine_InvalidTransfer')
      .withArgs(holder.address, ethers.ZeroAddress, VALUE)
  })
})
