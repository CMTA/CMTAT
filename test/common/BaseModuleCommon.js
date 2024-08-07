const { expect } = require('chai');
const { DEFAULT_ADMIN_ROLE } = require('../utils')
const {
  expectRevertCustomError
} = require('../../openzeppelin-contracts-upgradeable/test/helpers/customError.js')

function BaseModuleCommon () {
  context('Token structure', function () {
    it('testHasTheDefinedVersion', async function () {
      // Act + Assert
      expect(await this.cmtat.VERSION()).to.equal('2.4.1')
    })
    it('testHasTheDefinedTokenId', async function () {
      // Act + Assert
      expect(await this.cmtat.tokenId()).to.equal('CMTAT_ISIN')
    })
    it('testHasTheDefinedTerms', async function () {
      // Act + Assert
      expect(await this.cmtat.terms()).to.equal('https://cmta.ch')
    })
    it('testAdminCanChangeTokenId', async function () {
      // Arrange
      expect(await this.cmtat.tokenId()).to.equal('CMTAT_ISIN')
      // Act
      this.logs = await this.cmtat.connect(this.admin).setTokenId('CMTAT_TOKENID');
      // Assert
      expect(await this.cmtat.tokenId()).to.equal('CMTAT_TOKENID')
      await expect(this.logs).to.emit(this.cmtat, 'TokenId').withArgs('CMTAT_TOKENID', 'CMTAT_TOKENID');
    })
    it('testCannotNonAdminChangeTokenId', async function () {
      // Arrange - Assert
      expect(await this.cmtat.tokenId()).to.equal('CMTAT_ISIN')
      // Act
      await expectRevertCustomError(
        this.cmtat.connect(this.address1).setTokenId('CMTAT_TOKENID'),
        'AccessControlUnauthorizedAccount',
        [this.address1.address, DEFAULT_ADMIN_ROLE]
      );
      // Assert
      expect(await this.cmtat.tokenId()).to.equal('CMTAT_ISIN')
    })
    it('testAdminCanUpdateTerms', async function () {
      // Arrange - Assert
      expect(await this.cmtat.terms()).to.equal('https://cmta.ch')
      // Act
      this.logs = await this.cmtat.connect(this.admin).setTerms('https://cmta.ch/terms');
      // Assert
      expect(await this.cmtat.terms()).to.equal('https://cmta.ch/terms')
      await expect(this.logs).to.emit(this.cmtat, 'Term').withArgs('https://cmta.ch/terms', 'https://cmta.ch/terms');
    })
    it('testCannotNonAdminUpdateTerms', async function () {
      // Arrange - Assert
      expect(await this.cmtat.terms()).to.equal('https://cmta.ch')
      // Act
      await expectRevertCustomError(
        this.cmtat.connect(this.address1).setTerms('https://cmta.ch/terms'),
        'AccessControlUnauthorizedAccount',
        [this.address1.address, DEFAULT_ADMIN_ROLE]
      );
      // Assert
      expect(await this.cmtat.terms()).to.equal('https://cmta.ch')
    })
    it('testAdminCanUpdateInformation', async function () {
      // Arrange - Assert
      expect(await this.cmtat.information()).to.equal('CMTAT_info')
      // Act
      this.logs = await this.cmtat.connect(this.admin).setInformation('new info available');
      // Assert
      expect(await this.cmtat.information()).to.equal('new info available')
      await expect(this.logs).to.emit(this.cmtat, 'Information').withArgs( 'new info available', 'new info available');
    })
    it('testCannotNonAdminUpdateInformation', async function () {
      // Arrange - Assert
      expect(await this.cmtat.information()).to.equal('CMTAT_info')
      // Act
      await expectRevertCustomError(
        this.cmtat.connect(this.address1).setInformation('new info available'),
        'AccessControlUnauthorizedAccount',
        [this.address1.address, DEFAULT_ADMIN_ROLE]
      );
      // Assert
      expect(await this.cmtat.information()).to.equal('CMTAT_info')
    })
  })
}
module.exports = BaseModuleCommon
