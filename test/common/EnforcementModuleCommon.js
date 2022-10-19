const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { should } = require('chai').should()
const { ENFORCER_ROLE } = require('../utils')

const CMTAT = artifacts.require('CMTAT')

function EnforcementModuleCommon (owner, address1, address2) {
  context('Freeze', function () {
    beforeEach(async function () {
      await this.cmtat.mint(address1, 50, { from: owner })
    })

    it('can freeze an account as the owner', async function () {
      (await this.cmtat.frozen(address1)).should.equal(false);
      ({ logs: this.logs } = await this.cmtat.freeze(address1, {
        from: owner
      }));
      (await this.cmtat.frozen(address1)).should.equal(true)
    })

    it('emits a Freeze event', function () {
      expectEvent.inLogs(this.logs, 'Freeze', {
        enforcer: owner,
        owner: address1
      })
    })

    it('can freeze an account as anyone with the enforcer role', async function () {
      await this.cmtat.grantRole(ENFORCER_ROLE, address2, { from: owner });
      (await this.cmtat.frozen(address1)).should.equal(false)
      await this.cmtat.freeze(address1, { from: address2 });
      (await this.cmtat.frozen(address1)).should.equal(true)
    })

    it('can unfreeze an account as the owner', async function () {
      await this.cmtat.freeze(address1, { from: owner });
      (await this.cmtat.frozen(address1)).should.equal(true);
      ({ logs: this.logs } = await this.cmtat.unfreeze(address1, {
        from: owner
      }));
      (await this.cmtat.frozen(address1)).should.equal(false)
    })

    it('can unfreeze an account as anyone with the enforcer role', async function () {
      await this.cmtat.freeze(address1, { from: owner });
      (await this.cmtat.frozen(address1)).should.equal(true)
      await this.cmtat.grantRole(ENFORCER_ROLE, address2, { from: owner })
      await this.cmtat.unfreeze(address1, { from: address2 });
      (await this.cmtat.frozen(address1)).should.equal(false)
    })

    it('emits an Unfreeze event', function () {
      expectEvent.inLogs(this.logs, 'Unfreeze', {
        enforcer: owner,
        owner: address1
      })
    })

    it('reverts when freezing from non-enforcer', async function () {
      await expectRevert(
        this.cmtat.freeze(address1, { from: address2 }),
        'AccessControl: account ' +
            address2.toLowerCase() +
            ' is missing role ' +
            ENFORCER_ROLE
      )
    })

    it('reverts when unfreezing from non-enforcer', async function () {
      await expectRevert(
        this.cmtat.unfreeze(address1, { from: address2 }),
        'AccessControl: account ' +
            address2.toLowerCase() +
            ' is missing role ' +
            ENFORCER_ROLE
      )
    })
  })
}
module.exports = EnforcementModuleCommon
