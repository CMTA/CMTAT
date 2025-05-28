const { WHITELIST_ROLE, ZERO_ADDRESS } = require('../utils')
const { expect } = require('chai')

const REASON_FREEZE_STRING = 'testWhitelist'
const REASON_FREEZE_EVENT = ethers.toUtf8Bytes(REASON_FREEZE_STRING)
const reasonFreeze = ethers.Typed.bytes(REASON_FREEZE_EVENT)
const REASON_FREEZE_EMPTY = ethers.Typed.bytes(ethers.toUtf8Bytes(''))

const REASON_STRING = 'testUnfreeze'
const REASON_UNFREEZE_EVENT = ethers.toUtf8Bytes(REASON_STRING)
const reasonUnfreeze = ethers.Typed.bytes(REASON_UNFREEZE_EVENT)
const REASON_EMPTY = ethers.Typed.bytes(ethers.toUtf8Bytes(''))
const REASON_EMPTY_EVENT = ethers.toUtf8Bytes('')
function WhitelistModuleCommon () {

  context('Freeze', function () {
    beforeEach(async function () {
      const accounts = [this.address1, this.address2, this.address3, this.admin]
      const unwhitelist = [false,false, false, false]
      // Arrange - Assert
      this.logs = await this.cmtat
      .connect(this.admin)
      .batchSetAddressWhitelisted(accounts,  unwhitelist)
    })
    async function testWhitelist (sender) {
      // Assert
      expect(
        await this.cmtat.canTransfer(this.address1, this.address2, 10)
      ).to.equal(false)

      // Arrange - Assert
      expect(await this.cmtat.isWhitelisted(this.address1)).to.equal(false)
      // Act
      this.logs = await this.cmtat
        .connect(sender)
        .setAddressWhitelisted(this.address1, true, reasonFreeze)
      this.logs2 = await this.cmtat
        .connect(sender)
        .setAddressWhitelisted(this.address2, true, reasonFreeze)
      
        // Assert
      expect(
        await this.cmtat.canTransfer(this.address1, this.address2, 10)
      ).to.equal(true)

      expect(await this.cmtat.isWhitelisted(this.address1)).to.equal(true)
      expect(await this.cmtat.isWhitelisted(this.address2)).to.equal(true)
     
      // emits a Freeze event
      await expect(this.logs)
        .to.emit(this.cmtat, 'AddressWhitelisted')
        .withArgs(this.address1, true, sender, REASON_FREEZE_EVENT)
      await expect(this.logs2)
        .to.emit(this.cmtat, 'AddressWhitelisted')
        .withArgs(this.address2, true, sender, REASON_FREEZE_EVENT)
    }

    async function testWhitelistBatch (sender) {
      const accounts = [this.address1, this.address2]
      const whitelist = [true, true]
      const unwhitelist = [false,false]
      // Arrange - Assert
      this.logs = await this.cmtat
      .connect(sender)
      .batchSetAddressWhitelisted(accounts,  unwhitelist)
      expect(await this.cmtat.isWhitelisted(this.address1)).to.equal(false)
      expect(await this.cmtat.isWhitelisted(this.address2)).to.equal(false)
       
      // Assert - canTransfer
       expect(
        await this.cmtat.canTransfer(this.address1, this.address3, 10)
      ).to.equal(false)
      expect(
        await this.cmtat.canTransfer(this.address2, this.address3, 10)
      ).to.equal(false)
      expect(
        await this.cmtat.canTransfer(this.address1, this.address2, 10)
      ).to.equal(false)
      
      // Act
      this.logs = await this.cmtat
        .connect(sender)
        .batchSetAddressWhitelisted(accounts, whitelist)
      
      // Assert
      expect(
        await this.cmtat.canTransfer(this.address1, this.address3, 10)
      ).to.equal(false)
      expect(
        await this.cmtat.canTransfer(this.address2, this.address3, 10)
      ).to.equal(false)
      expect(
        await this.cmtat.canTransfer(this.address1, this.address2, 10)
      ).to.equal(true)
      expect(await this.cmtat.isWhitelisted(this.address1)).to.equal(true)
      expect(await this.cmtat.isWhitelisted(this.address2)).to.equal(true)
      
      // emits a Whitelist event
      await expect(this.logs)
        .to.emit(this.cmtat, 'AddressWhitelisted')
        .withArgs(this.address1, true, sender, REASON_EMPTY_EVENT)
      await expect(this.logs)
        .to.emit(this.cmtat, 'AddressWhitelisted')
        .withArgs(this.address2, true, sender, REASON_EMPTY_EVENT)
    }

    async function testPartialFreezeBatch (sender) {
      const accounts = [this.address1, this.address2, this.address3]
      const freeze = [true, true, false]

      // Arrange
      testWhitelistBatch(sender)

      // Act
      this.logs = await this.cmtat
        .connect(sender)
        .batchSetAddressWhitelisted(accounts, freeze)

      // Assert
      expect(
        await this.cmtat.canTransfer(this.address1, this.address3, 10)
      ).to.equal(false)
      expect(
        await this.cmtat.canTransfer(this.address2, this.address3, 10)
      ).to.equal(false)
      expect(
        await this.cmtat.canTransfer(this.address1, this.address2, 10)
      ).to.equal(true)
      expect(await this.cmtat.isWhitelisted(this.address1)).to.equal(true)
      expect(await this.cmtat.isWhitelisted(this.address2)).to.equal(true)
      
      // emits a whitelist event
      await expect(this.logs)
        .to.emit(this.cmtat, 'AddressWhitelisted')
        .withArgs(this.address1, true, sender, REASON_EMPTY_EVENT)
      
        await expect(this.logs)
        .to.emit(this.cmtat, 'AddressWhitelisted')
        .withArgs(this.address2, true, sender, REASON_EMPTY_EVENT)
      
        await expect(this.logs)
        .to.emit(this.cmtat, 'AddressWhitelisted')
        .withArgs(this.address3, false, sender, REASON_EMPTY_EVENT)
    }

    async function testUnWhitelist (sender) {
      // Arrange
      await this.cmtat.connect(sender).setAddressWhitelisted(this.address1, true, reasonFreeze)
      
      // Arrange - Assert
      expect(await this.cmtat.isWhitelisted(this.address1)).to.equal(true)
      expect(
        await this.cmtat.canTransfer(this.address1, this.address2, 10)
      ).to.equal(false)
      
      // Act
      this.logs = await this.cmtat
        .connect(sender)
        .setAddressWhitelisted(this.address1, false, reasonUnfreeze)
      
        // Assert
      expect(await this.cmtat.isWhitelisted(this.address1)).to.equal(false)
      expect(
        await this.cmtat.canTransfer(this.address1, this.address2, 10)
      ).to.equal(false)
      
      await expect(this.logs)
        .to.emit(this.cmtat, 'AddressWhitelisted')
        .withArgs(this.address1, false, sender, REASON_UNFREEZE_EVENT)
    }
    beforeEach(async function () {
      await this.cmtat
      .connect(this.admin)
      .setAddressWhitelisted(this.address1, true, reasonUnfreeze)
      await this.cmtat
      .connect(this.admin)
      .setAddressWhitelisted(ZERO_ADDRESS, true, reasonUnfreeze)
      await this.cmtat.connect(this.admin).mint(this.address1, 50)
      await this.cmtat
      .connect(this.admin)
      .setAddressWhitelisted(this.address1, false, reasonUnfreeze)
    })

    it('testAdminCanWhitelistAddress', async function () {
      const bindTest = testWhitelist.bind(this)
      await bindTest(this.admin)
    })

    it('testAdminCanBatchWhitelistAddress', async function () {
      const bindTest = testWhitelistBatch.bind(this)
      await bindTest(this.admin)
    })

    it('testAdminCanBatchPartialWhitelistAddress', async function () {
      const bindTest = testPartialFreezeBatch.bind(this)
      await bindTest(this.admin)
    })

    it('testReasonParameterCanBeEmptyString', async function () {
      // Arrange - Assert
      expect(await this.cmtat.isWhitelisted(this.address1)).to.equal(false)
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .setAddressWhitelisted(this.address1, true, REASON_EMPTY)
      // Assert
      expect(await this.cmtat.isWhitelisted(this.address1)).to.equal(true)
      // emits a Freeze event
      await expect(this.logs)
        .to.emit(this.cmtat, 'AddressWhitelisted')
        .withArgs(this.address1, true, this.admin, REASON_EMPTY_EVENT)
    })

    it('testEnforcerRoleCanWhitelistAddress', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(WHITELIST_ROLE, this.address2)

      const bindTest = testWhitelist.bind(this)
      await bindTest(this.address2)
    })

    it('testAdminCanUnWhitelistAddress', async function () {
      const bindTest = testUnWhitelist.bind(this)
      await bindTest(this.admin)
    })

    it('testEnforcerRoleCanUnWhitelistAddress', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(WHITELIST_ROLE, this.address2)
      // Act + assert
      const bindTest = testUnWhitelist.bind(this)
      await bindTest(this.address2)
    })

    it('testCannotNonEnforcerWhitelistAddress', async function () {
      // Act
      await expect(
        this.cmtat.connect(this.address2).setAddressWhitelisted(this.address1, true, reasonFreeze)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, WHITELIST_ROLE)
      // Assert
      expect(await this.cmtat.isWhitelisted(this.address1)).to.equal(false)
    })

    it('testCannotNonEnforcerBatchWhitelistAddress', async function () {
      const accounts = []
      const freezes = []
      // Act
      await expect(
        this.cmtat.connect(this.address2).batchSetAddressWhitelisted(accounts, freezes)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, WHITELIST_ROLE)
    })

    it('testCannotNonEnforcerUnWhiteistAddress', async function () {
      // Arrange
      await this.cmtat.connect(this.admin).setAddressWhitelisted(this.address1, true, reasonFreeze)
      // Act
      await expect(
        this.cmtat.connect(this.address2).setAddressWhitelisted(this.address1, false, reasonFreeze)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, WHITELIST_ROLE)
      // Assert
      expect(await this.cmtat.isWhitelisted(this.address1)).to.equal(true)
    })

    // reverts if address1 transfers tokens to address2 when paused
    it('testCannotTransferWhenFromIsNotWhitelistedWithTransfer', async function () {
      const AMOUNT_TO_TRANSFER = 10
      // Act
      await this.cmtat.connect(this.admin).setAddressWhitelisted(this.address2, true, reasonFreeze)
      await this.cmtat.connect(this.admin).setAddressWhitelisted(this.address3, true, reasonFreeze)
      // Assert
      if (!this.core) {
        expect(
          await this.cmtat.detectTransferRestriction(
            this.address1,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal('2')
        expect(await this.cmtat.messageForTransferRestriction(2)).to.equal(
          'AddrFromisWhitelisted'
        )
      }
      await expect(
        this.cmtat
          .connect(this.address1)
          .transfer(this.address2, AMOUNT_TO_TRANSFER)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_InvalidTransfer')
        .withArgs(
          this.address1.address,
          this.address2.address,
          AMOUNT_TO_TRANSFER
        )
    })

    // reverts if address3 transfers tokens from address1 to this.address2 when paused
    it('testCannotTransferTokenWhenToIsNotWhitelistedWithTransferFrom', async function () {
      const AMOUNT_TO_TRANSFER = 10
      // Arrange
      // Define allowance
      await this.cmtat.connect(this.address3).approve(this.address1, AMOUNT_TO_TRANSFER)
      // Act
      await this.cmtat.connect(this.admin).setAddressWhitelisted(this.address3, true, reasonFreeze)
      await this.cmtat.connect(this.admin).setAddressWhitelisted(this.address1, true, reasonFreeze)
      if (!this.core) {
        // Assert
        expect(
          await this.cmtat.detectTransferRestriction(
            this.address3,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal('3')
        expect(await this.cmtat.messageForTransferRestriction(3)).to.equal(
          'AddrToisWhitelisted'
        )
      }

      await expect(
        this.cmtat
          .connect(this.address1)
          .transferFrom(this.address3, this.address2, AMOUNT_TO_TRANSFER)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_InvalidTransfer')
        .withArgs(
          this.address3.address,
          this.address2.address,
          AMOUNT_TO_TRANSFER
        )
    })

    it('testCannotTransferTokenWhenSpenderIsNotWhitelistedWithTransferFrom', async function () {
      const AMOUNT_TO_TRANSFER = 10
      // Arrange
      // Define allowance
      await this.cmtat.connect(this.address3).approve(this.address1, AMOUNT_TO_TRANSFER)
      await this.cmtat.connect(this.admin).setAddressWhitelisted(this.address3, true, reasonFreeze)
      await this.cmtat.connect(this.admin).setAddressWhitelisted(this.address2, true, reasonFreeze)
      // Act
      expect(
        await this.cmtat.canTransferFrom(
          this.address1,
          this.address3,
          this.address2,
          AMOUNT_TO_TRANSFER
        )
      ).to.equal(false)

      await expect(
        this.cmtat
          .connect(this.address1)
          .transferFrom(this.address3, this.address2, AMOUNT_TO_TRANSFER)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_InvalidTransfer')
        .withArgs(
          this.address3.address,
          this.address2.address,
          AMOUNT_TO_TRANSFER
        )
    })
  })
}
module.exports = WhitelistModuleCommon
