const { BN, time } = require('@openzeppelin/test-helpers')
const { getDomain, domainType } = require('../../openzeppelin-contracts-upgradeable/test/helpers/eip712');
// TODO : Update the library
// const ethSigUtil = require('@metamask/eth-sig-util')
const ethSigUtil = require('eth-sig-util')
const Wallet = require('ethereumjs-wallet').default
const { ERC2771ForwarderDomain } = require('../utils')
const { should } = require('chai').should()
const { expect } = require('chai')
const VERSION = '0.0.1'
const EIP712Domain = [
  { name: 'name', type: 'string' },
  { name: 'version', type: 'string' },
  { name: 'chainId', type: 'uint256' },
  { name: 'verifyingContract', type: 'address' },
  { name: 'salt', type: 'bytes32' },
]

function MetaTxModuleCommon (owner, address1) {
  context('Transferring without paying gas', function () {
    const AMOUNT_TO_TRANSFER = new BN(11)
    const ALICE_INITIAL_BALANCE = new BN(31)
    const ADDRESS1_INITIAL_BALANCE = new BN(32)
    
    beforeEach(async function () {
      this.aliceWallet = Wallet.generate()
      this.aliceAddress = web3.utils.toChecksumAddress(this.aliceWallet.getAddressString())

      this.domain = await getDomain(this.forwarder); 

      this.types = {
        EIP712Domain: domainType(this.domain),
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

      /*this.data = {
        types: this.types,
        domain: this.domain,
        primaryType: 'ForwardRequest'
      }*/

      await this.cmtat.mint(this.aliceAddress, ALICE_INITIAL_BALANCE, { from: owner })
      await this.cmtat.mint(address1, ADDRESS1_INITIAL_BALANCE, { from: owner });
      (await this.cmtat.balanceOf(this.aliceAddress)).should.be.bignumber.equal(
        ALICE_INITIAL_BALANCE
      );
      this.timestamp = await time.latest()
      const data = this.cmtat.contract.methods
        .transfer(address1, AMOUNT_TO_TRANSFER)
        .encodeABI()
      this.request = {
        from: this.aliceAddress,
        to: this.cmtat.address,
        value: '0',
        gas: '100000',
        data,
        deadline: this.timestamp.toNumber() + 180 // 3 minute
      }
      this.requestData = {
        ...this.request,
        nonce: (await this.forwarder.nonces(this.aliceAddress)).toString()
      }

      this.forgeData = request => ({
        types: this.types,
        domain: this.domain,
        primaryType: 'ForwardRequest',
        message: { ...this.requestData, ...request },
      })

      this.sign = (privateKey, request) =>
        ethSigUtil.signTypedMessage(privateKey, {
          data: this.forgeData(request)
        })

      this.requestData.signature = this.sign(this.aliceWallet.getPrivateKey())
    })

    it('returns true without altering the nonce', async function () {
      expect(await this.forwarder.nonces(this.requestData.from)).to.be.bignumber.equal(
        web3.utils.toBN(this.requestData.nonce),
      )
      expect(await this.forwarder.verify(this.requestData)).to.be.equal(true)
      expect(await this.forwarder.nonces(this.requestData.from)).to.be.bignumber.equal(
        web3.utils.toBN(this.requestData.nonce),
      )
    })

    it('can send a transfer transaction without paying gas', async function () {
      // TODO : code for the new version of the library, it doesn't compile
      // const sign = ethSigUtil.signTypedData( {privateKey  : this.wallet.getPrivateKey(), data: { ...this.data, message: req }, version : 'V4'});
      const balanceEtherBefore = await web3.eth.getBalance(this.aliceAddress);
      (await this.cmtat.balanceOf(this.aliceAddress)).should.be.bignumber.equal(
        ALICE_INITIAL_BALANCE
      );
      await this.forwarder.execute(this.requestData);
      (await this.cmtat.balanceOf(this.aliceAddress)).should.be.bignumber.equal(
        ALICE_INITIAL_BALANCE.sub(AMOUNT_TO_TRANSFER) 
      );
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal(ADDRESS1_INITIAL_BALANCE.add(AMOUNT_TO_TRANSFER))
      const balanceAfter = await web3.eth.getBalance(this.aliceAddress)
      balanceEtherBefore.should.be.bignumber.equal(balanceAfter)
    })
  })
}
module.exports = MetaTxModuleCommon
