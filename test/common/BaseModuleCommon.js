const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { DEFAULT_ADMIN_ROLE } = require('../utils')
const { should } = require('chai').should()

function BaseModuleCommon (owner, address1, address2, address3, proxyTest) {
  context('Token structure', function () {
    it('testHasTheDefinedTokenId', async function () {
      // Act + Assert
      (await this.cmtat.tokenId()).should.equal('CMTAT_ISIN')
    })
    it('testHasTheDefinedTerms', async function () {
      // Act + Assert
      (await this.cmtat.terms()).should.equal('https://cmta.ch')
    })
    it('testAdminCanChangeTokenId', async function () {
      // Arrange
      (await this.cmtat.tokenId()).should.equal('CMTAT_ISIN');
      // Act
      ({ logs: this.logs } = await this.cmtat.setTokenId('CMTAT_TOKENID', { from: owner }));
      // Assert
      (await this.cmtat.tokenId()).should.equal('CMTAT_TOKENID')
      expectEvent.inLogs(this.logs, 'TokenId', {
        newTokenIdIndexed: web3.utils.sha3('CMTAT_TOKENID'),
        newTokenId: 'CMTAT_TOKENID'
      })
    })
    it('testCannotNonAdminChangeTokenId', async function () {
      // Arrange - Assert
      (await this.cmtat.tokenId()).should.equal('CMTAT_ISIN')
      // Act
      await expectRevert(
        this.cmtat.setTokenId('CMTAT_TOKENID', { from: address1 }),
        'AccessControl: account ' +
          address1.toLowerCase() +
          ' is missing role ' +
          DEFAULT_ADMIN_ROLE
      );
      // Assert
      (await this.cmtat.tokenId()).should.equal('CMTAT_ISIN')
    })
    it('testAdminCanUpdateTerms', async function () {
      // Arrange - Assert
      (await this.cmtat.terms()).should.equal('https://cmta.ch');
      // Act
      ({ logs: this.logs } = await this.cmtat.setTerms('https://cmta.ch/terms', { from: owner }));
      // Assert
      (await this.cmtat.terms()).should.equal('https://cmta.ch/terms')
      expectEvent.inLogs(this.logs, 'Term', {
        newTermIndexed: web3.utils.sha3('https://cmta.ch/terms'),
        newTerm: 'https://cmta.ch/terms'
      })
    })
    it('testCannotNonAdminUpdateTerms', async function () {
      // Arrange - Assert
      (await this.cmtat.terms()).should.equal('https://cmta.ch')
      // Act
      await expectRevert(
        this.cmtat.setTerms('https://cmta.ch/terms', { from: address1 }),
        'AccessControl: account ' +
          address1.toLowerCase() +
          ' is missing role ' +
          DEFAULT_ADMIN_ROLE
      );
      // Assert
      (await this.cmtat.terms()).should.equal('https://cmta.ch')
    })
    it('testAdminCanUpdateInformation', async function () {
      // Arrange - Assert
      (await this.cmtat.information()).should.equal('CMTAT_info');
      // Act
      ({ logs: this.logs } = await this.cmtat.setInformation('new info available', { from: owner }));
      // Assert
      (await this.cmtat.information()).should.equal('new info available')
      expectEvent.inLogs(this.logs, 'Information', {
        newInformationIndexed: web3.utils.sha3('new info available'),
        newInformation: 'new info available'
      })
    })
    it('testCannotNonAdminUpdateInformation', async function () {
      // Arrange - Assert
      (await this.cmtat.information()).should.equal('CMTAT_info')
      // Act
      await expectRevert(
        this.cmtat.setInformation('new info available', { from: address1 }),
        'AccessControl: account ' +
          address1.toLowerCase() +
          ' is missing role ' +
          DEFAULT_ADMIN_ROLE
      );
      // Assert
      (await this.cmtat.information()).should.equal('CMTAT_info')
    })
    it('testAdminCanUpdateFlag', async function () {
      // Arrange - Assert
      (await this.cmtat.flag()).should.be.bignumber.equal(this.flag.toString());
      // Act
      ({ logs: this.logs } = await this.cmtat.setFlag(100, { from: owner }));
      // Assert
      (await this.cmtat.flag()).should.be.bignumber.equal('100')
      expectEvent.inLogs(this.logs, 'Flag', {
        newFlag: '100'
      })
    })
    it('testAdminCanNotUpdateFlagWithTheSameValue', async function () {
      // Arrange - Assert
      (await this.cmtat.flag()).should.be.bignumber.equal(this.flag.toString())
      // Act
      await expectRevert(this.cmtat.setFlag(this.flag.toString(), { from: owner }),
        'Same value'
      )
    })
    it('testCannotNonAdminUpdateFlag', async function () {
      // Arrange - Assert
      (await this.cmtat.flag()).should.be.bignumber.equal(this.flag.toString())
      // Act
      await expectRevert(this.cmtat.setFlag(25, { from: address1 }),
        'AccessControl: account ' +
          address1.toLowerCase() +
          ' is missing role ' +
          DEFAULT_ADMIN_ROLE
      );
      // Assert
      (await this.cmtat.flag()).should.be.bignumber.equal(this.flag.toString())
    })
    it('testAdminCanKillContract', async function () {
      // Arrange - Assert
      await web3.eth.getCode(this.cmtat.address).should.not.equal('0x')
      // Act
      await this.cmtat.kill({ from: owner });
      // Assert
      // TODO: Check if the ethers inside the contract is sent to the right address
      // A destroyed contract has a bytecode size of 0.
      (await web3.eth.getCode(this.cmtat.address)).should.equal('0x')
      try {
        await this.cmtat.terms()
      } catch (e) {
        e.message.should.equal(
          "Returned values aren't valid, did it run Out of Gas? You might also see this error if you are not using the correct ABI for the contract you are retrieving data from, requesting data from a block number that does not exist, or querying a node which is not fully synced."
        )
      }
    })
    it('testCannotNonAdminKillContract', async function () {
      // Act
      await expectRevert(
        this.cmtat.kill({ from: address1 }),
        'AccessControl: account ' +
          address1.toLowerCase() +
          ' is missing role ' +
          DEFAULT_ADMIN_ROLE
      );
      // Assert
      (await this.cmtat.terms()).should.equal('https://cmta.ch')
      // The contract is not destroyed, so the contract has a bytecode size different from zero.
      await web3.eth.getCode(this.cmtat.address).should.not.equal('0x')
    })
  })
}
module.exports = BaseModuleCommon
