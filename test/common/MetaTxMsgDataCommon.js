const helpers = require('@nomicfoundation/hardhat-network-helpers')
const {
  getDomain
} = require('../../openzeppelin-contracts-upgradeable/test/helpers/eip712')
const { expect } = require('chai')

function MetaTxMsgDataCommon () {
  context('_msgData() coverage', function () {
    beforeEach(async function () {
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
    })

    it('returns correct msgData for direct call', async function () {
      const expectedData = this.cmtat.interface.encodeFunctionData('getMsgData')
      const result = await this.cmtat.getMsgData.staticCall()
      expect(result).to.equal(expectedData)
    })

    it('returns correct msgData when called through forwarder', async function () {
      const data = this.cmtat.interface.encodeFunctionData('getMsgData')
      const request = {
        from: await this.address1.getAddress(),
        to: this.cmtat.target,
        value: 0n,
        data: data,
        gas: 100000n,
        deadline: (await helpers.time.latest()) + 60,
        nonce: await this.forwarder.nonces(this.address1)
      }
      request.signature = await this.address1.signTypedData(
        this.domain,
        this.types,
        request
      )
      const tx = await this.forwarder.connect(this.address3).execute(request)
      const receipt = await tx.wait()
      // Parse MsgDataReturned event
      const log = receipt.logs.find(l => {
        try {
          return this.cmtat.interface.parseLog(l)?.name === 'MsgDataReturned'
        } catch {
          return false
        }
      })
      expect(log).to.not.be.undefined
      const parsedLog = this.cmtat.interface.parseLog(log)
      // Through forwarder, _msgData() should strip the appended sender address
      // so the returned data should match the original calldata
      expect(parsedLog.args.data).to.equal(data)
    })
  })
}
module.exports = MetaTxMsgDataCommon
