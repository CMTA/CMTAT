const { ethers, upgrades } = require('hardhat')
const { DEFAULT_ADMIN_ROLE } = require('../../utils')

const errorSameValue = 'SameValue'

describe('Proxy - BaseModule', function () {
  let admin, account1, flag, cmtat

  beforeEach(async function () {
    [admin, account1] = await ethers.getSigners()

    flag = 5
    const CMTAT_BASE = await ethers.getContractFactory('CMTAT_BASE')
    cmtat = await upgrades.deployProxy(CMTAT_BASE, [admin.address, 'CMTA Token', 'CMTAT', 18, 'CMTAT_ISIN', 'https://cmta.ch', 'CMTAT_info', flag])
  })

  context('Token structure', function () {
    it('testHasTheDefinedTokenId', async function () {
      // Act + Assert
      await expect(await cmtat.tokenId()).to.equal('CMTAT_ISIN')
    })
    it('testHasTheDefinedTerms', async function () {
      // Act + Assert
      await expect(await cmtat.terms()).to.equal('https://cmta.ch')
    })
    it('testHasTheDefinedInformation', async function () {
      // Act + Assert
      await expect(await cmtat.information()).to.equal('CMTAT_info')
    })
    it('testHasTheDefinedFlag', async function () {
      // Act + Assert
      await expect(await cmtat.flag()).to.equal(flag.toString())
    })
    it('testAdminCanChangeTokenId', async function () {
      // Arrange
      await expect(await cmtat.tokenId()).to.equal('CMTAT_ISIN')
      // Act
      await expect(await cmtat.connect(admin).setTokenId('CMTAT_TOKENID')).to.emit(cmtat, 'TokenId').withArgs('CMTAT_TOKENID', 'CMTAT_TOKENID')
      // Assert
      await expect(await cmtat.tokenId()).to.equal('CMTAT_TOKENID')
    })
    it('testCannotNonAdminChangeTokenId', async function () {
      // Arrange - Assert
      await expect(await cmtat.tokenId()).to.equal('CMTAT_ISIN')
      // Act
      await expect(cmtat.connect(account1).setTokenId('CMTAT_TOKENID')).to.be.revertedWith(
        'AccessControl: account ' +
            account1.address.toLowerCase() +
            ' is missing role ' +
            DEFAULT_ADMIN_ROLE
      )
      // Assert
      await expect(await cmtat.tokenId()).to.equal('CMTAT_ISIN')
    })
    it('testAdminCanUpdateTerms', async function () {
      // Arrange - Assert
      await expect(await cmtat.terms()).to.equal('https://cmta.ch')
      // Act
      await expect(await cmtat.connect(admin).setTerms('https://cmta.ch/terms')).to.emit(cmtat, 'Term').withArgs('https://cmta.ch/terms', 'https://cmta.ch/terms')
      // Assert
      await expect(await cmtat.terms()).to.equal('https://cmta.ch/terms')
    })
    it('testCannotNonAdminUpdateTerms', async function () {
      // Arrange - Assert
      await expect(await cmtat.terms()).to.equal('https://cmta.ch')
      // Act
      await expect(cmtat.connect(account1).setTerms('https://cmta.ch/terms')).to.be.revertedWith(
        'AccessControl: account ' +
            account1.address.toLowerCase() +
            ' is missing role ' +
            DEFAULT_ADMIN_ROLE
      )
      // Assert
      await expect(await cmtat.terms()).to.equal('https://cmta.ch')
    })
    it('testAdminCanUpdateInformation', async function () {
      // Arrange - Assert
      await expect(await cmtat.information()).to.equal('CMTAT_info')
      // Act
      await expect(await cmtat.connect(admin).setInformation('new info available')).to.emit(cmtat, 'Information').withArgs('new info available', 'new info available')
      // Assert
      await expect(await cmtat.information()).to.equal('new info available')
    })
    it('testCannotNonAdminUpdateInformation', async function () {
      // Arrange - Assert
      await expect(await cmtat.information()).to.equal('CMTAT_info')
      // Act
      await expect(cmtat.connect(account1).setInformation('new info available')).to.be.revertedWith(
        'AccessControl: account ' +
            account1.address.toLowerCase() +
            ' is missing role ' +
            DEFAULT_ADMIN_ROLE
      )

      // Assert
      await expect(await cmtat.information()).to.equal('CMTAT_info')
    })
    it('testAdminCanUpdateFlag', async function () {
      // Arrange - Assert
      await expect(await cmtat.flag()).to.equal(flag.toString())
      // Act
      await expect(await cmtat.connect(admin).setFlag(100)).to.emit(cmtat, 'Flag').withArgs('100')
      // Assert
      await expect(await cmtat.flag()).to.equal('100')
    })
    it('testAdminCanNotUpdateFlagWithTheSameValue', async function () {
      // Arrange - Assert
      await expect(await cmtat.flag()).to.equal(flag.toString())
      // Act
      await expect(cmtat.connect(admin).setFlag(flag)).to.be.revertedWithCustomError(cmtat, errorSameValue)
    })
    it('testCannotNonAdminUpdateFlag', async function () {
      // Arrange - Assert
      await expect(await cmtat.flag()).to.equal(flag.toString())
      // Act
      await expect(cmtat.connect(account1).setFlag(25)).to.be.revertedWith(
        'AccessControl: account ' +
            account1.address.toLowerCase() +
            ' is missing role ' +
            DEFAULT_ADMIN_ROLE
      )
      // Assert
      await expect(await cmtat.flag()).to.equal(flag.toString())
    })
  })
})
