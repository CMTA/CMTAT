const {
  ENFORCER_ROLE,
  REJECTED_CODE_BASE_TRANSFER_REJECTED_FROM_FROZEN,
  REJECTED_CODE_BASE_TRANSFER_REJECTED_TO_FROZEN,
  REJECTED_CODE_BASE_TRANSFER_REJECTED_SPENDER_FROZEN
} = require('../utils')
const { expect } = require('chai')

const REASON_FREEZE_STRING = 'testFreeze'
const REASON_FREEZE_EVENT = ethers.toUtf8Bytes(REASON_FREEZE_STRING)
const reasonFreeze = ethers.Typed.bytes(REASON_FREEZE_EVENT)
const REASON_FREEZE_EMPTY = ethers.Typed.bytes(ethers.toUtf8Bytes(''))

const REASON_STRING = 'testUnfreeze'
const REASON_UNFREEZE_EVENT = ethers.toUtf8Bytes(REASON_STRING)
const reasonUnfreeze = ethers.Typed.bytes(REASON_UNFREEZE_EVENT)
const REASON_EMPTY = ethers.Typed.bytes(ethers.toUtf8Bytes(''))
const REASON_EMPTY_EVENT = ethers.toUtf8Bytes('')
function EnforcementModuleCommon () {
  context('Freeze', function () {
    async function testFreeze (sender) {
      // Arrange - Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(false)
      // Act
      this.logs = await this.cmtat
        .connect(sender)
        .setAddressFrozen(this.address1, true, reasonFreeze)
      // Assert
      if (!this.generic) {
        expect(
          await this.cmtat.canTransfer(this.address1, this.address2, 10)
        ).to.equal(false)
      }
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(true)
      // emits a Freeze event
      await expect(this.logs)
        .to.emit(this.cmtat, 'AddressFrozen')
        .withArgs(this.address1, true, sender, REASON_FREEZE_EVENT)
    }

    async function testFreezeBatch (sender) {
      const accounts = [this.address1, this.address2]
      const freeze = [true, true]
      // Arrange - Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(false)
      expect(await this.cmtat.isFrozen(this.address2)).to.equal(false)
      // Act
      this.logs = await this.cmtat
        .connect(sender)
        .batchSetAddressFrozen(accounts, freeze)
      // Assert
      if (!this.generic) {
        expect(
          await this.cmtat.canTransfer(this.address1, this.address3, 10)
        ).to.equal(false)
        expect(
          await this.cmtat.canTransfer(this.address2, this.address3, 10)
        ).to.equal(false)
        expect(
          await this.cmtat.canTransfer(this.address1, this.address2, 10)
        ).to.equal(false)
      }
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(true)
      expect(await this.cmtat.isFrozen(this.address2)).to.equal(true)
      // emits a Freeze event
      await expect(this.logs)
        .to.emit(this.cmtat, 'AddressFrozen')
        .withArgs(this.address1, true, sender, REASON_EMPTY_EVENT)
      await expect(this.logs)
        .to.emit(this.cmtat, 'AddressFrozen')
        .withArgs(this.address2, true, sender, REASON_EMPTY_EVENT)
    }

    async function testPartialFreezeBatch (sender) {
      const accounts = [this.address1, this.address2, this.address3]
      const freeze = [false, false, true]

      // Arrange
      testFreezeBatch(sender)

      // Act
      this.logs = await this.cmtat
        .connect(sender)
        .batchSetAddressFrozen(accounts, freeze)
      // Assert
      if (!this.generic) {
        expect(
          await this.cmtat.canTransfer(this.address1, this.address3, 10)
        ).to.equal(false)
        expect(
          await this.cmtat.canTransfer(this.address2, this.address3, 10)
        ).to.equal(false)
        expect(
          await this.cmtat.canTransfer(this.address1, this.address2, 10)
        ).to.equal(true)
      }

      expect(await this.cmtat.isFrozen(this.address1)).to.equal(false)
      expect(await this.cmtat.isFrozen(this.address2)).to.equal(false)
      // emits a Freeze event
      await expect(this.logs)
        .to.emit(this.cmtat, 'AddressFrozen')
        .withArgs(this.address1, false, sender, REASON_EMPTY_EVENT)
      await expect(this.logs)
        .to.emit(this.cmtat, 'AddressFrozen')
        .withArgs(this.address2, false, sender, REASON_EMPTY_EVENT)
      await expect(this.logs)
        .to.emit(this.cmtat, 'AddressFrozen')
        .withArgs(this.address3, true, sender, REASON_EMPTY_EVENT)
    }

    async function testUnfreeze (sender) {
      // Arrange
      await this.cmtat
        .connect(sender)
        .setAddressFrozen(this.address1, true, reasonFreeze)
      // Arrange - Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(true)
      if (!this.generic) {
        expect(
          await this.cmtat.canTransfer(this.address1, this.address2, 10)
        ).to.equal(false)
      }

      // Act
      this.logs = await this.cmtat
        .connect(sender)
        .setAddressFrozen(this.address1, false, reasonUnfreeze)
      // Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(false)
      if (!this.generic) {
        expect(
          await this.cmtat.canTransfer(this.address1, this.address2, 10)
        ).to.equal(true)
      }
      await expect(this.logs)
        .to.emit(this.cmtat, 'AddressFrozen')
        .withArgs(this.address1, false, sender, REASON_UNFREEZE_EVENT)
    }
    beforeEach(async function () {
      await this.cmtat.connect(this.admin).mint(this.address1, 50)
    })

    it('testAdminCanFreezeAddress', async function () {
      const bindTest = testFreeze.bind(this)
      await bindTest(this.admin)
    })

    it('testAdminCanBatchFreezeAddress', async function () {
      const bindTest = testFreezeBatch.bind(this)
      await bindTest(this.admin)
    })

    it('testAdminCanBatchPartialFreezeAddress', async function () {
      const bindTest = testPartialFreezeBatch.bind(this)
      await bindTest(this.admin)
    })

    it('testReasonParameterCanBeEmptyString', async function () {
      // Arrange - Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(false)
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .setAddressFrozen(this.address1, true, REASON_EMPTY)
      // Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(true)
      // emits a Freeze event
      await expect(this.logs)
        .to.emit(this.cmtat, 'AddressFrozen')
        .withArgs(this.address1, true, this.admin, REASON_EMPTY_EVENT)
    })

    it('testEnforcerRoleCanFreezeAddress', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(ENFORCER_ROLE, this.address2)

      const bindTest = testFreeze.bind(this)
      await bindTest(this.address2)
    })

    it('testAdminCanUnfreezeAddress', async function () {
      const bindTest = testUnfreeze.bind(this)
      await bindTest(this.admin)
    })

    it('testEnforcerRoleCanUnfreezeAddress', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(ENFORCER_ROLE, this.address2)
      // Act + assert
      const bindTest = testUnfreeze.bind(this)
      await bindTest(this.address2)
    })

    it('testCannotNonEnforcerFreezeAddress', async function () {
      // Act
      await expect(
        this.cmtat
          .connect(this.address2)
          .setAddressFrozen(this.address1, true, reasonFreeze)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, ENFORCER_ROLE)
      // Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(false)
    })

    it('testCannotNonEnforcerBatchFreezeAddress', async function () {
      const accounts = []
      const freezes = []
      // Act
      await expect(
        this.cmtat
          .connect(this.address2)
          .batchSetAddressFrozen(accounts, freezes)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, ENFORCER_ROLE)
    })

    it('testCannotNonEnforcerUnfreezeAddress', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .setAddressFrozen(this.address1, true, reasonFreeze)
      // Act
      await expect(
        this.cmtat
          .connect(this.address2)
          .setAddressFrozen(this.address1, false, reasonFreeze)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, ENFORCER_ROLE)
      // Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(true)
    })

    it('testCannotTransferWhenFromIsFrozenWithTransfer', async function () {
      const AMOUNT_TO_TRANSFER = 10
      // Act
      await this.cmtat
        .connect(this.admin)
        .setAddressFrozen(this.address1, true, reasonFreeze)
      // Assert
      if (!this.erc1404 && !this.generic) {
        expect(
          await this.cmtat.detectTransferRestriction(
            this.address1,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal(REJECTED_CODE_BASE_TRANSFER_REJECTED_FROM_FROZEN)
        expect(
          await this.cmtat.messageForTransferRestriction(
            REJECTED_CODE_BASE_TRANSFER_REJECTED_FROM_FROZEN
          )
        ).to.equal('AddrFromIsFrozen')
      }
      if (!this.generic) {
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
      }
    })

    it('testCannotTransferTokenWhenToIsisFrozenWithTransferFrom', async function () {
      const AMOUNT_TO_TRANSFER = 10
      // Arrange
      // Define allowance
      if (!this.generic) {
        await this.cmtat
          .connect(this.address3)
          .approve(this.address1, AMOUNT_TO_TRANSFER)
      }
      // Act
      await this.cmtat
        .connect(this.admin)
        .setAddressFrozen(this.address2, true, reasonFreeze)
      if (!this.erc1404 && !this.generic) {
        // Assert
        expect(
          await this.cmtat.detectTransferRestriction(
            this.address3,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal(REJECTED_CODE_BASE_TRANSFER_REJECTED_TO_FROZEN)
        expect(
          await this.cmtat.messageForTransferRestriction(
            REJECTED_CODE_BASE_TRANSFER_REJECTED_TO_FROZEN
          )
        ).to.equal('AddrToIsFrozen')
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

    it('testCannotTransferTokenWhenSpenderIsFrozenWithTransferFrom', async function () {
      const AMOUNT_TO_TRANSFER = 10
      // Arrange
      // Define allowance
      if (!this.generic) {
        await this.cmtat
          .connect(this.address3)
          .approve(this.address1, AMOUNT_TO_TRANSFER)
      }

      // Act
      await this.cmtat
        .connect(this.admin)
        .setAddressFrozen(this.address1, true, reasonFreeze)

      if (!this.generic) {
        expect(
          await this.cmtat.canTransferFrom(
            this.address1,
            this.address3,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal(false)

        if (!this.erc1404 && !this.generic) {
          // Assert
          expect(
            await this.cmtat.detectTransferRestrictionFrom(
              this.address1,
              this.address3,
              this.address2,
              AMOUNT_TO_TRANSFER
            )
          ).to.equal(REJECTED_CODE_BASE_TRANSFER_REJECTED_SPENDER_FROZEN)
          expect(
            await this.cmtat.messageForTransferRestriction(
              REJECTED_CODE_BASE_TRANSFER_REJECTED_SPENDER_FROZEN
            )
          ).to.equal('AddrSpenderIsFrozen')
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
      }
    })

    it('testCannotBatchFrozenIfLengthMismatchTooManyAddresses', async function () {
      // There are too many addresses
      const accounts = [this.address1, this.address2, this.address3]
      const freeze = [false, false]

      // Act
      await expect(
        this.cmtat.connect(this.admin).batchSetAddressFrozen(accounts, freeze)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_Enforcement_AccountsValueslengthMismatch'
      )
    })

    it('testCannotBatchFrozenIfAccountsSIsEmpty', async function () {
      const accounts = []
      const freeze = [false, false]
      await expect(
        this.cmtat.connect(this.admin).batchSetAddressFrozen(accounts, freeze)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_Enforcement_EmptyAccounts'
      )
    })
  })
}
module.exports = EnforcementModuleCommon
