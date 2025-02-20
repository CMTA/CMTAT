const { ENFORCER_ROLE } = require('../utils')
const { expect } = require('chai')


const REASON_FREEZE_STRING = 'testFreeze'
const REASON_FREEZE_EVENT = ethers.toUtf8Bytes(REASON_FREEZE_STRING)
const reasonFreeze = ethers.Typed.bytes(REASON_FREEZE_EVENT);
const REASON_FREEZE_EMPTY = ethers.Typed.bytes(ethers.toUtf8Bytes(""))


const REASON_STRING = 'testUnfreeze'
const REASON_UNFREEZE_EVENT = ethers.toUtf8Bytes(REASON_STRING)
const reasonUnfreeze = ethers.Typed.bytes(REASON_UNFREEZE_EVENT);
const REASON_EMPTY = ethers.Typed.bytes(ethers.toUtf8Bytes(""))
const REASON_EMPTY_EVENT = ethers.toUtf8Bytes("")
function EnforcementModuleCommon () {
  context('Freeze', function () {
    beforeEach(async function () {
      await this.cmtat.connect(this.admin).mint(this.address1, 50)
    })

    it('testAdminCanFreezeAddress', async function () {
      // Arrange - Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(false)
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .setAddressFrozen(this.address1, true, reasonFreeze)
      // Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(true)
      // emits a Freeze event
      await expect(this.logs)
        .to.emit(this.cmtat, 'AddressFrozen')
        .withArgs(this.address1, true, this.admin, REASON_FREEZE_EVENT)
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
        .withArgs(this.address1,  true, this.admin, REASON_EMPTY_EVENT )
    })

    it('testEnforcerRoleCanFreezeAddress', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(ENFORCER_ROLE, this.address2)
      // Arrange - Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(false)
      // Act
      this.logs = await this.cmtat
        .connect(this.address2)
        .setAddressFrozen(this.address1, true, reasonFreeze)
      // Act + Assert
      // Act + Assert
      expect(
        await this.cmtat.canTransfer(this.address1, this.address2, 10)
      ).to.equal(false)
      // Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(true)

      // emits a Freeze event
      await expect(this.logs)
        .to.emit(this.cmtat, 'AddressFrozen')
        .withArgs(this.address1, true,this.address2, REASON_FREEZE_EVENT)
    })

    it('testAdminCanUnfreezeAddress', async function () {
      // Arrange
      await this.cmtat.connect(this.admin).setAddressFrozen(this.address1, true, reasonFreeze)
      // Arrange - Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(true)
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .setAddressFrozen(this.address1, false, reasonUnfreeze)
      // Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(false)
      await expect(this.logs)
        .to.emit(this.cmtat, 'AddressFrozen')
        .withArgs(this.address1, false, this.admin, REASON_UNFREEZE_EVENT)
    })

    it('testEnforcerRoleCanUnfreezeAddress', async function () {
      // Arrange
      await this.cmtat.connect(this.admin).setAddressFrozen(this.address1, true, reasonFreeze)
      await this.cmtat
        .connect(this.admin)
        .grantRole(ENFORCER_ROLE, this.address2)
      // Arrange - Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(true)
      // Act
      this.logs = await this.cmtat
        .connect(this.address2)
        .setAddressFrozen(this.address1, false, reasonUnfreeze)
      // Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(false)
      // emits an Unfreeze event
      await expect(this.logs)
        .to.emit(this.cmtat, 'AddressFrozen')
        .withArgs(this.address1, false, this.address2, REASON_UNFREEZE_EVENT)
    })

    it('testCannotNonEnforcerFreezeAddress', async function () {
      // Act
      await expect(
        this.cmtat.connect(this.address2).setAddressFrozen(this.address1, true, reasonFreeze)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, ENFORCER_ROLE)
      // Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(false)
    })

    it('testCannotNonEnforcerUnfreezeAddress', async function () {
      // Arrange
      await this.cmtat.connect(this.admin).setAddressFrozen(this.address1, true, reasonFreeze)
      // Act
      await expect(
        this.cmtat.connect(this.address2).setAddressFrozen(this.address1, false, reasonFreeze)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, ENFORCER_ROLE)
      // Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(true)
    })

    // reverts if address1 transfers tokens to address2 when paused
    it('testCannotTransferWhenFromIsisFrozenWithTransfer', async function () {
      // Act
      await this.cmtat.connect(this.admin).setAddressFrozen(this.address1, true, reasonFreeze)
      // Assert
      expect(
        await this.cmtat.detectTransferRestriction(
          this.address1,
          this.address2,
          10
        )
      ).to.equal('2')
      expect(await this.cmtat.messageForTransferRestriction(2)).to.equal(
        'Address FROM is frozen'
      )
      const AMOUNT_TO_TRANSFER = 10
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
    it('testCannotTransferTokenWhenToIsisFrozenWithTransferFrom', async function () {
      // Arrange
      // Define allowance
      await this.cmtat.connect(this.address3).approve(this.address1, 20)
      // Act
      await this.cmtat.connect(this.admin).setAddressFrozen(this.address2, true, reasonFreeze)

      // Assert
      expect(
        await this.cmtat.detectTransferRestriction(
          this.address1,
          this.address2,
          10
        )
      ).to.equal('3')
      expect(await this.cmtat.messageForTransferRestriction(3)).to.equal(
        'Address TO is frozen'
      )
      const AMOUNT_TO_TRANSFER = 10
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


   /* it('testFreezeDoesNotEmitEventIfAddressAlreadyisFrozen', async function () {
      // Arrange - Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(false)
      // Arrange
      await this.cmtat.connect(this.admin).setAddressFrozen(this.address1, true, reasonFreeze)
      // Arrange - Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(true)
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .setAddressFrozen(this.address1, true, reasonFreeze)
      // Assert
      await expect(this.logs).to.not.emit(this.cmtat, 'AddressFrozen')
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(true)
    })

    it('testUnfreezeDoesNotEmitEventIfAddressAlreadyUnisFrozen', async function () {
      // Arrange
      await this.cmtat.connect(this.admin).setAddressFrozen(this.address1, true, reasonFreeze)
      // Arrange - Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(true)
      await this.cmtat
        .connect(this.admin)
        .setAddressFrozen(this.address1, true, reasonFreeze)

      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .setAddressFrozen(this.address1, true, reasonUnfreeze)
      // Assert
      await expect(this.logs).to.not.emit(this.cmtat, 'AddressFrozen')
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(false)
    })*/
  })
}
module.exports = EnforcementModuleCommon
