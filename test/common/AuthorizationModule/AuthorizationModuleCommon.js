const { expect } = require('chai')
const {
  PAUSER_ROLE,
  DEFAULT_ADMIN_ROLE,
  ZERO_ADDRESS
} = require('../../utils')
function AuthorizationModuleCommon () {
  context('Authorization', function () {
    it('testAdminCanTransmitAdminship', async function () {
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .grantRole(DEFAULT_ADMIN_ROLE, this.address1)
      // Assert
      expect(await this.cmtat.hasRole(DEFAULT_ADMIN_ROLE, this.address1)).to.equal(
        true
      )
      // emits a RoleGranted event
      await expect(this.logs)
        .to.emit(this.cmtat, 'RoleGranted')
        .withArgs(DEFAULT_ADMIN_ROLE, this.address1, this.admin)

      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .renounceRole(DEFAULT_ADMIN_ROLE, this.admin)
      // Assert
      expect(await this.cmtat.hasRole(DEFAULT_ADMIN_ROLE, this.admin)).to.equal(
        false
      )

      // New admin can mint
      this.logs = await this.cmtat
        .connect(this.address1)
        .mint(this.address1, 100)
    })
    it('testAdminCanGrantRole', async function () {
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .grantRole(PAUSER_ROLE, this.address1)
      // Assert
      expect(await this.cmtat.hasRole(PAUSER_ROLE, this.address1)).to.equal(
        true
      )
      // emits a RoleGranted event
      await expect(this.logs)
        .to.emit(this.cmtat, 'RoleGranted')
        .withArgs(PAUSER_ROLE, this.address1, this.admin)
    })

    it('testAdminCanRevokeRole', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(PAUSER_ROLE, this.address1)
      // Arrange - Assert
      expect(await this.cmtat.hasRole(PAUSER_ROLE, this.address1)).to.equal(
        true
      )
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .revokeRole(PAUSER_ROLE, this.address1)
      // Assert
      expect(await this.cmtat.hasRole(PAUSER_ROLE, this.address1)).to.equal(
        false
      )
      // emits a RoleRevoked event
      await expect(this.logs)
        .to.emit(this.cmtat, 'RoleRevoked')
        .withArgs(PAUSER_ROLE, this.address1, this.admin)
    })

    /*
     * Already tested by OpenZeppelin library
     */
    it('testCannotNonAdminGrantRole', async function () {
      // Arrange - Assert
      expect(await this.cmtat.hasRole(PAUSER_ROLE, this.address1)).to.equal(
        false
      )
      // Act
      await expect(
        this.cmtat.connect(this.address2).grantRole(PAUSER_ROLE, this.address1)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, DEFAULT_ADMIN_ROLE)
      // Assert
      expect(await this.cmtat.hasRole(PAUSER_ROLE, this.address1)).to.equal(
        false
      )
    })

    /*
     * Already tested by OpenZeppelin library
     */
    it('testCannotNonAdminRevokeRole', async function () {
      // Arrange
      expect(await this.cmtat.hasRole(PAUSER_ROLE, this.address1)).to.equal(
        false
      )
      await this.cmtat
        .connect(this.admin)
        .grantRole(PAUSER_ROLE, this.address1)
      // Arrange - Assert
      expect(await this.cmtat.hasRole(PAUSER_ROLE, this.address1)).to.equal(
        true
      )
      // Act
      await expect(
        this.cmtat.connect(this.address2).revokeRole(PAUSER_ROLE, this.address1)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, DEFAULT_ADMIN_ROLE)
      // Assert
      expect(await this.cmtat.hasRole(PAUSER_ROLE, this.address1)).to.equal(
        true
      )
    })
  })
}
module.exports = AuthorizationModuleCommon
