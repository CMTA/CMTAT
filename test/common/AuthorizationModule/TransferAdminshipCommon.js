const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { DEFAULT_ADMIN_ROLE, MINTER_ROLE, BURNER_ROLE, ENFORCER_ROLE, SNAPSHOOTER_ROLE } = require('../../utils')
const { should } = require('chai').should()
const { ZERO_ADDRESS } = require('../../utils')
function TransferAdminshipCommon (oldAdmin, newAdmin, attacker) {
  context('Token structure', function () {
    it('testCanTransferAdminship', async function () {
      // Act
      (await this.cmtat.transferAdminship(newAdmin, { from: oldAdmin }));
      // Assert
      // newAdmin
      (await this.cmtat.hasRole(MINTER_ROLE, newAdmin)).should.equal(true);
      (await this.cmtat.hasRole(BURNER_ROLE, newAdmin)).should.equal(true);
      (await this.cmtat.hasRole(ENFORCER_ROLE, newAdmin)).should.equal(true);
      (await this.cmtat.hasRole(SNAPSHOOTER_ROLE, newAdmin)).should.equal(true);
      (await this.cmtat.hasRole(DEFAULT_ADMIN_ROLE, newAdmin)).should.equal(true);
      // oldAdmin
      (await this.cmtat.hasRole(MINTER_ROLE, oldAdmin)).should.equal(false);
      (await this.cmtat.hasRole(BURNER_ROLE, oldAdmin)).should.equal(false);
      (await this.cmtat.hasRole(ENFORCER_ROLE, oldAdmin)).should.equal(false);
      (await this.cmtat.hasRole(SNAPSHOOTER_ROLE, oldAdmin)).should.equal(false);
      (await this.cmtat.hasRole(DEFAULT_ADMIN_ROLE, oldAdmin)).should.equal(false)
    })
    it('testCannotTransferAdminshipToTheZeroAddress', async function () {
      // Act
      await expectRevert(
        this.cmtat.transferAdminship(ZERO_ADDRESS, { from: oldAdmin }),
        'Address 0 not allowed'
      );
      // Assert
      // newAdmin
      (await this.cmtat.hasRole(MINTER_ROLE, newAdmin)).should.equal(false);
      (await this.cmtat.hasRole(BURNER_ROLE, newAdmin)).should.equal(false);
      (await this.cmtat.hasRole(ENFORCER_ROLE, newAdmin)).should.equal(false);
      (await this.cmtat.hasRole(SNAPSHOOTER_ROLE, newAdmin)).should.equal(false);
      (await this.cmtat.hasRole(DEFAULT_ADMIN_ROLE, newAdmin)).should.equal(false);
      // oldAdmin
      (await this.cmtat.hasRole(MINTER_ROLE, oldAdmin)).should.equal(true);
      (await this.cmtat.hasRole(BURNER_ROLE, oldAdmin)).should.equal(true);
      (await this.cmtat.hasRole(ENFORCER_ROLE, oldAdmin)).should.equal(true);
      (await this.cmtat.hasRole(SNAPSHOOTER_ROLE, oldAdmin)).should.equal(true);
      (await this.cmtat.hasRole(DEFAULT_ADMIN_ROLE, oldAdmin)).should.equal(true)
    })
    it('testCanTransferAdminshipWithoutMinterRole', async function () {
      // Arrange
      await this.cmtat.renounceRole(MINTER_ROLE, oldAdmin);
      // Act
      (await this.cmtat.transferAdminship(newAdmin, { from: oldAdmin }));
      // Assert
      // newAdmin
      // The minter role is not granted to the new admin
      (await this.cmtat.hasRole(MINTER_ROLE, newAdmin)).should.equal(false);
      (await this.cmtat.hasRole(BURNER_ROLE, newAdmin)).should.equal(true);
      (await this.cmtat.hasRole(ENFORCER_ROLE, newAdmin)).should.equal(true);
      (await this.cmtat.hasRole(SNAPSHOOTER_ROLE, newAdmin)).should.equal(true);
      (await this.cmtat.hasRole(DEFAULT_ADMIN_ROLE, newAdmin)).should.equal(true);
      // oldAdmin
      (await this.cmtat.hasRole(MINTER_ROLE, oldAdmin)).should.equal(false);
      (await this.cmtat.hasRole(BURNER_ROLE, oldAdmin)).should.equal(false);
      (await this.cmtat.hasRole(ENFORCER_ROLE, oldAdmin)).should.equal(false);
      (await this.cmtat.hasRole(SNAPSHOOTER_ROLE, oldAdmin)).should.equal(false);
      (await this.cmtat.hasRole(DEFAULT_ADMIN_ROLE, oldAdmin)).should.equal(false)
    })
    it('testCanTransferAdminshipWithoutBurnerRole', async function () {
      // Arrange
      await this.cmtat.renounceRole(BURNER_ROLE, oldAdmin);
      // Act
      (await this.cmtat.transferAdminship(newAdmin, { from: oldAdmin }));
      // Assert
      // newAdmin
      (await this.cmtat.hasRole(MINTER_ROLE, newAdmin)).should.equal(true);
      (await this.cmtat.hasRole(BURNER_ROLE, newAdmin)).should.equal(false);
      (await this.cmtat.hasRole(ENFORCER_ROLE, newAdmin)).should.equal(true);
      (await this.cmtat.hasRole(SNAPSHOOTER_ROLE, newAdmin)).should.equal(true);
      (await this.cmtat.hasRole(DEFAULT_ADMIN_ROLE, newAdmin)).should.equal(true);
      // oldAdmin
      (await this.cmtat.hasRole(MINTER_ROLE, oldAdmin)).should.equal(false);
      (await this.cmtat.hasRole(BURNER_ROLE, oldAdmin)).should.equal(false);
      (await this.cmtat.hasRole(ENFORCER_ROLE, oldAdmin)).should.equal(false);
      (await this.cmtat.hasRole(SNAPSHOOTER_ROLE, oldAdmin)).should.equal(false);
      (await this.cmtat.hasRole(DEFAULT_ADMIN_ROLE, oldAdmin)).should.equal(false)
    })
    it('testCanTransferAdminshipWithoutEnforcerRole', async function () {
      // Arrange
      await this.cmtat.renounceRole(ENFORCER_ROLE, oldAdmin);
      // Act
      (await this.cmtat.transferAdminship(newAdmin, { from: oldAdmin }));
      // Assert
      // newAdmin
      (await this.cmtat.hasRole(MINTER_ROLE, newAdmin)).should.equal(true);
      (await this.cmtat.hasRole(BURNER_ROLE, newAdmin)).should.equal(true);
      (await this.cmtat.hasRole(ENFORCER_ROLE, newAdmin)).should.equal(false);
      (await this.cmtat.hasRole(SNAPSHOOTER_ROLE, newAdmin)).should.equal(true);
      (await this.cmtat.hasRole(DEFAULT_ADMIN_ROLE, newAdmin)).should.equal(true);
      // oldAdmin
      (await this.cmtat.hasRole(MINTER_ROLE, oldAdmin)).should.equal(false);
      (await this.cmtat.hasRole(BURNER_ROLE, oldAdmin)).should.equal(false);
      (await this.cmtat.hasRole(ENFORCER_ROLE, oldAdmin)).should.equal(false);
      (await this.cmtat.hasRole(SNAPSHOOTER_ROLE, oldAdmin)).should.equal(false);
      (await this.cmtat.hasRole(DEFAULT_ADMIN_ROLE, oldAdmin)).should.equal(false)
    })
    it('testCanTransferAdminshipWithoutSnapshooterRole', async function () {
      // Arrange
      await this.cmtat.renounceRole(SNAPSHOOTER_ROLE, oldAdmin);
      // Act
      (await this.cmtat.transferAdminship(newAdmin, { from: oldAdmin }));
      // Assert
      // newAdmin
      (await this.cmtat.hasRole(MINTER_ROLE, newAdmin)).should.equal(true);
      (await this.cmtat.hasRole(BURNER_ROLE, newAdmin)).should.equal(true);
      (await this.cmtat.hasRole(ENFORCER_ROLE, newAdmin)).should.equal(true);
      (await this.cmtat.hasRole(SNAPSHOOTER_ROLE, newAdmin)).should.equal(false);
      (await this.cmtat.hasRole(DEFAULT_ADMIN_ROLE, newAdmin)).should.equal(true);
      // oldAdmin
      (await this.cmtat.hasRole(MINTER_ROLE, oldAdmin)).should.equal(false);
      (await this.cmtat.hasRole(BURNER_ROLE, oldAdmin)).should.equal(false);
      (await this.cmtat.hasRole(ENFORCER_ROLE, oldAdmin)).should.equal(false);
      (await this.cmtat.hasRole(SNAPSHOOTER_ROLE, oldAdmin)).should.equal(false);
      (await this.cmtat.hasRole(DEFAULT_ADMIN_ROLE, oldAdmin)).should.equal(false)
    })
    it('testCannotTransferAdminshipWithoutAdminRole', async function () {
      // Act + Assert
      await expectRevert(
        this.cmtat.transferAdminship(newAdmin, { from: attacker }),
        'AccessControl: account ' +
          attacker.toLowerCase() +
            ' is missing role ' +
            DEFAULT_ADMIN_ROLE
      );
      // Assert
      // newAdmin
      (await this.cmtat.hasRole(MINTER_ROLE, newAdmin)).should.equal(false);
      (await this.cmtat.hasRole(BURNER_ROLE, newAdmin)).should.equal(false);
      (await this.cmtat.hasRole(ENFORCER_ROLE, newAdmin)).should.equal(false);
      (await this.cmtat.hasRole(SNAPSHOOTER_ROLE, newAdmin)).should.equal(false);
      (await this.cmtat.hasRole(DEFAULT_ADMIN_ROLE, newAdmin)).should.equal(false);
      // oldAdmin
      (await this.cmtat.hasRole(MINTER_ROLE, oldAdmin)).should.equal(true);
      (await this.cmtat.hasRole(BURNER_ROLE, oldAdmin)).should.equal(true);
      (await this.cmtat.hasRole(ENFORCER_ROLE, oldAdmin)).should.equal(true);
      (await this.cmtat.hasRole(SNAPSHOOTER_ROLE, oldAdmin)).should.equal(true);
      (await this.cmtat.hasRole(DEFAULT_ADMIN_ROLE, oldAdmin)).should.equal(true)
    })
  })
}
module.exports = TransferAdminshipCommon
