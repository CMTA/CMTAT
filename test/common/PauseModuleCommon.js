const {
  PAUSER_ROLE,
  DEFAULT_ADMIN_ROLE,
  REJECTED_CODE_BASE_TRANSFER_REJECTED_PAUSED,
  REJECTED_CODE_BASE_TRANSFER_REJECTED_DEACTIVATED
} = require('../utils')
const { expect } = require('chai')
function PauseModuleCommon () {
  context('Pause', function () {
    /*//////////////////////////////////////////////////////////////
                          ACCESS CONTROL
    //////////////////////////////////////////////////////////////*/
    /**
     * The admin is assigned the PAUSER role when the contract is deployed
     */
    it('testCanBePausedByAdmin', async function () {
      const AMOUNT_TO_TRANSFER = 10n
      // Act
      this.logs = await this.cmtat.connect(this.admin).pause()

      // Assert
      expect(await this.cmtat.paused()).to.equal(true)
      // emits a Paused event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Paused')
        .withArgs(this.admin)
      // Transfer is reverted
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

    it('testCanBePausedByPauserRole', async function () {
      const AMOUNT_TO_TRANSFER = 10n
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(PAUSER_ROLE, this.address1)

      // Act
      this.logs = await this.cmtat.connect(this.address1).pause()

      // Assert
      expect(await this.cmtat.paused()).to.equal(true)
      // emits a Paused event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Paused')
        .withArgs(this.address1)
      if (!this.generic) {
        // Transfer is reverted
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

    it('testCannotBePausedByNonPauser', async function () {
      await expect(this.cmtat.connect(this.address1).pause())
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, PAUSER_ROLE)
    })

    it('testCanBeUnpausedByAdmin', async function () {
      // Arrange
      await this.cmtat.connect(this.admin).pause()

      // Act
      this.logs = await this.cmtat.connect(this.admin).unpause()

      // Assert
      expect(await this.cmtat.paused()).to.equal(false)
      // emits a Unpaused event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Unpaused')
        .withArgs(this.admin)
      // Transfer works
      if (!this.generic) {
        this.cmtat.connect(this.address1).transfer(this.address2, 10n)
      }
    })

    it('testCanBeUnpausedByANewPauser', async function () {
      // Arrange
      await this.cmtat.connect(this.admin).pause()
      await this.cmtat
        .connect(this.admin)
        .grantRole(PAUSER_ROLE, this.address1)

      // Act
      this.logs = await this.cmtat.connect(this.address1).unpause()

      // Assert
      expect(await this.cmtat.paused()).to.equal(false)
      // emits a Unpaused event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Unpaused')
        .withArgs(this.address1)
      // Transfer works
      if (!this.generic) {
        this.cmtat.connect(this.address1).transfer(this.address2, 10n)
      }
    })

    it('testCannotBeUnpausedByNonPauser', async function () {
      // Arrange
      await this.cmtat.connect(this.admin).pause()
      // Act
      await expect(this.cmtat.connect(this.address1).unpause())
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, PAUSER_ROLE)
    })

    /*//////////////////////////////////////////////////////////////
                          COMPLIANCE
    //////////////////////////////////////////////////////////////*/


    // reverts if address1 transfers tokens to address2 when paused
    it('testCannotTransferTokenWhenPausedWithTransfer', async function () {
      const AMOUNT_TO_TRANSFER = 10n
      // Act
      await this.cmtat.connect(this.admin).pause()
      // Act + Assert
      if (!this.generic) {
        expect(
          await this.cmtat.canTransfer(
            this.address1,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal(false)

        expect(
          await this.cmtat.canTransferFrom(
            this.address3,
            this.address1,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal(false)
      }

      if (!this.erc1404 && !this.generic) {
        // Assert
        expect(
          await this.cmtat.detectTransferRestriction(
            this.address1,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal(REJECTED_CODE_BASE_TRANSFER_REJECTED_PAUSED)
        expect(
          await this.cmtat.detectTransferRestrictionFrom(
            this.address3,
            this.address1,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal(REJECTED_CODE_BASE_TRANSFER_REJECTED_PAUSED)
        expect(
          await this.cmtat.messageForTransferRestriction(
            REJECTED_CODE_BASE_TRANSFER_REJECTED_PAUSED
          )
        ).to.equal('EnforcedPause')
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

    // reverts if address3 transfers tokens from address1 to address2 when paused
    it('testCannotTransferTokenWhenPausedWithTransferFrom', async function () {
      const AMOUNT_TO_TRANSFER = 10n
      // Arrange
      // Define allowance
      if (!this.generic) {
        await this.cmtat.connect(this.address1).approve(this.address3, 20)
      }
      if (!this.generic) {
        expect(
          await this.cmtat.canTransfer(
            this.address1,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal(true)

        expect(
          await this.cmtat.canTransferFrom(
            this.address3,
            this.address1,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal(true)
      }

      // Act
      await this.cmtat.connect(this.admin).pause()
      if (!this.generic) {
        expect(
          await this.cmtat.canTransfer(
            this.address1,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal(false)

        expect(
          await this.cmtat.canTransferFrom(
            this.address3,
            this.address1,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal(false)
      }

      if (!this.erc1404 && !this.generic) {
        // Assert
        expect(
          await this.cmtat.detectTransferRestrictionFrom(
            this.address3,
            this.address1,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal(REJECTED_CODE_BASE_TRANSFER_REJECTED_PAUSED)
        expect(
          await this.cmtat.detectTransferRestriction(
            this.address1,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal(REJECTED_CODE_BASE_TRANSFER_REJECTED_PAUSED)
        // Assert
        expect(
          await this.cmtat.detectTransferRestrictionFrom(
            this.address1,
            this.address3,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal(REJECTED_CODE_BASE_TRANSFER_REJECTED_PAUSED)
        expect(
          await this.cmtat.messageForTransferRestriction(
            REJECTED_CODE_BASE_TRANSFER_REJECTED_PAUSED
          )
        ).to.equal('EnforcedPause')
        await expect(
          this.cmtat
            .connect(this.address3)
            .transferFrom(this.address1, this.address2, AMOUNT_TO_TRANSFER)
        )
          .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_InvalidTransfer')
          .withArgs(
            this.address1.address,
            this.address2.address,
            AMOUNT_TO_TRANSFER
          )
      }
    })
  })

  context('DeactivateContract', function () {
    /**
     * The admin is assigned the PAUSER role when the contract is deployed
     */
    it('testCanDeactivatedByAdminIfContractIsPaused', async function () {
      const AMOUNT_TO_TRANSFER = 10n
      // Arrange
      await this.cmtat.connect(this.admin).pause()

      // Act
      this.logs = await this.cmtat.connect(this.admin).deactivateContract()

      // Assert
      expect(await this.cmtat.deactivated()).to.equal(true)
      // Contract is in pause state
      expect(await this.cmtat.paused()).to.equal(true)
      // emits a Deactivated event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Deactivated')
        .withArgs(this.admin)
      // Transfer is reverted because contract is in paused state
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

      if (!this.generic) {
        expect(
          await this.cmtat.canTransfer(
            this.address1,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal(false)

        expect(
          await this.cmtat.canTransferFrom(
            this.address3,
            this.address1,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal(false)
      }

      if (!this.erc1404 && !this.generic) {
        // Assert
        expect(
          await this.cmtat.detectTransferRestrictionFrom(
            this.address3,
            this.address1,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal(REJECTED_CODE_BASE_TRANSFER_REJECTED_DEACTIVATED)
        expect(
          await this.cmtat.detectTransferRestriction(
            this.address1,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal(REJECTED_CODE_BASE_TRANSFER_REJECTED_DEACTIVATED)
        // Assert
        expect(
          await this.cmtat.detectTransferRestrictionFrom(
            this.address1,
            this.address3,
            this.address2,
            AMOUNT_TO_TRANSFER
          )
        ).to.equal(REJECTED_CODE_BASE_TRANSFER_REJECTED_DEACTIVATED)
        expect(
          await this.cmtat.messageForTransferRestriction(
            REJECTED_CODE_BASE_TRANSFER_REJECTED_DEACTIVATED
          )
        ).to.equal('ContractDeactivated')
        await expect(
          this.cmtat
            .connect(this.address3)
            .transferFrom(this.address1, this.address2, AMOUNT_TO_TRANSFER)
        )
          .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_InvalidTransfer')
          .withArgs(
            this.address1.address,
            this.address2.address,
            AMOUNT_TO_TRANSFER
          )
      }

      // Unpause is reverted
      await expect(
        this.cmtat.connect(this.admin).unpause()
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_PauseModule_ContractIsDeactivated'
      )
    })

    it('testCannotDeactivatedIfNotInPause', async function () {
      // Arrange
      await expect(
        this.cmtat.connect(this.admin).deactivateContract()
      ).to.be.revertedWithCustomError(this.cmtat, 'ExpectedPause')
    })

    it('testCannotBeDeactivatedByNonAdmin', async function () {
      // Act
      await expect(this.cmtat.connect(this.address1).deactivateContract())
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, DEFAULT_ADMIN_ROLE)
      // Assert
      expect(await this.cmtat.deactivated()).to.equal(false)
    })
  })
}
module.exports = PauseModuleCommon
