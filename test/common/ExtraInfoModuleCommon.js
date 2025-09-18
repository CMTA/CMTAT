const { expect } = require('chai')
const { DEFAULT_ADMIN_ROLE, EXTRA_INFORMATION_ROLE } = require('../utils')
const { TERMS } = require('../deploymentUtils')

function ExtraInfoModuleCommon () {
  context('Token structure', function () {
    async function checkTerms (myThis, terms) {
      const blockTimestamp = (await ethers.provider.getBlock('latest'))
        .timestamp
      const result = await myThis.cmtat.terms()
      expect(result[0]).to.equal(terms[0])
      expect(result[1][0]).to.equal(terms[1])
      if (!myThis.dontCheckTimestamp) {
        expect(result[1][2]).to.equal(blockTimestamp)
      }
    }
    it('testHasTheDefinedTokenId', async function () {
      // Act + Assert
      expect(await this.cmtat.tokenId()).to.equal('CMTAT_ISIN')
    })
    it('testHasTheDefinedTerms', async function () {
      // Act + Assert
      await checkTerms(this, TERMS)
    })
    it('testAdminCanChangeTokenId', async function () {
      // Arrange
      expect(await this.cmtat.tokenId()).to.equal('CMTAT_ISIN')
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .setTokenId('CMTAT_TOKENID')
      // Assert
      expect(await this.cmtat.tokenId()).to.equal('CMTAT_TOKENID')
      await expect(this.logs)
        .to.emit(this.cmtat, 'TokenId')
        .withArgs('CMTAT_TOKENID', 'CMTAT_TOKENID')
    })
    it('testCannotNonAdminChangeTokenId', async function () {
      // Arrange - Assert
      expect(await this.cmtat.tokenId()).to.equal('CMTAT_ISIN')
      // Act
      await expect(
        this.cmtat.connect(this.address1).setTokenId('CMTAT_TOKENID')
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, EXTRA_INFORMATION_ROLE)
      // Assert
      expect(await this.cmtat.tokenId()).to.equal('CMTAT_ISIN')
    })
    it('testAdminCanUpdateTerms', async function () {
      const NEW_TERMS = [
        'doc2',
        'https://example.com/doc2',
        '0xe405e5dad3b45f611e35717af4430b4560f12cd4054380b856446d286c341d05'
      ]

      // Act
      this.logs = await this.cmtat.connect(this.admin).setTerms(NEW_TERMS)
      // Assert

      // let blockTimestamp = (await ethers.provider.getBlock('latest')).timestamp;
      await checkTerms(this, NEW_TERMS)
      const blockTimestamp = (
        await ethers.provider.getBlock(this.logs.blockNumber)
      ).timestamp
      const TAB_EVENT = [
        NEW_TERMS[0],
        [NEW_TERMS[1], NEW_TERMS[2], blockTimestamp]
      ]
      await expect(this.logs)
        .to.emit(this.cmtat, 'Terms((string,(string,bytes32,uint256)))')
        .withArgs(TAB_EVENT)
    })
    it('testCannotNonAdminUpdateTerms', async function () {
      // Arrange - Assert
      checkTerms(TERMS)
      // Act
      await expect(this.cmtat.connect(this.address1).setTerms(TERMS))
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, EXTRA_INFORMATION_ROLE)
      // Assert
      checkTerms(TERMS)
    })
    it('testAdminCanUpdateInformation', async function () {
      // Arrange - Assert
      expect(await this.cmtat.information()).to.equal('CMTAT_info')
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .setInformation('new info available')
      // Assert
      expect(await this.cmtat.information()).to.equal('new info available')
      await expect(this.logs)
        .to.emit(this.cmtat, 'Information')
        .withArgs('new info available')
    })
    it('testCannotNonAdminUpdateInformation', async function () {
      // Arrange - Assert
      expect(await this.cmtat.information()).to.equal('CMTAT_info')
      // Act
      await expect(
        this.cmtat.connect(this.address1).setInformation('new info available')
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, EXTRA_INFORMATION_ROLE)
      // Assert
      expect(await this.cmtat.information()).to.equal('CMTAT_info')
    })
  })
}
module.exports = ExtraInfoModuleCommon
