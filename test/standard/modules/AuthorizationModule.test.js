const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { PAUSER_ROLE } = require('../../utils')
const chai = require('chai')
const expect = chai.expect
const should = chai.should()
const CMTAT = artifacts.require('CMTAT')

contract(
  'AuthorizationModule',
  function ([_, owner, address1, address2, address3, fakeRuleEngine]) {
    beforeEach(async function () {
      this.cmtat = await CMTAT.new(_, { from: owner })
      await this.cmtat.initialize(owner, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', { from: owner })
    })

    context('Authorization', function () {
      it('can grant role as the owner', async function () {
        ({ logs: this.logs } = await this.cmtat.grantRole(
          PAUSER_ROLE,
          address1,
          { from: owner }
        ));
        (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(true)
      })

      it('emits a RoleGranted event', function () {
        expectEvent.inLogs(this.logs, 'RoleGranted', {
          role: PAUSER_ROLE,
          account: address1,
          sender: owner
        })
      })

      it('can revoke role as the owner', async function () {
        await this.cmtat.grantRole(PAUSER_ROLE, address1, { from: owner });
        (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(true);
        ({ logs: this.logs } = await this.cmtat.revokeRole(
          PAUSER_ROLE,
          address1,
          { from: owner }
        ));
        (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(false)
      })

      it('emits a RoleRevoked event', function () {
        expectEvent.inLogs(this.logs, 'RoleRevoked', {
          role: PAUSER_ROLE,
          account: address1,
          sender: owner
        })
      })

      it('reverts when granting from non-owner', async function () {
        (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(false)
        await expectRevert(
          this.cmtat.grantRole(PAUSER_ROLE, address1, { from: address2 }),
          'AccessControl: account ' +
            address2.toLowerCase() +
            ' is missing role 0x0000000000000000000000000000000000000000000000000000000000000000'
        );
        (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(false)
      })

      it('reverts when revoking from non-owner', async function () {
        (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(false)
        await this.cmtat.grantRole(PAUSER_ROLE, address1, { from: owner });
        (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(true)
        await expectRevert(
          this.cmtat.revokeRole(PAUSER_ROLE, address1, { from: address2 }),
          'AccessControl: account ' +
            address2.toLowerCase() +
            ' is missing role 0x0000000000000000000000000000000000000000000000000000000000000000'
        );
        (await this.cmtat.hasRole(PAUSER_ROLE, address1)).should.equal(true)
      })
    })
  }
)
