const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const ethSigUtil = require('eth-sig-util');
const Wallet = require('ethereumjs-wallet').default;
const { DEFAULT_ADMIN_ROLE } = require('../utils');
require('chai/register-should');

const CMTAT = artifacts.require('CMTAT');
const MinimalForwarderMock = artifacts.require('MinimalForwarderMock');

const NAME = 'MinimalForwarder';
const VERSION = '0.0.1';
const EIP712Domain = [
  { name: 'name', type: 'string' },
  { name: 'version', type: 'string' },
  { name: 'chainId', type: 'uint256' },
  { name: 'verifyingContract', type: 'address' },
];

contract('MetaTxModule', function ([_, owner, address1, address2, address3, trustedForwarder, defaultForwarder]) {
  beforeEach(async function () {
    this.cmtat = await CMTAT.new({ from: owner });
    this.cmtat.initialize(owner, defaultForwarder, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', { from: owner });
  });

  context('Owner', function () {
    it('can change the trustedForwarder', async function () {
      (await this.cmtat.isTrustedForwarder(trustedForwarder)).should.equal(false);
      (await this.cmtat.isTrustedForwarder(defaultForwarder)).should.equal(true);
      await this.cmtat.setTrustedForwarder(trustedForwarder, {from: owner});
      (await this.cmtat.isTrustedForwarder(trustedForwarder)).should.equal(true);
      (await this.cmtat.isTrustedForwarder(defaultForwarder)).should.equal(false);
    }); 

    it('reverts when calling from non-owner', async function () {
      await expectRevert(this.cmtat.setTrustedForwarder(trustedForwarder, { from: address1 }), 'AccessControl: account ' + address1.toLowerCase() + ' is missing role ' + DEFAULT_ADMIN_ROLE);
    });
  });

  context('Transferring without paying gas', function () {
    beforeEach(async function () {
      this.forwarder = await MinimalForwarderMock.new();
      await this.forwarder.initialize();
      this.cmtat.setTrustedForwarder(this.forwarder.address, {from: owner});
      this.wallet = Wallet.generate();
      this.sender = web3.utils.toChecksumAddress(this.wallet.getAddressString());

      this.domain = {
        name: NAME,
        version: VERSION,
        chainId: 1,
        verifyingContract: this.forwarder.address,
      };
      this.types = {
        EIP712Domain,
        ForwardRequest: [
          { name: 'from', type: 'address' },
          { name: 'to', type: 'address' },
          { name: 'value', type: 'uint256' },
          { name: 'gas', type: 'uint256' },
          { name: 'nonce', type: 'uint256' },
          { name: 'data', type: 'bytes' },
        ],
      };
      this.data = {
        types: this.types,
        domain: this.domain,
        primaryType: 'ForwardRequest',
      };

      await this.cmtat.mint(this.sender, 31, {from: owner});
      await this.cmtat.mint(address2, 32, {from: owner});
    });

    it('can send a transfer transaction without paying gas', async function () {
      const data = this.cmtat.contract.methods.transfer(address2, 11).encodeABI();

      const req = {
        from: this.sender,
        to: this.cmtat.address,
        value: '0',
        gas: '100000',
        nonce: (await this.forwarder.getNonce(this.sender)).toString(),
        data,
      };

      const sign = ethSigUtil.signTypedMessage(this.wallet.getPrivateKey(), { data: { ...this.data, message: req } })
      const balanceBefore = await web3.eth.getBalance(this.sender);
      await this.forwarder.execute(req, sign);
      (await this.cmtat.balanceOf(this.sender)).should.be.bignumber.equal('20');
      (await this.cmtat.balanceOf(address2)).should.be.bignumber.equal('43');
      const balanceAfter = await web3.eth.getBalance(this.sender);
      balanceBefore.should.be.bignumber.equal(balanceAfter);
    });
  });
});
