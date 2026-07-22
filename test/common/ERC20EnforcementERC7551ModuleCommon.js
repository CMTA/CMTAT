const { expect } = require('chai')

const REASON_STRING = 'testReason'
const REASON_EVENT = ethers.toUtf8Bytes(REASON_STRING)
const REASON = ethers.Typed.bytes(REASON_EVENT)

function ERC20EnforcementERC7551ModuleCommon () {
  context('ERC20 Enforcement ERC7551 Specific', function () {
    beforeEach(async function () {
      await this.cmtat.connect(this.admin).mint(this.address1, 50)
      await this.cmtat
        .connect(this.admin)
        .grantRole(await this.cmtat.ERC20ENFORCER_ROLE(), this.admin)
    })

    it('testForcedTransferWithReasonEmitsReasonedEvent', async function () {
      const amount = 10
      const logs = await this.cmtat
        .connect(this.admin)
        .forcedTransfer(this.address1, this.address2, amount, REASON)

      await expect(logs)
        .to.emit(
          this.cmtat,
          'ForcedTransfer(address,address,address,uint256,bytes)'
        )
        .withArgs(
          this.admin,
          this.address1,
          this.address2,
          amount,
          REASON_EVENT
        )
    })

    it('testFreezeWithReasonEmitsReasonedEvent', async function () {
      const amount = 10
      const logs = await this.cmtat
        .connect(this.admin)
        .freezePartialTokens(this.address1, amount, REASON)

      await expect(logs)
        .to.emit(this.cmtat, 'TokensFrozen(address,uint256,bytes)')
        .withArgs(this.address1, amount, REASON_EVENT)
    })

    it('testUnfreezeWithReasonEmitsReasonedEvent', async function () {
      const amount = 10
      await this.cmtat
        .connect(this.admin)
        .freezePartialTokens(this.address1, amount, REASON)

      const logs = await this.cmtat
        .connect(this.admin)
        .unfreezePartialTokens(this.address1, amount, REASON)

      await expect(logs)
        .to.emit(this.cmtat, 'TokensUnfrozen(address,uint256,bytes)')
        .withArgs(this.address1, amount, REASON_EVENT)
    })

    it('testGetActiveBalanceOf', async function () {
      await this.cmtat
        .connect(this.admin)
        .freezePartialTokens(this.address1, 20, REASON)

      expect(await this.cmtat.getActiveBalanceOf(this.address1)).to.equal(30)
    })
  })
}

module.exports = ERC20EnforcementERC7551ModuleCommon
