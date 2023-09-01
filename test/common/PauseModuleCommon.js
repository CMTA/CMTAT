const { expectEvent } = require('@openzeppelin/test-helpers')
const {
  expectRevertCustomError
} = require('../../openzeppelin-contracts-upgradeable/test/helpers/customError.js')
const { PAUSER_ROLE, DEFAULT_ADMIN_ROLE } = require('../utils')
const { should } = require('chai').should()

function PauseModuleCommon (admin, address1, address2, address3) {
  context('Pause', function () {
    /**
    The admin is assigned the PAUSER role when the contract is deployed
    */
    it('testCanBePausedByAdmin', async function () {
      const AMOUNT_TO_TRANSFER = 10
      // Act
      this.logs = await this.cmtat.pause({ from: admin });

      // Assert
      (await this.cmtat.paused()).should.equal(true)
      // emits a Paused event
      expectEvent(this.logs, 'Paused', { account: admin })
      // Transfer is reverted
      await expectRevertCustomError(
        this.cmtat.transfer(address2, AMOUNT_TO_TRANSFER, { from: address1 }),
        'CMTAT_InvalidTransfer',
        [address1, address2, AMOUNT_TO_TRANSFER]
      )
    })

    it('testCanBePausedByPauserRole', async function () {
      const AMOUNT_TO_TRANSFER = 10
      // Arrange
      await this.cmtat.grantRole(PAUSER_ROLE, address1, { from: admin })

      // Act
      this.logs = await this.cmtat.pause({ from: address1 });

      // Assert
      (await this.cmtat.paused()).should.equal(true)
      // emits a Paused event
      expectEvent(this.logs, 'Paused', { account: address1 })
      // Transfer is reverted
      await expectRevertCustomError(
        this.cmtat.transfer(address2, AMOUNT_TO_TRANSFER, { from: address1 }),
        'CMTAT_InvalidTransfer',
        [address1, address2, AMOUNT_TO_TRANSFER]
      )
      
    })

    it('testCannotBePausedByNonPauser', async function () {
      // Act
      await expectRevertCustomError(
        this.cmtat.pause({ from: address1 }),
        'AccessControlUnauthorizedAccount',
        [address1, PAUSER_ROLE]
      )
    })

    it('testCanBeUnpausedByAdmin', async function () {
      // Arrange
      await this.cmtat.pause({ from: admin })

      // Act
      this.logs = await this.cmtat.unpause({ from: admin });

      // Assert
      (await this.cmtat.paused()).should.equal(false)
      // emits a Unpaused event
      expectEvent(this.logs, 'Unpaused', { account: admin })
      // Transfer works
      this.cmtat.transfer(address2, 10, { from: address1 })
    })

    it('testCanBeUnpausedByANewPauser', async function () {
      // Arrange
      await this.cmtat.pause({ from: admin })
      await this.cmtat.grantRole(PAUSER_ROLE, address1, { from: admin })

      // Act
      this.logs = await this.cmtat.unpause({ from: address1 });

      // Assert
      (await this.cmtat.paused()).should.equal(false)
      // emits a Unpaused event
      expectEvent(this.logs, 'Unpaused', { account: address1 })
      // Transfer works
      this.cmtat.transfer(address2, 10, { from: address1 })
    })

    it('testCannotBeUnpausedByNonPauser', async function () {
      // Arrange
      await this.cmtat.pause({ from: admin })
      // Act
      await expectRevertCustomError(
        this.cmtat.unpause({ from: address1 }),
        'AccessControlUnauthorizedAccount',
        [address1, PAUSER_ROLE]
      )
    })

    // reverts if address1 transfers tokens to address2 when paused
    it('testCannotTransferTokenWhenPausedWithTransfer', async function () {
      const AMOUNT_TO_TRANSFER = 10
      // Act
      await this.cmtat.pause({ from: admin });
      // Assert
      (
        await this.cmtat.detectTransferRestriction(
          address1,
          address2,
          AMOUNT_TO_TRANSFER
        )
      ).should.be.bignumber.equal('1');
      (await this.cmtat.messageForTransferRestriction(1)).should.equal(
        'All transfers paused'
      )
      await expectRevertCustomError(
        this.cmtat.transfer(address2, AMOUNT_TO_TRANSFER, { from: address1 }),
        'CMTAT_InvalidTransfer',
        [address1, address2, AMOUNT_TO_TRANSFER]
      )
    })

    // reverts if address3 transfers tokens from address1 to address2 when paused
    it('testCannotTransferTokenWhenPausedWithTransferFrom', async function () {
      const AMOUNT_TO_TRANSFER = 10
      // Arrange
      // Define allowance
      await this.cmtat.approve(address3, 20, { from: address1 })

      // Act
      await this.cmtat.pause({ from: admin });

      // Assert
      (
        await this.cmtat.detectTransferRestriction(
          address1,
          address2,
          AMOUNT_TO_TRANSFER
        )
      ).should.be.bignumber.equal('1');
      (await this.cmtat.messageForTransferRestriction(1)).should.equal(
        'All transfers paused'
      )
      await expectRevertCustomError(
        this.cmtat.transferFrom(address1, address2, AMOUNT_TO_TRANSFER, {
          from: address3
        }),
        'CMTAT_InvalidTransfer',
        [address1, address2, AMOUNT_TO_TRANSFER]
      )
    })
  })

  context('DeactivateContract', function () {
    /**
    The admin is assigned the PAUSER role when the contract is deployed
    */
    it('testCanDeactivatedByAdmin', async function () {
      const AMOUNT_TO_TRANSFER = 10
      // Act
      this.logs = await this.cmtat.deactivateContract({ from: admin });

      // Assert
      (await this.cmtat.deactivated()).should.equal(true);
      // Contract is in pause state
      (await this.cmtat.paused()).should.equal(true)
      // emits a Deactivated event
      expectEvent(this.logs, 'Deactivated', { account: admin })
      // Transfer is reverted because contract is in paused state
      await expectRevertCustomError(
        this.cmtat.transfer(address2, AMOUNT_TO_TRANSFER, { from: address1 }),
        'CMTAT_InvalidTransfer',
        [address1, address2, AMOUNT_TO_TRANSFER]
      )

      // Unpause is reverted
      await expectRevertCustomError(this.cmtat.unpause({ from: admin }),
        'CMTAT_PauseModule_ContractIsDeactivated',
        []
      )
    })

    it('testCannotBeDeactivatedByNonAdmin', async function () {
      // Act
      await expectRevertCustomError(
        this.cmtat.deactivateContract({ from: address1 }),
        'AccessControlUnauthorizedAccount',
        [address1, DEFAULT_ADMIN_ROLE]
      );
      // Assert
      (await this.cmtat.deactivated()).should.equal(false)
    })
  })
}
module.exports = PauseModuleCommon
