const { BN, time } = require('@openzeppelin/test-helpers')
const {
  getDomain,
  domainType
} = require('../../openzeppelin-contracts-upgradeable/test/helpers/eip712')
// TODO : Update the library
// const ethSigUtil = require('@metamask/eth-sig-util')
const { expect } = require('chai')
const { waffle} = require("hardhat");
function MetaTxModuleCommon (owner, address1) {
  context('Transferring without paying gas', function () {
    const AMOUNT_TO_TRANSFER = 11n
    const ALICE_INITIAL_BALANCE = 31n
    const ADDRESS1_INITIAL_BALANCE = 32n

    beforeEach(async function () {
      this.aliceWallet = ethers.Wallet.createRandom()
      this.aliceAddress = this.aliceWallet.address

      this.domain = await getDomain(this.forwarder)

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
      await this.cmtat.connect(this.admin).mint(this.aliceAddress, ALICE_INITIAL_BALANCE)
      await this.cmtat.connect(this.admin).mint(this.address1, ADDRESS1_INITIAL_BALANCE);
      expect(await this.cmtat.balanceOf(this.aliceAddress)).to.equal(
        ALICE_INITIAL_BALANCE
      )
     // this.timestamp = await time.latest()*/
      const data = this.cmtat.ADDRESS1_INITIAL_BALANCE
        .transfer(address1, AMOUNT_TO_TRANSFER)
        .encodeABI()
      this.request = {
        from: this.aliceAddress,
        to: this.cmtat.address,
        value: 0n,
        gas: 100000n,
        data,
        deadline: this.timestamp.toNumber() + 180 // 3 minute
      }
      this.requestData = {
        ...this.request,
        nonce: (await this.forwarder.nonces(this.aliceAddress)).toString()
      }

      this.forgeData = (request) => ({
        types: this.types,
        domain: this.domain,
        primaryType: 'ForwardRequest',
        message: { ...this.requestData, ...request }
      })

      /*this.sign = (privateKey, request) =>
        ethSigUtil.signTypedMessage(privateKey, {
          data: this.forgeData(request)
        })*/

      this.requestData.signature = this.sign(this.aliceWallet.getPrivateKey())
    })

    it('returns true without altering the nonce', async function () {
      /*expect(
        await this.forwarder.nonces(this.requestData.from)
      ).to.equal(web3.utils.toBN(this.requestData.nonce))
      expect(await this.forwarder.verify(this.requestData)).to.be.equal(true)
      expect(
        await this.forwarder.nonces(this.requestData.from)
      ).to.equal(web3.utils.toBN(this.requestData.nonce))*/
    })

    it('can send a transfer transaction without paying gas', async function () {
      // TODO : code for the new version of the library, it doesn't compile
      // const sign = ethSigUtil.signTypedData( {privateKey  : this.wallet.getPrivateKey(), data: { ...this.data, message: req }, version : 'V4'});
      const provider =  await ethers.getDefaultProvider();;
      const balanceEtherBefore = await  provider.getBalance(this.aliceAddress);
      expect(await this.cmtat.balanceOf(this.aliceAddress)).to.equal(
        ALICE_INITIAL_BALANCE
      )
      await this.forwarder.execute(this.requestData);
      expect(await this.cmtat.balanceOf(this.aliceAddress)).to.equal(
        ALICE_INITIAL_BALANCE.sub(AMOUNT_TO_TRANSFER)
      );
      expect(await this.cmtat.balanceOf(address1)).to.equal(
        ADDRESS1_INITIAL_BALANCE.add(AMOUNT_TO_TRANSFER)
      )
      const balanceAfter = await  ethers.getBalance(this.aliceAddress)
      expect(balanceEtherBefore).to.equal(balanceAfter)
    })
  })
}
module.exports = MetaTxModuleCommon
