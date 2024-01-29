const { expectEvent } = require('@openzeppelin/test-helpers')
const {
  expectRevertCustomError
} = require('../../../openzeppelin-contracts-upgradeable/test/helpers/customError.js')
const { DEFAULT_ADMIN_ROLE } = require('../../utils.js')
const { should } = require('chai').should()

function AuthorizationModuleSetAuthorizationEngineCommon (admin, address1, authorizationEngine) {
  context('AuthorizationEngineSetTest', function () {
    it('testCanBeSetByAdminIfNotAlreadySet', async function () {
      // Act
      this.logs = await this.cmtat.setAuthorizationEngine(this.authorizationEngineMock.address, {
        from: admin
      })
      // Assert
      // emits a RuleEngineSet event
      expectEvent(this.logs, 'AuthorizationEngine', {
        newAuthorizationEngine: this.authorizationEngineMock.address
      })
    })

    it('testCannotBeSetByAdminIfAlreadySet', async function () {
      // Arrange
      await this.cmtat.setAuthorizationEngine(this.authorizationEngineMock.address, {
        from: admin
      })
      // Act
      await expectRevertCustomError(
        this.cmtat.setAuthorizationEngine(this.authorizationEngineMock.address, {
          from: admin
        }),
        'CMTAT_AuthorizationModule_AuthorizationEngineAlreadySet',
        []
      )
    })

    it('testCannotNonAdminSetAuthorizationEngine', async function () {
      // Act
      await expectRevertCustomError(
        this.cmtat.setAuthorizationEngine(this.authorizationEngineMock.address, { from: address1 }),
        'AccessControlUnauthorizedAccount',
        [address1, DEFAULT_ADMIN_ROLE]
      )
    })

    // Mock
    it('testCanTransferAdminIfAuthorizedByTheEngine', async function () {
      // Arrange
      await this.authorizationEngineMock.authorizeAdminChange(address1)
      // Act
      await this.cmtat.setAuthorizationEngine(this.authorizationEngineMock.address, { from: admin })
      // Assert
      this.logs = await this.cmtat.grantRole(DEFAULT_ADMIN_ROLE, address1, {
        from: admin
      });
      // Assert
      (await this.cmtat.hasRole(DEFAULT_ADMIN_ROLE, address1)).should.equal(true)
    })

    // Mock
    it('testCannotTransferAdminIfNotAuthorizedByTheEngine', async function () {
      // Arrange
      await this.cmtat.setAuthorizationEngine(this.authorizationEngineMock.address, { from: admin })
      // Act
      await expectRevertCustomError(
        this.cmtat.grantRole(DEFAULT_ADMIN_ROLE, address1, {
          from: admin
        }),
        'CMTAT_AuthorizationModule_InvalidAuthorization',
        []
      )
    })

    it('testCanRevokeAdminIfAuthorizedByTheEngine', async function () {
      // Arrange
      await this.authorizationEngineMock.authorizeAdminChange(address1)
      // Act
      await this.cmtat.setAuthorizationEngine(this.authorizationEngineMock.address, { from: admin })
      // Assert
      this.logs = await this.cmtat.revokeRole(DEFAULT_ADMIN_ROLE, address1, {
        from: admin
      });
      // Assert
      (await this.cmtat.hasRole(DEFAULT_ADMIN_ROLE, address1)).should.equal(false)
    })

    // Mock
    it('testCannotRevokeAdminIfNotAuthorizedByTheEngine', async function () {
      // Arrange
      await this.cmtat.setAuthorizationEngine(this.authorizationEngineMock.address, { from: admin })
      await this.authorizationEngineMock.setRevokeAdminRoleAuthorized(false)
      // Act
      await expectRevertCustomError(
        this.cmtat.revokeRole(DEFAULT_ADMIN_ROLE, address1, {
          from: admin
        }),
        'CMTAT_AuthorizationModule_InvalidAuthorization',
        []
      )
    })
  })
}
module.exports = AuthorizationModuleSetAuthorizationEngineCommon
