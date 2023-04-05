const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { PAUSER_ROLE, CMTAT_TRANSFER_REJECT } = require('../utils')
const { should } = require('chai').should()

function PauseModuleCommon (admin, address1, address2, address3) {
  context('Pause', function () {
    /**
    The admin is assigned the PAUSER role when the contract is deployed
    */
    it('testCanBePausedByAdmin', async function () {
      // Act
      ({ logs: this.logs } = await this.cmtat.pause({ from: admin }))

      // Assert
      // emits a Paused event
      expectEvent.inLogs(this.logs, 'Paused', { account: admin })
      // Transfer is reverted
      await expectRevert(
        this.cmtat.transfer(address2, 10, { from: address1 }),
        CMTAT_TRANSFER_REJECT
      )
    })

    it('testCanBePausedByPauserRole', async function () {
      // Arrange
      await this.cmtat.grantRole(PAUSER_ROLE, address1, { from: admin });

      // Act
      ({ logs: this.logs } = await this.cmtat.pause({ from: address1 }))

      // Assert
      // emits a Paused event
      expectEvent.inLogs(this.logs, 'Paused', { account: address1 })
      // Transfer is reverted
      await expectRevert(
        this.cmtat.transfer(address2, 10, { from: address1 }),
        CMTAT_TRANSFER_REJECT
      )
    })

    it('testCannotBePausedByNonPauser', async function () {
      // Act
      await expectRevert(
        this.cmtat.pause({ from: address1 }),
        'AccessControl: account ' +
          address1.toLowerCase() +
          ' is missing role ' +
          PAUSER_ROLE
      )
    })

    it('testCanBeUnpausedByAdmin', async function () {
      // Arrange
      await this.cmtat.pause({ from: admin });

      // Act
      ({ logs: this.logs } = await this.cmtat.unpause({ from: admin }))

      // Assert
      // emits a Unpaused event
      expectEvent.inLogs(this.logs, 'Unpaused', { account: admin })
      // Transfer works
      this.cmtat.transfer(address2, 10, { from: address1 })
    })

    it('testCanBeUnpausedByANewPauser', async function () {
      // Arrange
      await this.cmtat.pause({ from: admin })
      await this.cmtat.grantRole(PAUSER_ROLE, address1, { from: admin });

      // Act
      ({ logs: this.logs } = await this.cmtat.unpause({ from: address1 }))

      // Assert
      // emits a Unpaused event
      expectEvent.inLogs(this.logs, 'Unpaused', { account: address1 })
      // Transfer works
      this.cmtat.transfer(address2, 10, { from: address1 })
    })

    it('testCannotBeUnpausedByNonPauser', async function () {
      // Arrange
      await this.cmtat.pause({ from: admin })
      // Act
      await expectRevert(
        this.cmtat.unpause({ from: address1 }),
        'AccessControl: account ' +
          address1.toLowerCase() +
          ' is missing role ' +
          PAUSER_ROLE
      )
    })

    // reverts if address1 transfers tokens to address2 when paused
    it('testCannotTransferTokenWhenPaused_A', async function () {
      // Act
      await this.cmtat.pause({ from: admin });
      // Assert
      (
        await this.cmtat.detectTransferRestriction(address1, address2, 10)
      ).should.be.bignumber.equal('1');
      (await this.cmtat.messageForTransferRestriction(1)).should.equal(
        'All transfers paused'
      )
      await expectRevert(
        this.cmtat.transfer(address2, 10, { from: address1 }),
        CMTAT_TRANSFER_REJECT
      )
    })

    // reverts if address3 transfers tokens from address1 to address2 when paused
    it('testCannotTransferTokenWhenPaused_B', async function () {
      // Arrange
      // Define allowance
      await this.cmtat.approve(address3, 20, { from: address1 })

      // Act
      await this.cmtat.pause({ from: admin });

      // Assert
      (
        await this.cmtat.detectTransferRestriction(address1, address2, 10)
      ).should.be.bignumber.equal('1');
      (await this.cmtat.messageForTransferRestriction(1)).should.equal(
        'All transfers paused'
      )
      await expectRevert(
        this.cmtat.transferFrom(address1, address2, 10, { from: address3 }),
        CMTAT_TRANSFER_REJECT
      )
    })
  })
}
module.exports = PauseModuleCommon
