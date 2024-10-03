const { expect } = require('chai')
const { DEFAULT_ADMIN_ROLE } = require('../../utils.js')

function AuthorizationModuleSetAuthorizationEngineCommon () {
  context('AuthorizationEngineSetTest', function () {
    it('testCanBeSetByAdminIfNotAlreadySet', async function () {
      if (!this.definedAtDeployment) {
        // Act
        this.logs = await this.cmtat
          .connect(this.admin)
          .setAuthorizationEngine(this.authorizationEngineMock.target)
        // Assert
        // emits a AuthorizationEngin event
        await expect(this.logs)
          .to.emit(this.cmtat, 'AuthorizationEngine')
          .withArgs(this.authorizationEngineMock)
      }
    })

    it('testCanReturnTheRightAddressIfSet', async function () {
      if (this.definedAtDeployment) {
        expect(this.authorizationEngineMock.target).to.equal(
          await this.cmtat.authorizationEngine()
        )
      }
    })

    it('testCannotBeSetByAdminIfAlreadySet', async function () {
      // Arrange
      if (!this.definedAtDeployment) {
        await this.cmtat
          .connect(this.admin)
          .setAuthorizationEngine(this.authorizationEngineMock.target)
      }
      // Act
      await expect(
        this.cmtat
          .connect(this.admin)
          .setAuthorizationEngine(this.authorizationEngineMock.target)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_AuthorizationModule_AuthorizationEngineAlreadySet'
      )
    })

    it('testCannotNonAdminSetAuthorizationEngine', async function () {
      // Act
      await expect(
        this.cmtat
          .connect(this.address1)
          .setAuthorizationEngine(this.authorizationEngineMock.target)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, DEFAULT_ADMIN_ROLE)
    })

    // Mock
    it('testCanTransferAdminIfAuthorizedByTheEngine', async function () {
      // Arrange
      await this.authorizationEngineMock.authorizeAdminChange(this.address1)

      // Arrange
      if (!this.definedAtDeployment) {
        await this.cmtat
          .connect(this.admin)
          .setAuthorizationEngine(this.authorizationEngineMock.target)
      }
      // Act + Assert
      this.logs = await this.cmtat
        .connect(this.admin)
        .grantRole(DEFAULT_ADMIN_ROLE, this.address1)
      // Assert
      expect(
        await this.cmtat.hasRole(DEFAULT_ADMIN_ROLE, this.address1)
      ).to.equal(true)
    })

    // Mock
    it('testCannotTransferAdminIfNotAuthorizedByTheEngine', async function () {
      // Arrange
      if (!this.definedAtDeployment) {
        await this.cmtat
          .connect(this.admin)
          .setAuthorizationEngine(this.authorizationEngineMock.target)
      }
      // Act
      await expect(
        this.cmtat
          .connect(this.admin)
          .grantRole(DEFAULT_ADMIN_ROLE, this.address1)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_AuthorizationModule_InvalidAuthorization'
      )
    })

    it('testCanRevokeAdminIfAuthorizedByTheEngine', async function () {
      // Arrange
      await this.authorizationEngineMock.authorizeAdminChange(this.address1)
      // Arrange
      if (!this.definedAtDeployment) {
        await this.cmtat
          .connect(this.admin)
          .setAuthorizationEngine(this.authorizationEngineMock.target)
      }
      // Assert
      this.logs = await this.cmtat
        .connect(this.admin)
        .revokeRole(DEFAULT_ADMIN_ROLE, this.address1)
      // Assert
      expect(
        await this.cmtat.hasRole(DEFAULT_ADMIN_ROLE, this.address1)
      ).to.equal(false)
    })

    // Mock
    it('testCannotRevokeAdminIfNotAuthorizedByTheEngine', async function () {
      // Arrange
      if (!this.definedAtDeployment) {
        await this.cmtat
          .connect(this.admin)
          .setAuthorizationEngine(this.authorizationEngineMock.target)
      }

      await this.authorizationEngineMock.setRevokeAdminRoleAuthorized(false)
      // Act
      await expect(
        this.cmtat
          .connect(this.admin)
          .revokeRole(DEFAULT_ADMIN_ROLE, this.address1)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_AuthorizationModule_InvalidAuthorization'
      )
    })
  })
}
module.exports = AuthorizationModuleSetAuthorizationEngineCommon
