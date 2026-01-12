const { expect } = require('chai')
const { ZERO_ADDRESS,
  IERC165_INTERFACEID, IERC721_INTERFACEID,IACCESSCONTROL_INTERFACEID,
  IERC5679_INTERFACEID } = require('../utils')
const VALUE1 = 20n
const VALUE2 = 50n
function CMTATIntegrationCommon () {
  context('CMTAT integration test', function () {
      /* ============ ERC165 ============ */
    it('testSupportRightInterface', async function () {
      // Assert
      expect(await this.cmtat.supportsInterface(IACCESSCONTROL_INTERFACEID)).to.equal(true)
      expect(await this.cmtat.supportsInterface(IERC165_INTERFACEID)).to.equal(true)
      expect(await this.cmtat.supportsInterface(IERC721_INTERFACEID)).to.equal(
          false)
      expect(await this.cmtat.supportsInterface(IERC5679_INTERFACEID)).to.equal(true)
    })

    it('testCMTATIntegration', async function () {
      /* ============ ERC20 Base Module ============ */
      const NEW_NAME = 'New Name'
      // Act
      this.logs = await this.cmtat.connect(this.admin).setName(NEW_NAME)
      // Assert
      expect(await this.cmtat.name()).to.equal(NEW_NAME)
      await expect(this.logs)
        .to.emit(this.cmtat, 'Name')
        .withArgs(NEW_NAME, NEW_NAME)

      /* ============ Extra information =========== */
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

      /* ============ ERC 7551 information =========== */
      if (this.erc7551) {
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
      }

      /* ============ ERC20 MintModule ============ */
      this.logs = await this.cmtat
        .connect(this.admin)
        .mint(this.address1, VALUE1)

      // Assert
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(VALUE1)
      expect(await this.cmtat.totalSupply()).to.equal(VALUE1)

      // Assert event
      // emits a Transfer event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(ZERO_ADDRESS, this.address1, VALUE1)
      // emits a Mint event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Mint')
        .withArgs(this.admin, this.address1, VALUE1, '0x')

      /* ============ Cross Chain Mint ============ */
      // Act
      // Issue 20 and check balances and total supply
      this.logs = await this.cmtat
        .connect(this.admin)
        .crosschainMint(this.address1, VALUE2)

      // Assert
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(
        VALUE1 + VALUE2
      )
      expect(await this.cmtat.totalSupply()).to.equal(VALUE1 + VALUE2)

      // Assert event
      // emits a Transfer event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(ZERO_ADDRESS, this.address1, VALUE2)
      await expect(this.logs)
        .to.emit(this.cmtat, 'CrosschainMint')
        .withArgs(this.address1, VALUE2, this.admin)

      /* ============ Pause module ============ */

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
    })
  })
}
module.exports = CMTATIntegrationCommon
