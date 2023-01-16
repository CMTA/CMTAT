const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { PAUSER_ROLE } = require('../../utils')
const chai = require('chai')
const expect = chai.expect
const should = chai.should()

function AuthorizationModuleCommon (owner, address1, address2) {
  context('Authorization', function () {
    it('testAdminCanGrantRole', async function () {
      // Act
      ({ logs: this.logs } = await this.cmtat.grantRole(
        PAUSER_ROLE,
        address1,
        { from: owner }
      ));
      // Assert
      (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(true)
      // emits a RoleGranted event
      expectEvent.inLogs(this.logs, 'RoleGranted', {
        role: PAUSER_ROLE,
        account: address1,
        sender: owner
      })
    })

    it('testAdminCanRevokeRole', async function () {
      // Arrange
      await this.cmtat.grantRole(PAUSER_ROLE, address1, { from: owner });
      // Arrange - Assert
      (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(true);
      // Act
      ({ logs: this.logs } = await this.cmtat.revokeRole(
        PAUSER_ROLE,
        address1,
        { from: owner }
      ));
      // Assert
      (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(false)
      // emits a RoleRevoked event
      expectEvent.inLogs(this.logs, 'RoleRevoked', {
        role: PAUSER_ROLE,
        account: address1,
        sender: owner
      })
    })

    it('testCannotNonAdminGrantRole', async function () {
      // Arrange - Assert
      (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(false)
      // Act
      await expectRevert(
        this.cmtat.grantRole(PAUSER_ROLE, address1, { from: address2 }),
        'AccessControl: account ' +
          address2.toLowerCase() +
          ' is missing role 0x0000000000000000000000000000000000000000000000000000000000000000'
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
      await expectRevert(
        this.cmtat.revokeRole(PAUSER_ROLE, address1, { from: address2 }),
        'AccessControl: account ' +
          address2.toLowerCase() +
          ' is missing role 0x0000000000000000000000000000000000000000000000000000000000000000'
      );
      // Assert
      (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(true)
    })
  })
}
module.exports = AuthorizationModuleCommon
