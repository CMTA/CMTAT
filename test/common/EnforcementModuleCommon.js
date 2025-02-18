const { ENFORCER_ROLE } = require('../utils')
const { expect } = require('chai')
const reasonFreeze = 'testFreeze'
const reasonUnfreeze = 'testUnfreeze'

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
        .freeze(this.address1, reasonFreeze)
      // Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(true)
      // emits a Freeze event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Freeze')
        .withArgs(this.admin, this.address1, reasonFreeze, reasonFreeze)
    })

    it('testReasonParameterCanBeEmptyString', async function () {
      // Arrange - Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(false)
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .freeze(this.address1, '')
      // Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(true)
      // emits a Freeze event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Freeze')
        .withArgs(this.admin, this.address1, '', '')
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
        .freeze(this.address1, reasonFreeze)
      // Act + Assert
      // Act + Assert
      expect(
        await this.cmtat.canTransfer(this.address1, this.address2, 10)
      ).to.equal(false)
      // Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(true)

      // emits a Freeze event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Freeze')
        .withArgs(this.address2, this.address1, reasonFreeze, reasonFreeze)
    })

    it('testAdminCanUnfreezeAddress', async function () {
      // Arrange
      await this.cmtat.connect(this.admin).freeze(this.address1, reasonFreeze)
      // Arrange - Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(true)
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .unfreeze(this.address1, reasonUnfreeze)
      // Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(false)
      await expect(this.logs)
        .to.emit(this.cmtat, 'Unfreeze')
        .withArgs(this.admin, this.address1, reasonUnfreeze, reasonUnfreeze)
    })

    it('testEnforcerRoleCanUnfreezeAddress', async function () {
      // Arrange
      await this.cmtat.connect(this.admin).freeze(this.address1, reasonFreeze)
      await this.cmtat
        .connect(this.admin)
        .grantRole(ENFORCER_ROLE, this.address2)
      // Arrange - Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(true)
      // Act
      this.logs = await this.cmtat
        .connect(this.address2)
        .unfreeze(this.address1, reasonUnfreeze)
      // Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(false)
      // emits an Unfreeze event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Unfreeze')
        .withArgs(this.address2, this.address1, reasonUnfreeze, reasonUnfreeze)
    })

    it('testCannotNonEnforcerFreezeAddress', async function () {
      // Act
      await expect(
        this.cmtat.connect(this.address2).freeze(this.address1, reasonFreeze)
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
      await this.cmtat.connect(this.admin).freeze(this.address1, reasonFreeze)
      // Act
      await expect(
        this.cmtat.connect(this.address2).unfreeze(this.address1, reasonFreeze)
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
      await this.cmtat.connect(this.admin).freeze(this.address1, reasonFreeze)
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
      await this.cmtat.connect(this.admin).freeze(this.address2, reasonFreeze)

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

    // Improvement: check the return value but it is not possible to get the return value of a state modifying function
    it('testFreezeDoesNotEmitEventIfAddressAlreadyisFrozen', async function () {
      // Arrange - Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(false)
      // Arrange
      await this.cmtat.connect(this.admin).freeze(this.address1, reasonFreeze)
      // Arrange - Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(true)
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .freeze(this.address1, reasonFreeze)
      // Assert
      await expect(this.logs).to.not.emit(this.cmtat, 'Freeze')
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(true)
    })

    // Improvement: check the return value but it is not possible to get the return value of a state modifying function
    it('testUnfreezeDoesNotEmitEventIfAddressAlreadyUnisFrozen', async function () {
      // Arrange
      await this.cmtat.connect(this.admin).freeze(this.address1, reasonFreeze)
      // Arrange - Assert
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(true)
      await this.cmtat
        .connect(this.admin)
        .unfreeze(this.address1, reasonFreeze)

      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .unfreeze(this.address1, reasonUnfreeze)
      // Assert
      await expect(this.logs).to.not.emit(this.cmtat, 'Unfreeze')
      expect(await this.cmtat.isFrozen(this.address1)).to.equal(false)
    })
  })
}
module.exports = EnforcementModuleCommon
