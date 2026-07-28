const { expect } = require('chai')

/*
 * Spender-aware dispatch of the RuleEngine `transferred` callback
 * ({ValidationModuleRuleEngine-_callRuleEngineTransferred}).
 *
 * The `spender != address(0)` branch selects the spender-aware 4-argument overload
 * `transferred(spender, from, to, value)` for a `transferFrom`, and the legacy 3-argument
 * overload `transferred(from, to, value)` for a direct `transfer` / `mint` / `burn`
 * (where the spender is address(0)). The 4-arg overload forwards the real spender to the
 * engine (`canTransferFrom` / spender-aware hooks); the 3-arg overload does not.
 *
 * These tests drive both paths through CMTAT with a recording RuleEngine and assert which
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
  })
}
module.exports = RuleEngineSpenderDispatchCommon
