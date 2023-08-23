const { expectEvent } = require('@openzeppelin/test-helpers')
const {
  expectRevertCustomError
} = require('../../../openzeppelin-contracts-upgradeable/test/helpers/customError')
const { PAUSER_ROLE, DEFAULT_ADMIN_ROLE } = require('../../utils')
const chai = require('chai')
const should = chai.should()

function AuthorizationModuleCommon (owner, address1, address2) {
  context('Authorization', function () {
    it('testAdminCanGrantRole', async function () {
      // Act
      this.logs = await this.cmtat.grantRole(PAUSER_ROLE, address1, {
        from: owner
      });
      // Assert
      (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(true)
      // emits a RoleGranted event
      expectEvent(this.logs, 'RoleGranted', {
        role: PAUSER_ROLE,
        account: address1,
        sender: owner
      })
    })

    it('testAdminCanRevokeRole', async function () {
      // Arrange
      await this.cmtat.grantRole(PAUSER_ROLE, address1, { from: owner });
      // Arrange - Assert
      (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(true)
      // Act
      this.logs = await this.cmtat.revokeRole(PAUSER_ROLE, address1, {
        from: owner
      });
      // Assert
      (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(false)
      // emits a RoleRevoked event
      expectEvent(this.logs, 'RoleRevoked', {
        role: PAUSER_ROLE,
        account: address1,
        sender: owner
      })
    })

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

    it('testCannotNonAdminRevokeRole', async function () {
      // Arrange
      (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(false)
      await this.cmtat.grantRole(PAUSER_ROLE, address1, { from: owner });
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
  })
}
module.exports = AuthorizationModuleCommon
