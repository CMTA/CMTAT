const { expectEvent, time } = require('@openzeppelin/test-helpers')
const {
  expectRevertCustomError
} = require('../../../openzeppelin-contracts-upgradeable/test/helpers/customError')
const { PAUSER_ROLE, DEFAULT_ADMIN_ROLE } = require('../../utils')
const chai = require('chai')
const should = chai.should()
const { DEFAULT_ADMIN_DELAY_WEB3 } = require('../../deploymentUtils')
function AuthorizationModuleCommon (admin, address1, address2) {
  context('Authorization', function () {
    it('testAdminCanGrantRole', async function () {
      // Act
      this.logs = await this.cmtat.grantRole(PAUSER_ROLE, address1, {
        from: admin
      });
      // Assert
      (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(true)
      // emits a RoleGranted event
      expectEvent(this.logs, 'RoleGranted', {
        role: PAUSER_ROLE,
        account: address1,
        sender: admin
      })
    })

    it('testAdminCanRevokeRole', async function () {
      // Arrange
      await this.cmtat.grantRole(PAUSER_ROLE, address1, { from: admin });
      // Arrange - Assert
      (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(true)
      // Act
      this.logs = await this.cmtat.revokeRole(PAUSER_ROLE, address1, {
        from: admin
      });
      // Assert
      (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(false)
      // emits a RoleRevoked event
      expectEvent(this.logs, 'RoleRevoked', {
        role: PAUSER_ROLE,
        account: address1,
        sender: admin
      })
    })

    /*
    Already tested by OpenZeppelin library
    */
    it('testCannotNonAdminGrantRole', async function () {
      // Arrange - Assert
      (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(false)
      // Act
      await expectRevertCustomError(
        this.cmtat.grantRole(PAUSER_ROLE, address1, { from: address2 }),
        'AccessControlUnauthorizedAccount',
        [address2, DEFAULT_ADMIN_ROLE]
      );
      // Assert
      (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(false)
    })

    /*
    Already tested by OpenZeppelin library
    */
    it('testCannotNonAdminRevokeRole', async function () {
      // Arrange
      (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(false)
      await this.cmtat.grantRole(PAUSER_ROLE, address1, { from: admin });
      // Arrange - Assert
      (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(true)
      // Act
      await expectRevertCustomError(
        this.cmtat.revokeRole(PAUSER_ROLE, address1, { from: address2 }),
        'AccessControlUnauthorizedAccount',
        [address2, DEFAULT_ADMIN_ROLE]
      );
      // Assert
      (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(true)
    })

    /*
    Already tested by OpenZeppelin library
    */
    it('testCanTransferAdminship', async function () {
      // Arrange
      (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(false)
      await this.cmtat.grantRole(PAUSER_ROLE, address1, { from: admin });
      // Arrange - Assert
      (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(true)
      // Act
      await expectRevertCustomError(
        this.cmtat.revokeRole(PAUSER_ROLE, address1, { from: address2 }),
        'AccessControlUnauthorizedAccount',
        [address2, DEFAULT_ADMIN_ROLE]
      );
      // Assert
      (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(true)
    })


    it('testCanAdminTransferAdminship', async function () {
      // Arrange - Assert
      (await this.cmtat.owner()).should.equal(admin)
      // Starts an admin transfer
      await this.cmtat.beginDefaultAdminTransfer(address1, { from: admin });

      // Wait for acceptance
      const acceptSchedule = web3.utils.toBN(await time.latest()).add(DEFAULT_ADMIN_DELAY_WEB3);
      // We jump into the future
      await time.increase(acceptSchedule.addn(1))

      // Act
      await this.cmtat.acceptDefaultAdminTransfer({ from: address1 });

      // Assert
      (await this.cmtat.owner()).should.equal(address1)
    });

    /*
    Already tested by OpenZeppelin library
    */
    it('testCannotNonAdminTransferAdminship', async function () {
      // Arrange - Assert
      (await this.cmtat.owner()).should.equal(admin)
      // Starts an admin transfer
      await expectRevertCustomError(
        this.cmtat.beginDefaultAdminTransfer(address1, { from: address1 }),
        'AccessControlUnauthorizedAccount',
        [address1, DEFAULT_ADMIN_ROLE]
      );
      // Assert
      (await this.cmtat.owner()).should.equal(admin)
    });

    it('testCanAdminTransferAdminshipDirectly', async function () {
      // Arrange - Assert
      (await this.cmtat.owner()).should.equal(admin)

      // Act
      // Transfer the rights
      await this.cmtat.transferAdminshipDirectly(address1, { from: admin });

      // Assert
      (await this.cmtat.owner()).should.equal(address1)
    });

    it('testCannotNonAdminTransferAdminshipDirectly', async function () {
      // Arrange - Assert
      (await this.cmtat.owner()).should.equal(admin)
      // Transfer the rights
      await expectRevertCustomError(
        this.cmtat.transferAdminshipDirectly(address1, { from: address2 }),
        'AccessControlUnauthorizedAccount',
        [address2, DEFAULT_ADMIN_ROLE]
      );

      // Assert
      (await this.cmtat.owner()).should.equal(admin)
    });
  })
}
module.exports = AuthorizationModuleCommon
