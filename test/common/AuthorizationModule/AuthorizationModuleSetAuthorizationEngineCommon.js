const { expect } = require('chai');
const {
  expectRevertCustomError
} = require('../../../openzeppelin-contracts-upgradeable/test/helpers/customError.js')
const { DEFAULT_ADMIN_ROLE } = require('../../utils.js')

function AuthorizationModuleSetAuthorizationEngineCommon () {
  context('AuthorizationEngineSetTest', function () {
    it('testCanBeSetByAdminIfNotAlreadySet', async function () {
      // Act
      this.logs = await this.cmtat.connect(this.admin).setAuthorizationEngine(
        this.authorizationEngineMock
      )
      // Assert
      // emits a AuthorizationEngin event
      await expect(this.logs).to.emit(this.cmtat, 'AuthorizationEngine').withArgs(
        this.authorizationEngineMock);
    })

    it('testCannotBeSetByAdminIfAlreadySet', async function () {
      // Arrange
      await this.cmtat.connect(this.admin).setAuthorizationEngine(
        this.authorizationEngineMock
      )
      // Act
      await expectRevertCustomError(
        this.cmtat.connect(this.admin).setAuthorizationEngine(
          this.authorizationEngineMock
        ),
        'CMTAT_AuthorizationModule_AuthorizationEngineAlreadySet',
        []
      )
    })

    it('testCannotNonAdminSetAuthorizationEngine', async function () {
      // Act
      await expectRevertCustomError(
        this.cmtat.connect(this.address1).setAuthorizationEngine(
          this.authorizationEngineMock
        ),
        'AccessControlUnauthorizedAccount',
        [this.address1.address, DEFAULT_ADMIN_ROLE]
      )
    })

    // Mock
    it('testCanTransferAdminIfAuthorizedByTheEngine', async function () {
      // Arrange
      await this.authorizationEngineMock.authorizeAdminChange(this.address1)
      // Act
      await this.cmtat.connect(this.admin).setAuthorizationEngine(
        this.authorizationEngineMock.address
      )
      // Assert
      this.logs = await this.cmtat.connect(this.admin).grantRole(DEFAULT_ADMIN_ROLE, this.address1);
      // Assert
      (await this.cmtat.hasRole(DEFAULT_ADMIN_ROLE, this.address1)).to.equal(
        true
      )
    })

    // Mock
    it('testCannotTransferAdminIfNotAuthorizedByTheEngine', async function () {
      // Arrange
      await this.cmtat.connect(this.admin).setAuthorizationEngine(
        this.authorizationEngineMock
      )
      // Act
      await expectRevertCustomError(
        this.cmtat.connect(this.admin).grantRole(DEFAULT_ADMIN_ROLE, this.address1),
        'CMTAT_AuthorizationModule_InvalidAuthorization',
        []
      )
    })

    it('testCanRevokeAdminIfAuthorizedByTheEngine', async function () {
      // Arrange
      await this.authorizationEngineMock.authorizeAdminChange(this.address1)
      // Act
      await this.cmtat.connect(this.admin).setAuthorizationEngine(
        this.authorizationEngineMock
      )
      // Assert
      this.logs = await this.cmtat.connect(this.admin).revokeRole(DEFAULT_ADMIN_ROLE, this.address1);
      // Assert
      expect(await this.cmtat.hasRole(DEFAULT_ADMIN_ROLE, this.address1)).to.equal(
        false
      )
    })

    // Mock
    it('testCannotRevokeAdminIfNotAuthorizedByTheEngine', async function () {
      // Arrange
      await this.cmtat.connect(this.admin).setAuthorizationEngine(
        this.authorizationEngineMock
      )
      await this.authorizationEngineMock.setRevokeAdminRoleAuthorized(false)
      // Act
      await expectRevertCustomError(
        this.cmtat.connect(this.admin).revokeRole(DEFAULT_ADMIN_ROLE, this.address1),
        'CMTAT_AuthorizationModule_InvalidAuthorization',
        []
      )
    })
  })
}
module.exports = AuthorizationModuleSetAuthorizationEngineCommon
