const helpers = require('@nomicfoundation/hardhat-network-helpers')
const {
  getDomain,
  ForwardRequest
} = require('../../openzeppelin-contracts-upgradeable/test/helpers/eip712')
const { expect } = require('chai')
const { waffle } = require('hardhat')
function MetaTxModuleCommon () {
  context('Transferring without paying gas', function () {
    const AMOUNT_TO_TRANSFER = 11n
    const ADDRESS1_INITIAL_BALANCE = 31n
    const ADDRESS2_INITIAL_BALANCE = 32n

    beforeEach(async function () {
      // From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/test/metatx/ERC2771Forwarder.test.js
      this.domain = await getDomain(this.forwarder)
      this.types = {
        ForwardRequest: [
          { name: 'from', type: 'address' },
          { name: 'to', type: 'address' },
          { name: 'value', type: 'uint256' },
          { name: 'gas', type: 'uint256' },
          { name: 'nonce', type: 'uint256' },
          { name: 'deadline', type: 'uint48' },
          { name: 'data', type: 'bytes' }
        ]
      }
      await this.cmtat
        .connect(this.admin)
        .mint(this.address1, ADDRESS1_INITIAL_BALANCE)
      await this.cmtat
        .connect(this.admin)
        .mint(this.address2, ADDRESS2_INITIAL_BALANCE)
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(
        ADDRESS1_INITIAL_BALANCE
      )
      this.data = this.cmtat.interface.encodeFunctionData('transfer', [
        this.address2.address,
        AMOUNT_TO_TRANSFER
      ])
      this.forgeRequest = async (override = {}, signer = this.address1) => {
        const req = {
          from: await signer.getAddress(),
          to: this.cmtat.target,
          value: 0n,
          data: this.data,
          gas: 100000n,
          deadline: (await helpers.time.latest()) + 60,
          nonce: await this.forwarder.nonces(this.address1),
          ...override
        }
        req.signature = await signer.signTypedData(
          this.domain,
          this.types,
          req
        )
        return req
      }
    })

    it('returns true without altering the nonce', async function () {
      const request = await this.forgeRequest()
      expect(await this.forwarder.nonces(request.from)).to.equal(request.nonce)
      expect(await this.forwarder.verify(request)).to.be.equal(true)
      expect(await this.forwarder.nonces(request.from)).to.equal(request.nonce)
    })

    it('can send a transfer transaction without paying gas', async function () {
      const provider = await ethers.getDefaultProvider()
      const balanceEtherBefore = await provider.getBalance(this.address1)
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(
        ADDRESS1_INITIAL_BALANCE
      )
      const request = await this.forgeRequest()
      await this.forwarder.connect(this.address3).execute(request)
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(
        ADDRESS1_INITIAL_BALANCE - AMOUNT_TO_TRANSFER
      )
      expect(await this.cmtat.balanceOf(this.address2)).to.equal(
        ADDRESS2_INITIAL_BALANCE + AMOUNT_TO_TRANSFER
      )
      const balanceAfter = await provider.getBalance(this.address1)
      expect(balanceEtherBefore).to.equal(balanceAfter)
    })
  })
}
module.exports = MetaTxModuleCommon
