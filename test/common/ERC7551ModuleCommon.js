const { expect } = require('chai')
const { DEFAULT_ADMIN_ROLE, EXTRA_INFORMATION_ROLE } = require('../utils')
const { TERMS } = require('../deploymentUtils')

function ERC7551ModuleCommon () {
  context('ERC-7551', function () {
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
    it('testHasTheDefinedTerms', async function () {
      // Act + Assert
      await checkTerms(this, TERMS)
    })
    it('testAdminCanUpdateTerms', async function () {
      const NEW_TERMS = [
        '',
        'https://example.com/doc2',
        '0xe405e5dad3b45f611e35717af4430b4560f12cd4054380b856446d286c341d05'
      ]
      // Act
      this.logs = await this.cmtat.connect(this.admin).setTerms(ethers.Typed.bytes32(NEW_TERMS[2]), NEW_TERMS[1])
      // Assert

      await checkTerms(this, NEW_TERMS)

      let hash = await this.cmtat.termsHash()
      expect(hash).to.equal(NEW_TERMS[2])
    })
    it('testCannotNonAdminUpdateTerms', async function () {
      // Arrange - Assert
      checkTerms(TERMS)
      // Act
      await expect(this.cmtat.connect(this.address1).setTerms(ethers.Typed.bytes32(TERMS[2]), TERMS[1]))
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, EXTRA_INFORMATION_ROLE)
    })

    it('testAdminCanUpdateMetadata', async function () {
      const NEW_METADATA = 'https://example.com/metadata2'
      // Act
      this.logs = await this.cmtat.connect(this.admin).setMetaData(NEW_METADATA)
      // Assert
      expect(await this.cmtat.metaData()).to.equal(NEW_METADATA)
      await expect(this.logs)
        .to.emit(this.cmtat, 'MetaData')
        .withArgs(NEW_METADATA)
    })

    it('testCannotNonAdminUpdateMetadata', async function () {
      const NEW_METADATA = 'https://example.com/metadata2'
      // Act
      await expect(
        this.cmtat.connect(this.address1).setMetaData(NEW_METADATA)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, EXTRA_INFORMATION_ROLE)
      // Assert
      expect(await this.cmtat.metaData()).to.equal('')
    })
  })
}
module.exports = ERC7551ModuleCommon
