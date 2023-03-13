const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
// TODO : Update the library
// const ethSigUtil = require('@metamask/eth-sig-util')
const ethSigUtil = require('eth-sig-util')
const Wallet = require('ethereumjs-wallet').default
const { DEFAULT_ADMIN_ROLE } = require('../utils')
const { should } = require('chai').should()

const NAME = 'MinimalForwarder'
const VERSION = '0.0.1'
const EIP712Domain = [
  { name: 'name', type: 'string' },
  { name: 'version', type: 'string' },
  { name: 'chainId', type: 'uint256' },
  { name: 'verifyingContract', type: 'address' }
]

function MetaTxModuleCommon (owner, address1) {
  context('Transferring without paying gas', function () {
    beforeEach(async function () {
      this.wallet = Wallet.generate()
      this.sender = web3.utils.toChecksumAddress(
        this.wallet.getAddressString()
      )

      this.domain = {
        name: NAME,
        version: VERSION,
        chainId: await web3.eth.getChainId(),
        verifyingContract: this.trustedForwarder.address
      }
      this.types = {
        EIP712Domain,
        ForwardRequest: [
          { name: 'from', type: 'address' },
          { name: 'to', type: 'address' },
          { name: 'value', type: 'uint256' },
          { name: 'gas', type: 'uint256' },
          { name: 'nonce', type: 'uint256' },
          { name: 'data', type: 'bytes' }
        ]
      }
      this.data = {
        types: this.types,
        domain: this.domain,
        primaryType: 'ForwardRequest'
      }

      await this.cmtat.mint(this.sender, 31, { from: owner })
      await this.cmtat.mint(address1, 32, { from: owner })
    })

    it('can send a transfer transaction without paying gas', async function () {
      const data = this.cmtat.contract.methods
        .transfer(address1, 11)
        .encodeABI()
      const req = {
        from: this.sender,
        to: this.cmtat.address,
        value: '0',
        gas: '100000',
        nonce: (await this.trustedForwarder.getNonce(this.sender)).toString(),
        data
      }
      // TODO : code for the new version of the library, it doesn't compile
      // const sign = ethSigUtil.signTypedData( {privateKey  : this.wallet.getPrivateKey(), data: { ...this.data, message: req }, version : 'V4'});
      const sign = ethSigUtil.signTypedMessage(this.wallet.getPrivateKey(), {
        data: { ...this.data, message: req }
      })
      const balanceBefore = await web3.eth.getBalance(this.sender)
      await this.trustedForwarder.execute(req, sign);
      (await this.cmtat.balanceOf(this.sender)).should.be.bignumber.equal(
        '20'
      );
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal('43')
      const balanceAfter = await web3.eth.getBalance(this.sender)
      balanceBefore.should.be.bignumber.equal(balanceAfter)
    })
  })
}
module.exports = MetaTxModuleCommon
