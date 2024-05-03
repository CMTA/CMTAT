const { expectEvent } = require('@openzeppelin/test-helpers')
const { should } = require('chai').should()
const { ENFORCER_ROLE } = require('../utils')
const {
  expectRevertCustomError
} = require('../../openzeppelin-contracts-upgradeable/test/helpers/customError.js')
const reasonFreeze = 'testFreeze'
const reasonUnfreeze = 'testUnfreeze'

function EnforcementModuleCommon (owner, address1, address2, address3) {
  context('Freeze', function () {
    beforeEach(async function () {
      await this.cmtat.mint(address1, 50, { from: owner })
    })

    it('testAdminCanFreezeAddress', async function () {
      // Arrange - Assert
      (await this.cmtat.frozen(address1)).should.equal(false)
      // Act
      this.logs = await this.cmtat.freeze(address1, reasonFreeze, {
        from: owner
      });
      // Assert
      (await this.cmtat.frozen(address1)).should.equal(true)
      // emits a Freeze event
      expectEvent(this.logs, 'Freeze', {
        enforcer: owner,
        owner: address1,
        reasonIndexed: web3.utils.keccak256(reasonFreeze),
        reason: reasonFreeze
      })
    })

    it('testReasonParameterCanBeEmptyString', async function () {
      // Arrange - Assert
      (await this.cmtat.frozen(address1)).should.equal(false)
      // Act
      this.logs = await this.cmtat.freeze(address1, '', {
        from: owner
      });
      // Assert
      (await this.cmtat.frozen(address1)).should.equal(true)
      // emits a Freeze event
      expectEvent(this.logs, 'Freeze', {
        enforcer: owner,
        owner: address1,
        // see https://ethereum.stackexchange.com/questions/35103/keccak-hash-of-null-values-result-in-different-hashes-for-different-types
        reasonIndexed:
          '0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470',
        reason: ''
      })
    })

    it('testEnforcerRoleCanFreezeAddress', async function () {
      // Arrange
      await this.cmtat.grantRole(ENFORCER_ROLE, address2, { from: owner });
      // Arrange - Assert
      (await this.cmtat.frozen(address1)).should.equal(false)
      // Act
      this.logs = await this.cmtat.freeze(address1, reasonFreeze, {
        from: address2
      });
      // Act + Assert
      // Act + Assert
      (
        await this.cmtat.validateTransfer(address1, address2, 10)
      ).should.be.equal(false);
      // Assert
      (await this.cmtat.frozen(address1)).should.equal(true)

      // emits a Freeze event
      expectEvent(this.logs, 'Freeze', {
        enforcer: address2,
        owner: address1,
        reasonIndexed: web3.utils.keccak256(reasonFreeze),
        reason: reasonFreeze
      })
    })

    it('testAdminCanUnfreezeAddress', async function () {
      // Arrange
      await this.cmtat.freeze(address1, reasonFreeze, { from: owner });
      // Arrange - Assert
      (await this.cmtat.frozen(address1)).should.equal(true)
      // Act
      this.logs = await this.cmtat.unfreeze(address1, reasonUnfreeze, {
        from: owner
      });
      // Assert
      (await this.cmtat.frozen(address1)).should.equal(false)
      expectEvent(this.logs, 'Unfreeze', {
        enforcer: owner,
        owner: address1,
        reasonIndexed: web3.utils.keccak256(reasonUnfreeze),
        reason: reasonUnfreeze
      })
    })

    it('testEnforcerRoleCanUnfreezeAddress', async function () {
      // Arrange
      await this.cmtat.freeze(address1, reasonFreeze, { from: owner })
      await this.cmtat.grantRole(ENFORCER_ROLE, address2, { from: owner });
      // Arrange - Assert
      (await this.cmtat.frozen(address1)).should.equal(true)
      // Act
      this.logs = await this.cmtat.unfreeze(address1, reasonUnfreeze, {
        from: address2
      });
      // Assert
      (await this.cmtat.frozen(address1)).should.equal(false)
      // emits an Unfreeze event
      expectEvent(this.logs, 'Unfreeze', {
        enforcer: address2,
        owner: address1,
        reasonIndexed: web3.utils.keccak256(reasonUnfreeze),
        reason: reasonUnfreeze
      })
    })

    it('testCannotNonEnforcerFreezeAddress', async function () {
      // Act
      await expectRevertCustomError(
        this.cmtat.freeze(address1, reasonFreeze, { from: address2 }),
        'AccessControlUnauthorizedAccount',
        [address2, ENFORCER_ROLE]
      );
      // Assert
      (await this.cmtat.frozen(address1)).should.equal(false)
    })

    it('testCannotNonEnforcerUnfreezeAddress', async function () {
      // Arrange
      await this.cmtat.freeze(address1, reasonFreeze, { from: owner })
      // Act
      await expectRevertCustomError(
        this.cmtat.unfreeze(address1, reasonUnfreeze, { from: address2 }),
        'AccessControlUnauthorizedAccount',
        [address2, ENFORCER_ROLE]
      );
      // Assert
      (await this.cmtat.frozen(address1)).should.equal(true)
    })

    // reverts if address1 transfers tokens to address2 when paused
    it('testCannotTransferWhenFromIsFrozenWithTransfer', async function () {
      // Act
      await this.cmtat.freeze(address1, reasonFreeze, { from: owner });
      // Assert
      (
        await this.cmtat.detectTransferRestriction(address1, address2, 10)
      ).should.be.bignumber.equal('2');
      (await this.cmtat.messageForTransferRestriction(2)).should.equal(
        'Address FROM is frozen'
      )
      const AMOUNT_TO_TRANSFER = 10
      await expectRevertCustomError(
        this.cmtat.transfer(address2, AMOUNT_TO_TRANSFER, { from: address1 }),
        'CMTAT_InvalidTransfer',
        [address1, address2, AMOUNT_TO_TRANSFER]
      )
    })

    // reverts if address3 transfers tokens from address1 to address2 when paused
    it('testCannotTransferTokenWhenToIsFrozenWithTransferFrom', async function () {
      // Arrange
      // Define allowance
      await this.cmtat.approve(address1, 20, { from: address3 })
      // Act
      await this.cmtat.freeze(address2, reasonFreeze, { from: owner });

      // Assert
      (
        await this.cmtat.detectTransferRestriction(address1, address2, 10)
      ).should.be.bignumber.equal('3');
      (await this.cmtat.messageForTransferRestriction(3)).should.equal(
        'Address TO is frozen'
      )
      const AMOUNT_TO_TRANSFER = 10
      await expectRevertCustomError(
        this.cmtat.transferFrom(address3, address2, AMOUNT_TO_TRANSFER, {
          from: address1
        }),
        'CMTAT_InvalidTransfer',
        [address3, address2, AMOUNT_TO_TRANSFER]
      )
    })

    // Improvement: check the return value but it is not possible to get the return value of a state modifying function
    it('testFreezeDoesNotEmitEventIfAddressAlreadyFrozen', async function () {
      // Arrange - Assert
      (await this.cmtat.frozen(address1)).should.equal(false)
      // Arrange
      await this.cmtat.freeze(address1, reasonFreeze, {
        from: owner
      });
      // Arrange - Assert
      (await this.cmtat.frozen(address1)).should.equal(true)
      // Act
      this.logs = await this.cmtat.freeze(address1, reasonFreeze, {
        from: owner
      })
      // Assert
      expectEvent.notEmitted(this.logs, 'Freeze');
      (await this.cmtat.frozen(address1)).should.equal(true)
    })

    // Improvement: check the return value but it is not possible to get the return value of a state modifying function
    it('testUnfreezeDoesNotEmitEventIfAddressAlreadyUnfrozen', async function () {
      // Arrange
      await this.cmtat.freeze(address1, reasonFreeze, { from: owner });
      // Arrange - Assert
      (await this.cmtat.frozen(address1)).should.equal(true)
      await this.cmtat.unfreeze(address1, reasonFreeze, { from: owner })

      // Act
      this.logs = await this.cmtat.unfreeze(address1, reasonUnfreeze, {
        from: owner
      })
      // Assert
      expectEvent.notEmitted(this.logs, 'Unfreeze');
      (await this.cmtat.frozen(address1)).should.equal(false)
    })
  })
}
module.exports = EnforcementModuleCommon
