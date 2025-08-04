const { ALLOWLIST_ROLE, ZERO_ADDRESS } = require('../utils')
const { expect } = require('chai')

const REASON_FREEZE_STRING = 'testAllowlist'
const REASON_FREEZE_EVENT = ethers.toUtf8Bytes(REASON_FREEZE_STRING)
const reasonFreeze = ethers.Typed.bytes(REASON_FREEZE_EVENT)
const REASON_FREEZE_EMPTY = ethers.Typed.bytes(ethers.toUtf8Bytes(''))

const REASON_STRING = 'testUnfreeze'
const REASON_UNFREEZE_EVENT = ethers.toUtf8Bytes(REASON_STRING)
const reasonUnfreeze = ethers.Typed.bytes(REASON_UNFREEZE_EVENT)
const REASON_EMPTY = ethers.Typed.bytes(ethers.toUtf8Bytes(''))
const REASON_EMPTY_EVENT = ethers.toUtf8Bytes('')
function AllowlistModuleCommon () {
  context('Allowlist', function () {
    beforeEach(async function () {
      const accounts = [
        this.address1,
        this.address2,
        this.address3,
        this.admin
      ]
      const unAllowlist = [false, false, false, false]
      // Arrange - Assert
      this.logs = await this.cmtat
        .connect(this.admin)
        .batchSetAddressAllowlist(accounts, unAllowlist)
    })
    async function testAllowlist (sender) {
      // Assert
      expect(
        await this.cmtat.canTransfer(this.address1, this.address2, 10)
      ).to.equal(false)

      // Arrange - Assert
      expect(await this.cmtat.isAllowlisted(this.address1)).to.equal(false)
      // Act
      this.logs = await this.cmtat
        .connect(sender)
        .setAddressAllowlist(this.address1, true, reasonFreeze)
      this.logs2 = await this.cmtat
        .connect(sender)
        .setAddressAllowlist(this.address2, true, reasonFreeze)

      // Assert
      expect(
        await this.cmtat.canTransfer(this.address1, this.address2, 10)
      ).to.equal(true)

      expect(await this.cmtat.isAllowlisted(this.address1)).to.equal(true)
      expect(await this.cmtat.isAllowlisted(this.address2)).to.equal(true)

      // emits a Freeze event
      await expect(this.logs)
        .to.emit(this.cmtat, 'AddressAddedToAllowlist')
        .withArgs(this.address1, true, sender, REASON_FREEZE_EVENT)
      await expect(this.logs2)
        .to.emit(this.cmtat, 'AddressAddedToAllowlist')
        .withArgs(this.address2, true, sender, REASON_FREEZE_EVENT)
    }

    async function testAllowlistBatch (sender) {
      const accounts = [this.address1, this.address2]
      const Allowlist = [true, true]
      const unAllowlist = [false, false]
      // Arrange - Assert
      this.logs = await this.cmtat
        .connect(sender)
        .batchSetAddressAllowlist(accounts, unAllowlist)
      expect(await this.cmtat.isAllowlisted(this.address1)).to.equal(false)
      expect(await this.cmtat.isAllowlisted(this.address2)).to.equal(false)

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
        .batchSetAddressAllowlist(accounts, Allowlist)

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
      expect(await this.cmtat.isAllowlisted(this.address1)).to.equal(true)
      expect(await this.cmtat.isAllowlisted(this.address2)).to.equal(true)

      // emits a Allowlist event
      await expect(this.logs)
        .to.emit(this.cmtat, 'AddressAddedToAllowlist')
        .withArgs(this.address1, true, sender, REASON_EMPTY_EVENT)
      await expect(this.logs)
        .to.emit(this.cmtat, 'AddressAddedToAllowlist')
        .withArgs(this.address2, true, sender, REASON_EMPTY_EVENT)
    }

    async function testPartialFreezeBatch (sender) {
      const accounts = [this.address1, this.address2, this.address3]
      const freeze = [true, true, false]

      // Arrange
      testAllowlistBatch(sender)

      // Act
      this.logs = await this.cmtat
        .connect(sender)
        .batchSetAddressAllowlist(accounts, freeze)

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
      expect(await this.cmtat.isAllowlisted(this.address1)).to.equal(true)
      expect(await this.cmtat.isAllowlisted(this.address2)).to.equal(true)

      // emits a Allowlist event
      await expect(this.logs)
        .to.emit(this.cmtat, 'AddressAddedToAllowlist')
        .withArgs(this.address1, true, sender, REASON_EMPTY_EVENT)

      await expect(this.logs)
        .to.emit(this.cmtat, 'AddressAddedToAllowlist')
        .withArgs(this.address2, true, sender, REASON_EMPTY_EVENT)

      await expect(this.logs)
        .to.emit(this.cmtat, 'AddressAddedToAllowlist')
        .withArgs(this.address3, false, sender, REASON_EMPTY_EVENT)
    }

    async function testUnAllowlist (sender) {
      // Arrange
      await this.cmtat
        .connect(sender)
        .setAddressAllowlist(this.address1, true, reasonFreeze)

      // Arrange - Assert
      expect(await this.cmtat.isAllowlisted(this.address1)).to.equal(true)
      expect(
        await this.cmtat.canTransfer(this.address1, this.address2, 10)
      ).to.equal(false)

      // Act
      this.logs = await this.cmtat
        .connect(sender)
        .setAddressAllowlist(this.address1, false, reasonUnfreeze)

      // Assert
      expect(await this.cmtat.isAllowlisted(this.address1)).to.equal(false)
      expect(
        await this.cmtat.canTransfer(this.address1, this.address2, 10)
      ).to.equal(false)

      await expect(this.logs)
        .to.emit(this.cmtat, 'AddressAddedToAllowlist')
        .withArgs(this.address1, false, sender, REASON_UNFREEZE_EVENT)
    }
    beforeEach(async function () {
      await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(this.address1, true, reasonUnfreeze)
      await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(ZERO_ADDRESS, true, reasonUnfreeze)
      await this.cmtat.connect(this.admin).mint(this.address1, 50)
      await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(this.address1, false, reasonUnfreeze)
    })

    it('testAdminCanAllowlistAddress', async function () {
      const bindTest = testAllowlist.bind(this)
      await bindTest(this.admin)
    })

    it('testAdminCanAllowlistAddressWithoutReason', async function () {
      this.logs = await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(this.address1, true)
      expect(await this.cmtat.isAllowlisted(this.address1)).to.equal(true)

      this.logs = await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(this.address1, false)
      expect(await this.cmtat.isAllowlisted(this.address1)).to.equal(false)
    })

    it('testAdminCanBatchAllowlistAddress', async function () {
      const bindTest = testAllowlistBatch.bind(this)
      await bindTest(this.admin)
    })

    it('testAdminCanBatchPartialAllowlistAddress', async function () {
      const bindTest = testPartialFreezeBatch.bind(this)
      await bindTest(this.admin)
    })

    it('testReasonParameterCanBeEmptyString', async function () {
      // Arrange - Assert
      expect(await this.cmtat.isAllowlisted(this.address1)).to.equal(false)
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(this.address1, true, REASON_EMPTY)
      // Assert
      expect(await this.cmtat.isAllowlisted(this.address1)).to.equal(true)
      // emits a Freeze event
      await expect(this.logs)
        .to.emit(this.cmtat, 'AddressAddedToAllowlist')
        .withArgs(this.address1, true, this.admin, REASON_EMPTY_EVENT)
    })

    /* //////////////////////////////////////////////////////////////
                      ENABLE/DISABLE ALLOWLIST
    ////////////////////////////////////////////////////////////// */

    it('testEnforcerRoleCanAllowlistAddress', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(ALLOWLIST_ROLE, this.address2)

      const bindTest = testAllowlist.bind(this)
      await bindTest(this.address2)
    })

    it('testAdminCanEnableAllowlistAddress', async function () {
      // Act
      this.logs = await this.cmtat.connect(this.admin).enableAllowlist(false)
      await expect(this.logs)
        .to.emit(this.cmtat, 'AllowlistEnableStatus')
        .withArgs(this.admin, false)
      // Assert
      expect(await this.cmtat.isAllowlistEnabled()).to.equal(false)

      // Act
      this.logs = await this.cmtat.connect(this.admin).enableAllowlist(true)
      await expect(this.logs)
        .to.emit(this.cmtat, 'AllowlistEnableStatus')
        .withArgs(this.admin, true)
      // Assert
      expect(await this.cmtat.isAllowlistEnabled()).to.equal(true)
    })

    it('testAdminCanUnAllowlistAddress', async function () {
      const bindTest = testUnAllowlist.bind(this)
      await bindTest(this.admin)
    })

    it('testEnforcerRoleCanUnAllowlistAddress', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(ALLOWLIST_ROLE, this.address2)
      // Act + assert
      const bindTest = testUnAllowlist.bind(this)
      await bindTest(this.address2)
    })

    /* //////////////////////////////////////////////////////////////
                       ACCESS CONTROLER
    ////////////////////////////////////////////////////////////// */

    it('testCannotNonEnforcerAllowlistAddress', async function () {
      // Act
      await expect(
        this.cmtat
          .connect(this.address2)
          .setAddressAllowlist(this.address1, true, reasonFreeze)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, ALLOWLIST_ROLE)
      // Assert
      expect(await this.cmtat.isAllowlisted(this.address1)).to.equal(false)

      // without reason
      await expect(
        this.cmtat
          .connect(this.address2)
          .setAddressAllowlist(this.address1, true)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, ALLOWLIST_ROLE)
      // Assert
      expect(await this.cmtat.isAllowlisted(this.address1)).to.equal(false)
    })

    it('testCannotNonEnforcerBatchAllowlistAddress', async function () {
      const accounts = []
      const freezes = []
      // Act
      await expect(
        this.cmtat
          .connect(this.address2)
          .batchSetAddressAllowlist(accounts, freezes)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, ALLOWLIST_ROLE)
    })

    it('testCannotNonEnforcerUnWhitelistAddress', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(this.address1, true, reasonFreeze)
      // Act
      await expect(
        this.cmtat
          .connect(this.address2)
          .setAddressAllowlist(this.address1, false, reasonFreeze)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, ALLOWLIST_ROLE)
      // Assert
      expect(await this.cmtat.isAllowlisted(this.address1)).to.equal(true)
    })

    /* //////////////////////////////////////////////////////////////
                  TRANSFER
    ////////////////////////////////////////////////////////////// */

    it('testCannotTransferWhenFromIsNotAllowlistWithTransfer', async function () {
      const AMOUNT_TO_TRANSFER = 10
      // Act
      await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(this.address2, true, reasonFreeze)
      await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(this.address3, true, reasonFreeze)
      // Assert
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

    /* //////////////////////////////////////////////////////////////
                    MINT
    ////////////////////////////////////////////////////////////// */

    it('testCannotMintToNoWhitelistAddress', async function () {
      const AMOUNT_TO_TRANSFER = 10
      expect(
        await this.cmtat.canTransfer(
          ZERO_ADDRESS,
          this.address1,
          AMOUNT_TO_TRANSFER
        )
      ).to.equal(false)

      await expect(
        this.cmtat.connect(this.admin).mint(this.address1, AMOUNT_TO_TRANSFER)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_InvalidTransfer')
        .withArgs(ZERO_ADDRESS, this.address1.address, AMOUNT_TO_TRANSFER)
    })

    it('testCannotBatchMintToNoWhitelistAddress', async function () {
      const AMOUNT_TO_TRANSFER = 10
      const TOKEN_HOLDER = [this.address3, this.address1, this.address2]
      const TOKEN_SUPPLY_BY_HOLDERS = [10n, 100n, 1000n]
      expect(
        await this.cmtat.canTransfer(
          ZERO_ADDRESS,
          this.address3,
          AMOUNT_TO_TRANSFER
        )
      ).to.equal(false)

      await expect(
        this.cmtat
          .connect(this.admin)
          .batchMint(TOKEN_HOLDER, TOKEN_SUPPLY_BY_HOLDERS)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_InvalidTransfer')
        .withArgs(
          ZERO_ADDRESS,
          this.address3.address,
          TOKEN_SUPPLY_BY_HOLDERS[0]
        )
    })

    /* //////////////////////////////////////////////////////////////
                      FORCED TRANSFER
    ////////////////////////////////////////////////////////////// */

    it('testCanForceTransferFromAddress1ToAddress2AsAdminWithoutUnfreezeTokens', async function () {
      const AMOUNT_TO_TRANSFER = 20
      const AMOUNT_TO_FREEZE = 5

      await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(this.address1, true, reasonFreeze)
      this.cmtat.connect(this.admin).mint(this.address1, AMOUNT_TO_FREEZE)
      this.logs = await this.cmtat
        .connect(this.admin)
        .freezePartialTokens(this.address1, AMOUNT_TO_FREEZE)

      expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal('5')

      // Remove from the allowlist because we test a force transfer
      await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(this.address1, false, reasonFreeze)
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .forcedTransfer(
          this.address1,
          this.address2,
          AMOUNT_TO_TRANSFER,
          reasonFreeze
        )
      // Assert
      expect(await this.cmtat.getFrozenTokens(this.address1)).to.equal('5')
      // Events
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(this.address1, this.address2, AMOUNT_TO_TRANSFER)
    })

    /* //////////////////////////////////////////////////////////////
                        BURN
    ////////////////////////////////////////////////////////////// */
    it('testCanBatchBurnIfWhitelistedAddress', async function () {
      const TOKEN_BY_HOLDERS_TO_BURN = [10, 100, 1000]
      const TOKEN_HOLDER = [this.admin, this.address1, this.address2]

      await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(this.address1, true, reasonFreeze)
      await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(this.admin, true, reasonFreeze)
      await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(this.address2, true, reasonFreeze)

      this.cmtat
        .connect(this.admin)
        .batchMint(TOKEN_HOLDER, TOKEN_BY_HOLDERS_TO_BURN)

      // Act
      this.cmtat
        .connect(this.admin)
        .batchBurn(TOKEN_HOLDER, TOKEN_BY_HOLDERS_TO_BURN)
    })
    it('testCannotBatchBurnFromNoWhitelistedAddress', async function () {
      const TOKEN_BY_HOLDERS_TO_BURN = [10, 100, 1000]
      const TOKEN_HOLDER = [this.admin, this.address1, this.address2]
      await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(this.address1, true, reasonFreeze)
      await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(this.admin, true, reasonFreeze)

      await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(this.address2, true, reasonFreeze)

      this.cmtat
        .connect(this.admin)
        .batchMint(TOKEN_HOLDER, TOKEN_BY_HOLDERS_TO_BURN)

      // Remove from the allowlist
      await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(this.address1, false, reasonFreeze)

      // Act
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchBurn(TOKEN_HOLDER, TOKEN_BY_HOLDERS_TO_BURN)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_InvalidTransfer')
        .withArgs(
          this.address1.address,
          ZERO_ADDRESS,
          TOKEN_BY_HOLDERS_TO_BURN[1]
        )
    })

    it('testCanBurnFromWhitelistedAddress', async function () {
      const AMOUNT_TO_TRANSFER = 10
      await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(this.address1, true, reasonFreeze)
      this.cmtat.connect(this.admin).mint(this.address1, AMOUNT_TO_TRANSFER)
      expect(
        await this.cmtat.canTransfer(
          this.address1,
          ZERO_ADDRESS,
          AMOUNT_TO_TRANSFER
        )
      ).to.equal(true)

      expect(
        await this.cmtat.canTransfer(
          this.address1,
          ZERO_ADDRESS,
          AMOUNT_TO_TRANSFER
        )
      ).to.equal(true)

      // Act
      await this.cmtat
        .connect(this.admin)
        .burn(this.address1, AMOUNT_TO_TRANSFER)
    })

    it('testCannotBurnFromUnWhitelistedAddress', async function () {
      const AMOUNT_TO_TRANSFER = 10
      await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(this.address1, true, reasonFreeze)
      this.cmtat.connect(this.admin).mint(this.address1, AMOUNT_TO_TRANSFER)
      expect(
        await this.cmtat.canTransfer(
          this.address1,
          ZERO_ADDRESS,
          AMOUNT_TO_TRANSFER
        )
      ).to.equal(true)

      // Remove from the whitelist
      await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(this.address1, false, reasonFreeze)

      expect(
        await this.cmtat.canTransfer(
          this.address1,
          ZERO_ADDRESS,
          AMOUNT_TO_TRANSFER
        )
      ).to.equal(false)

      // Act
      await expect(
        this.cmtat.connect(this.admin).burn(this.address1, AMOUNT_TO_TRANSFER)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_InvalidTransfer')
        .withArgs(this.address1.address, ZERO_ADDRESS, AMOUNT_TO_TRANSFER)
    })

    /* //////////////////////////////////////////////////////////////
                          Batch transfer
    ////////////////////////////////////////////////////////////// */

    it('testCannotBeBatchTransferIfToIsNotWhitelisted', async function () {
      const accounts = [this.address1, this.address3, this.admin]
      const allowlist = [true, true, true]
      this.logs = await this.cmtat
        .connect(this.admin)
        .batchSetAddressAllowlist(accounts, allowlist)
      const TOKEN_HOLDER = [this.admin, this.address1, this.address2]
      const TOKEN_SUPPLY_BY_HOLDERS = [10n, 100n, 1000n]
      const TOKEN_HOLDER_ADMIN = [this.admin, this.admin, this.admin]

      await this.cmtat
        .connect(this.admin)
        .batchMint(TOKEN_HOLDER_ADMIN, TOKEN_SUPPLY_BY_HOLDERS)

      // Act
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchTransfer(TOKEN_HOLDER, TOKEN_SUPPLY_BY_HOLDERS)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_InvalidTransfer')
        .withArgs(this.admin, TOKEN_HOLDER[2], TOKEN_SUPPLY_BY_HOLDERS[2])
    })

    /* //////////////////////////////////////////////////////////////
                          TRANSFER FROM
    ////////////////////////////////////////////////////////////// */
    it('testCanTransferTokenWithTransferFrom', async function () {
      const AMOUNT_TO_TRANSFER = 10
      // Arrange
      // Define allowance
      await this.cmtat
        .connect(this.address3)
        .approve(this.address1, AMOUNT_TO_TRANSFER)

      await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(this.address3, true, reasonFreeze)
      await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(this.address2, true, reasonFreeze)
      await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(this.address1, true, reasonFreeze)
      await this.cmtat
        .connect(this.admin)
        .mint(this.address3, AMOUNT_TO_TRANSFER)
      // Act
      expect(
        await this.cmtat.canTransferFrom(
          this.address1,
          this.address3,
          this.address2,
          AMOUNT_TO_TRANSFER
        )
      ).to.equal(true)
      await this.cmtat
        .connect(this.address1)
        .transferFrom(this.address3, this.address2, AMOUNT_TO_TRANSFER)
    })

    it('testCannotTransferTokenWhenToIsNotAllowlistWithTransferFrom', async function () {
      const AMOUNT_TO_TRANSFER = 10
      // Arrange
      // Define allowance
      await this.cmtat
        .connect(this.address3)
        .approve(this.address1, AMOUNT_TO_TRANSFER)
      // Act
      await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(this.address3, true, reasonFreeze)
      await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(this.address1, true, reasonFreeze)

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

    it('testCannotTransferTokenWhenSpenderIsNotAllowlistWithTransferFrom', async function () {
      const AMOUNT_TO_TRANSFER = 10
      // Arrange
      // Define allowance
      await this.cmtat
        .connect(this.address3)
        .approve(this.address1, AMOUNT_TO_TRANSFER)
      await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(this.address3, true, reasonFreeze)
      await this.cmtat
        .connect(this.admin)
        .setAddressAllowlist(this.address2, true, reasonFreeze)
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

    /* //////////////////////////////////////////////////////////////
                           INPUT PARAMETERS
    ////////////////////////////////////////////////////////////// */

    it('testCannotBatchAllowlistIfLengthMismatchTooManyAddresses', async function () {
      // There are too many addresses
      const accounts = [this.address1, this.address2, this.address3]
      const allowlist = [false, false]

      // Act
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchSetAddressAllowlist(accounts, allowlist)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_Enforcement_AccountsValueslengthMismatch'
      )
    })

    it('testCannotBatchAllowlistIfAccountsSIsEmpty', async function () {
      const accounts = []
      const allowlist = [false, false]
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchSetAddressAllowlist(accounts, allowlist)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_Enforcement_EmptyAccounts'
      )
    })
  })
}
module.exports = AllowlistModuleCommon
