const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { DEFAULT_ADMIN_ROLE } = require('../utils')

function BaseModuleCommon(owner, address1) {
  context('Token structure', function () {
    it('testHasTheDefinedTokenId', async function () {
      // Act + Assert
      (await this.cmtat.tokenId()).should.equal('CMTAT_ISIN')
    })
    it('testHasTheDefinedTerms', async function () {
      // Act + Assert
      (await this.cmtat.terms()).should.equal('https://cmta.ch')
    })
    it('testHasTheDefinedInformation', async function () {
      // Act + Assert
      (await this.cmtat.information()).should.equal('CMTAT_info')
    })
    it('testHasTheDefinedFlag', async function () {
      // Act + Assert
      (await this.cmtat.flag()).should.be.bignumber.equal(this.flag.toString())
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

      /// //////////////////////////////////////////////////////////////////////////////////////////////////////
      // TODO: Check SameValue() custom error on-chain when the contract is deployed.
      // As of now, Truffle doesn't support custom errors: https://github.com/trufflesuite/truffle/issues/5753
      //
      // Note: We can use ".unspecified" as a filter to find all the custom errors we need to check
      /// //////////////////////////////////////////////////////////////////////////////////////////////////////
      await expectRevert.unspecified(this.cmtat.setFlag(this.flag.toString(), { from: owner })
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
  })
}
module.exports = BaseModuleCommon
