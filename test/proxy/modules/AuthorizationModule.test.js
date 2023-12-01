const { ethers, upgrades } = require('hardhat')
const { DEFAULT_ADMIN_ROLE } = require('../../utils')
const { PAUSER_ROLE } = require('../../utils')

describe('Proxy - AuthorizationModule', function () {
  let owner, address1, address2, cmtat

  beforeEach(async function () {
    [owner, address1, address2] = await ethers.getSigners()

    const flag = 5
    const CMTAT_BASE = await ethers.getContractFactory('CMTAT_BASE')
    cmtat = await upgrades.deployProxy(CMTAT_BASE, [owner.address, 'CMTA Token', 'CMTAT', 18, 'CMTAT_ISIN', 'https://cmta.ch', 'CMTAT_info', flag], { initializer: 'initialize' })
  })

  context('Authorization', function () {
    it('testAdminCanGrantRole', async function () {
      await hasRole(DEFAULT_ADMIN_ROLE, owner.address, true)
      await hasRole(PAUSER_ROLE, address1.address, false)
      await grantRole(owner, PAUSER_ROLE, address1.address)
      await hasRole(PAUSER_ROLE, address1.address, true)
    })

    it('testAdminCanRevokeRole', async function () {
      await grantRole(owner, PAUSER_ROLE, address1.address)
      await hasRole(PAUSER_ROLE, address1.address, true)
      await revokeRole(owner, PAUSER_ROLE, address1.address)
      await hasRole(PAUSER_ROLE, address1.address, false)
    })

    it('testOnlyRoleCanRenounceRole', async function () {
      await grantRole(owner, PAUSER_ROLE, address1.address)
      await hasRole(PAUSER_ROLE, address1.address, true)
      await renounceRole(address1, PAUSER_ROLE, address1.address)
      await hasRole(PAUSER_ROLE, address1.address, false)
    })

    it('testCannotNonAdminGrantRole', async function () {
      await hasRole(PAUSER_ROLE, address1.address, false)
      await expect(
        cmtat.connect(address2).grantRole(PAUSER_ROLE, address1.address)
      ).to.be.revertedWith('AccessControl: account ' + address2.address.toLowerCase() + ' is missing role ' + DEFAULT_ADMIN_ROLE)
      await hasRole(PAUSER_ROLE, address1.address, false)
    })

    it('testCannotNonAdminRevokeRole', async function () {
      await hasRole(PAUSER_ROLE, address1.address, false)
      await grantRole(owner, PAUSER_ROLE, address1.address)
      await hasRole(PAUSER_ROLE, address1.address, true)
      await expect(
        cmtat.connect(address2).revokeRole(PAUSER_ROLE, address1.address)
      ).to.be.revertedWith('AccessControl: account ' + address2.address.toLowerCase() + ' is missing role ' + DEFAULT_ADMIN_ROLE)
      await hasRole(PAUSER_ROLE, address1.address, true)
    })

    it('testCannotRenounceToNotYourRole', async function () {
      await hasRole(PAUSER_ROLE, address1.address, false)
      await grantRole(owner, PAUSER_ROLE, address1.address)
      await hasRole(PAUSER_ROLE, address1.address, true)
      await expect(
        cmtat.connect(address2).renounceRole(PAUSER_ROLE, address1.address)
      ).to.be.revertedWith('AccessControl: can only renounce roles for self')
      await hasRole(PAUSER_ROLE, address1.address, true)
    })

    // Helper functions

    async function hasRole (role, account, expected) {
      await expect(await cmtat.hasRole(role, account)).to.equal(expected)
    }

    async function grantRole (caller, role, account) {
      await expect(await cmtat.connect(caller).grantRole(role, account)).to.emit(cmtat, 'RoleGranted').withArgs(role, account, caller.address)
    }

    async function renounceRole (caller, role, account) {
      await expect(await cmtat.connect(caller).renounceRole(role, account)).to.emit(cmtat, 'RoleRevoked').withArgs(role, account, caller.address)
    }
    async function revokeRole (caller, role, account) {
      await expect(await cmtat.connect(caller).revokeRole(role, account)).to.emit(cmtat, 'RoleRevoked').withArgs(role, account, caller.address)
    }
  })
})
