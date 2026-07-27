const helpers = require('@nomicfoundation/hardhat-network-helpers')
const { expect } = require('chai')

function PermitModuleCommon () {
  context('Permit (ERC-2612)', function () {
    const PERMIT_VALUE = 100n

    beforeEach(async function () {
      this.permitOwner = this.address1
      this.permitSpender = this.address2

      const network = await ethers.provider.getNetwork()
      this.permitDomain = {
        name: await this.cmtat.name(),
        version: '1',
        chainId: network.chainId,
        verifyingContract: this.cmtat.target
      }
      this.permitTypes = {
        Permit: [
          { name: 'owner', type: 'address' },
          { name: 'spender', type: 'address' },
          { name: 'value', type: 'uint256' },
          { name: 'nonce', type: 'uint256' },
          { name: 'deadline', type: 'uint256' }
        ]
      }

      this.signPermit = async (override = {}, signer = this.permitOwner) => {
        const owner = await signer.getAddress()
        const spender = await this.permitSpender.getAddress()
        const nonce = await this.cmtat.nonces(owner)
        const deadline = (await helpers.time.latest()) + 3600
        const message = {
          owner,
          spender,
          value: PERMIT_VALUE,
          nonce,
          deadline,
          ...override
        }
        const signature = await signer.signTypedData(
          this.permitDomain,
          this.permitTypes,
          message
        )
        const sig = ethers.Signature.from(signature)
        return { ...message, v: sig.v, r: sig.r, s: sig.s }
      }
    })

    it('updates allowance with a valid permit', async function () {
      const permit = await this.signPermit()
      const owner = await this.permitOwner.getAddress()
      const spender = await this.permitSpender.getAddress()
      const nonceBefore = await this.cmtat.nonces(owner)

      await this.cmtat
        .connect(this.address3)
        .permit(
          owner,
          spender,
          permit.value,
          permit.deadline,
          permit.v,
          permit.r,
          permit.s
        )

      expect(await this.cmtat.allowance(owner, spender)).to.equal(PERMIT_VALUE)
      expect(await this.cmtat.nonces(owner)).to.equal(nonceBefore + 1n)
    })

    it('reverts with expired deadline', async function () {
      const expiredDeadline = (await helpers.time.latest()) - 1
      const permit = await this.signPermit({ deadline: expiredDeadline })
      const owner = await this.permitOwner.getAddress()
      const spender = await this.permitSpender.getAddress()

      await expect(
        this.cmtat
          .connect(this.address3)
          .permit(
            owner,
            spender,
            permit.value,
            permit.deadline,
            permit.v,
            permit.r,
            permit.s
          )
      ).to.be.revertedWithCustomError(this.cmtat, 'ERC2612ExpiredSignature')
    })

    it('reverts when paused', async function () {
      const permit = await this.signPermit()
      const owner = await this.permitOwner.getAddress()
      const spender = await this.permitSpender.getAddress()

      await this.cmtat.connect(this.admin).pause()

      await expect(
        this.cmtat
          .connect(this.address3)
          .permit(
            owner,
            spender,
            permit.value,
            permit.deadline,
            permit.v,
            permit.r,
            permit.s
          )
      ).to.be.revertedWithCustomError(this.cmtat, 'EnforcedPause')
    })

    it('reverts when owner is frozen', async function () {
      const permit = await this.signPermit()
      const owner = await this.permitOwner.getAddress()
      const spender = await this.permitSpender.getAddress()

      await this.cmtat.connect(this.admin).setAddressFrozen(owner, true)

      await expect(
        this.cmtat
          .connect(this.address3)
          .permit(
            owner,
            spender,
            permit.value,
            permit.deadline,
            permit.v,
            permit.r,
            permit.s
          )
      )
        .to.be.revertedWithCustomError(this.cmtat, 'ERC7943CannotSend')
        .withArgs(owner)
    })

    it('reverts when spender is frozen', async function () {
      const permit = await this.signPermit()
      const owner = await this.permitOwner.getAddress()
      const spender = await this.permitSpender.getAddress()

      await this.cmtat.connect(this.admin).setAddressFrozen(spender, true)

      await expect(
        this.cmtat
          .connect(this.address3)
          .permit(
            owner,
            spender,
            permit.value,
            permit.deadline,
            permit.v,
            permit.r,
            permit.s
          )
      )
        .to.be.revertedWithCustomError(this.cmtat, 'ERC7943CannotSend')
        .withArgs(spender)
    })

    // NM-3 / NM-8: a zero-value permit is a *revocation* and must stay available even while paused
    // or while the owner/spender is frozen — the same carve-out already tested for `approve`.
    async function grantThenExpectZeroValuePermitAllowed (ctx, restrict) {
      const owner = await ctx.permitOwner.getAddress()
      const spender = await ctx.permitSpender.getAddress()
      // Set a non-zero allowance first (unrestricted)
      const grant = await ctx.signPermit()
      await ctx.cmtat
        .connect(ctx.address3)
        .permit(owner, spender, grant.value, grant.deadline, grant.v, grant.r, grant.s)
      expect(await ctx.cmtat.allowance(owner, spender)).to.equal(PERMIT_VALUE)
      // Apply the restriction, then revoke with a zero-value permit
      await restrict(owner, spender)
      const revoke = await ctx.signPermit({ value: 0n })
      await expect(
        ctx.cmtat
          .connect(ctx.address3)
          .permit(owner, spender, revoke.value, revoke.deadline, revoke.v, revoke.r, revoke.s)
      ).to.not.be.reverted
      expect(await ctx.cmtat.allowance(owner, spender)).to.equal(0n)
    }

    it('allows a zero-value permit (revocation) while paused', async function () {
      await grantThenExpectZeroValuePermitAllowed(this, async () => {
        await this.cmtat.connect(this.admin).pause()
      })
    })

    it('allows a zero-value permit (revocation) when the owner is frozen', async function () {
      await grantThenExpectZeroValuePermitAllowed(this, async (owner) => {
        await this.cmtat.connect(this.admin).setAddressFrozen(owner, true)
      })
    })

    it('allows a zero-value permit (revocation) when the spender is frozen', async function () {
      await grantThenExpectZeroValuePermitAllowed(this, async (owner, spender) => {
        await this.cmtat.connect(this.admin).setAddressFrozen(spender, true)
      })
    })
  })
}

module.exports = PermitModuleCommon
