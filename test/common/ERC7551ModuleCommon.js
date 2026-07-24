const { expect } = require('chai')
const { EXTRA_INFORMATION_ROLE } = require('../utils')
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
        // The ERC-7551 overload carries no name, so the existing one is kept (NM-22)
        TERMS[0],
        'https://example.com/doc2',
        '0xe405e5dad3b45f611e35717af4430b4560f12cd4054380b856446d286c341d05'
      ]
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .setTerms(
          ethers.Typed.bytes32(NEW_TERMS[2]),
          ethers.Typed.string(NEW_TERMS[1])
        )
      // Assert

      await checkTerms(this, NEW_TERMS)

      const hash = await this.cmtat.termsHash()
      expect(hash).to.equal(NEW_TERMS[2])

      await expect(this.logs)
        .to.emit(this.cmtat, 'Terms(bytes32,string)')
        .withArgs(NEW_TERMS[2], NEW_TERMS[1])
    })
    /*
     * NM-22 (Nethermind AuditAgent v3.3.0-rc2): the ERC-7551 `setTerms(bytes32,string)`
     * overload carries no document name, so it must leave the existing one alone.
     * Previously it forwarded an empty string and silently erased it.
     */
    it('testERC7551SetTermsPreservesDocumentName', async function () {
      const NEW_URI = 'https://example.com/doc3'
      const NEW_HASH =
        '0xe405e5dad3b45f611e35717af4430b4560f12cd4054380b856446d286c341d05'
      // Arrange: the token is deployed with a named terms document
      await checkTerms(this, TERMS)

      // Act: update through the ERC-7551 overload
      await this.cmtat
        .connect(this.admin)
        .setTerms(ethers.Typed.bytes32(NEW_HASH), ethers.Typed.string(NEW_URI))

      // Assert: uri and hash updated, name untouched
      const result = await this.cmtat.terms()
      expect(result[0]).to.equal(TERMS[0])
      expect(result[1][0]).to.equal(NEW_URI)
      expect(result[1][1]).to.equal(NEW_HASH)
      expect(await this.cmtat.termsHash()).to.equal(NEW_HASH)
    })

    it('testCannotNonAdminUpdateTerms', async function () {
      // Arrange - Assert
      await checkTerms(this, TERMS)
      // Act
      await expect(
        this.cmtat
          .connect(this.address1)
          .setTerms(ethers.Typed.bytes32(TERMS[2]), TERMS[1])
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, EXTRA_INFORMATION_ROLE)
    })

    it('testAdminCanUpdateMetadata', async function () {
      const NEW_METADATA = 'https://example.com/metadata2'
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .setMetaData(NEW_METADATA)
      // Assert
      expect(await this.cmtat.metaData()).to.equal(NEW_METADATA)
      await expect(this.logs)
        .to.emit(this.cmtat, 'MetaData')
        .withArgs(NEW_METADATA)
    })

    it('testCannotNonAdminUpdateMetadata', async function () {
      const NEW_METADATA = 'https://example.com/metadata2'
      // Act
      await expect(this.cmtat.connect(this.address1).setMetaData(NEW_METADATA))
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
