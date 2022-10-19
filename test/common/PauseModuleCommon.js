const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { PAUSER_ROLE } = require('../utils')
const { should } = require('chai').should()

const CMTAT = artifacts.require('CMTAT')

function PauseModuleCommon (owner, address1, address2, address3) {
  context('Pause', function () {
    it('can be paused by the owner', async function () {
      ({ logs: this.logs } = await this.cmtat.pause({ from: owner }))
    })

    it('emits a Paused event', function () {
      expectEvent.inLogs(this.logs, 'Paused', { account: owner })
    })

    it('can be paused by the anyone having pauser role', async function () {
      await this.cmtat.grantRole(PAUSER_ROLE, address1, { from: owner })
      await this.cmtat.pause({ from: address1 })
    })

    it('reverts when calling from non-owner', async function () {
      await expectRevert(
        this.cmtat.pause({ from: address1 }),
        'AccessControl: account ' +
          address1.toLowerCase() +
          ' is missing role ' +
          PAUSER_ROLE
      )
    })

    it('can be unpaused by the owner', async function () {
      await this.cmtat.pause({ from: owner });
      ({ logs: this.logs } = await this.cmtat.unpause({ from: owner }))
    })

    it('emits a Unpaused event', function () {
      expectEvent.inLogs(this.logs, 'Unpaused', { account: owner })
    })

    it('can be paused by the anyone having pauser role', async function () {
      await this.cmtat.pause({ from: owner })
      await this.cmtat.grantRole(PAUSER_ROLE, address1, { from: owner })
      await this.cmtat.unpause({ from: address1 })
    })

    it('reverts when calling from non-owner', async function () {
      await this.cmtat.pause({ from: owner })
      await expectRevert(
        this.cmtat.unpause({ from: address1 }),
        'AccessControl: account ' +
          address1.toLowerCase() +
          ' is missing role ' +
          PAUSER_ROLE
      )
    })

    it('reverts if address1 transfers tokens to address2 when paused', async function () {
      await this.cmtat.pause({ from: owner });
      (
        await this.cmtat.detectTransferRestriction(address1, address2, 10)
      ).should.be.bignumber.equal('1');
      (await this.cmtat.messageForTransferRestriction(1)).should.equal(
        'All transfers paused'
      )
      await expectRevert(
        this.cmtat.transfer(address2, 10, { from: address1 }),
        'CMTAT: token transfer while paused'
      )
    })

    it('reverts if address3 transfers tokens from address1 to address2 when paused', async function () {
      // Define allowance
      await this.cmtat.approve(address3, 20, { from: address1 })

      await this.cmtat.pause({ from: owner });
      (
        await this.cmtat.detectTransferRestriction(address1, address2, 10)
      ).should.be.bignumber.equal('1');
      (await this.cmtat.messageForTransferRestriction(1)).should.equal(
        'All transfers paused'
      )
      await expectRevert(
        this.cmtat.transferFrom(address1, address2, 10, { from: address3 }),
        'CMTAT: token transfer while paused'
      )
    })
  })
}
module.exports = PauseModuleCommon
