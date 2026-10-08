const { expect } = require('chai')
const {
  BURNER_FROM_ROLE,
  BURNER_SELF_ROLE
} = require('../../utils')

/*
 * Spender-aware dispatch of the RuleEngine `transferred` callback
 * ({ValidationModuleRuleEngine-_callRuleEngineTransferred}).
 *
 * The `spender != address(0)` branch selects the spender-aware 4-argument overload
 * `transferred(spender, from, to, value)`, and the legacy 3-argument overload
 * `transferred(from, to, value)` otherwise.
 *
 * Since v3.3.0 the only path with `spender == address(0)` is a direct `transfer`. Every other
 * path passes the caller as `spender` and therefore reaches the 4-argument overload:
 * - `transferFrom` (the approved spender);
 * - supply operations, with the operator as spender: `mint` / `batchMint`, `burn` / `batchBurn`,
 *   `burnFrom`, self `burn(uint256)`, `crosschainMint` / `crosschainBurn`
 *   (mint: `from == address(0)`, burn: `to == address(0)`);
 * - the minter `batchTransfer`.
 * Up to v3.2.0, supply operations and the minter transfer passed `address(0)` and reached the
 * 3-argument overload. This change is silent at the ABI level (both overloads are part of
 * `IRuleEngine`), so these tests pin the routing of every path.
 *
 * The tests drive each path through CMTAT with a recording RuleEngine and assert which
 * overload was invoked and which spender it received, so inverting the condition (or routing
 * the wrong overload) is caught - a gap that plain transfer tests leave open because both
 * overloads are permissive and otherwise indistinguishable.
 */
function RuleEngineSpenderDispatchCommon () {
  context('RuleEngine transferred - spender dispatch', function () {
    const BALANCE = 100n
    const AMOUNT = 10n

    beforeEach(async function () {
      this.recorderEngine = await ethers.deployContract(
        'RuleEngineSpenderRecorderMock'
      )
      // Mint before wiring the engine so the recorder only sees the call under test
      await this.cmtat.connect(this.admin).mint(this.address1, BALANCE)
      await this.cmtat
        .connect(this.admin)
        .setRuleEngine(this.recorderEngine.target)
    })

    it('testTransferFromUsesSpenderAwareOverload', async function () {
      // A non-zero spender (approved third party) must route to the 4-arg overload
      await this.cmtat.connect(this.address1).approve(this.address2, AMOUNT)
      await this.cmtat
        .connect(this.address2)
        .transferFrom(this.address1, this.address3, AMOUNT)

      expect(await this.recorderEngine.lastWasSpenderOverload()).to.equal(true)
      expect(await this.recorderEngine.lastSpender()).to.equal(
        this.address2.address
      )
    })

    it('testDirectTransferUsesLegacyOverload', async function () {
      // A direct transfer has spender == address(0) and must route to the 3-arg overload
      await this.cmtat.connect(this.address1).transfer(this.address3, AMOUNT)

      expect(await this.recorderEngine.lastWasSpenderOverload()).to.equal(false)
      expect(await this.recorderEngine.lastSpender()).to.equal(
        ethers.ZeroAddress
      )
    })

    /* ====== Supply operations: operator forwarded as spender (since v3.3.0) ====== */

    async function expectSpenderOverload (engine, operator, calls = 1n) {
      expect(await engine.lastWasSpenderOverload()).to.equal(true)
      expect(await engine.lastSpender()).to.equal(operator.address)
      expect(await engine.callCount()).to.equal(calls)
    }

    it('testMintUsesSpenderAwareOverloadWithOperator', async function () {
      await this.cmtat.connect(this.admin).mint(this.address2, AMOUNT)
      await expectSpenderOverload(this.recorderEngine, this.admin)
    })

    it('testBatchMintUsesSpenderAwareOverloadWithOperator', async function () {
      await this.cmtat
        .connect(this.admin)
        .batchMint([this.address2, this.address3], [AMOUNT, AMOUNT])
      await expectSpenderOverload(this.recorderEngine, this.admin, 2n)
    })

    it('testBurnUsesSpenderAwareOverloadWithOperator', async function () {
      await this.cmtat
        .connect(this.admin)
        ['burn(address,uint256)'](this.address1, AMOUNT)
      await expectSpenderOverload(this.recorderEngine, this.admin)
    })

    it('testBatchBurnUsesSpenderAwareOverloadWithOperator', async function () {
      await this.cmtat
        .connect(this.admin)
        ['batchBurn(address[],uint256[])']([this.address1], [AMOUNT])
      await expectSpenderOverload(this.recorderEngine, this.admin)
    })

    it('testBurnFromUsesSpenderAwareOverloadWithOperator', async function () {
      await this.cmtat
        .connect(this.admin)
        .grantRole(BURNER_FROM_ROLE, this.address2)
      await this.cmtat.connect(this.address1).approve(this.address2, AMOUNT)
      await this.cmtat
        .connect(this.address2)
        .burnFrom(this.address1, AMOUNT)
      await expectSpenderOverload(this.recorderEngine, this.address2)
    })

    it('testSelfBurnUsesSpenderAwareOverloadWithHolder', async function () {
      await this.cmtat
        .connect(this.admin)
        .grantRole(BURNER_SELF_ROLE, this.address1)
      await this.cmtat.connect(this.address1)['burn(uint256)'](AMOUNT)
      await expectSpenderOverload(this.recorderEngine, this.address1)
    })

    it('testCrosschainMintUsesSpenderAwareOverloadWithOperator', async function () {
      await this.cmtat
        .connect(this.admin)
        .crosschainMint(this.address2, AMOUNT)
      await expectSpenderOverload(this.recorderEngine, this.admin)
    })

    it('testCrosschainBurnUsesSpenderAwareOverloadWithOperator', async function () {
      await this.cmtat
        .connect(this.admin)
        .crosschainBurn(this.address1, AMOUNT)
      await expectSpenderOverload(this.recorderEngine, this.admin)
    })

    it('testMinterBatchTransferUsesSpenderAwareOverloadWithOperator', async function () {
      // The minter transfers its own tokens: fund it before the recorder is reset
      await this.cmtat
        .connect(this.admin)
        .setRuleEngine(ethers.ZeroAddress)
      await this.cmtat.connect(this.admin).mint(this.admin, BALANCE)
      await this.cmtat
        .connect(this.admin)
        .setRuleEngine(this.recorderEngine.target)

      await this.cmtat
        .connect(this.admin)
        .batchTransfer([this.address2], [AMOUNT])
      await expectSpenderOverload(this.recorderEngine, this.admin)
    })
  })
}
module.exports = RuleEngineSpenderDispatchCommon
