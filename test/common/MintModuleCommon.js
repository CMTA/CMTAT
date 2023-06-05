const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { ZERO_ADDRESS, MINTER_ROLE } = require('../utils')

function MintModuleCommon (admin, address1, address2) {
  context('Minting', function () {
    /**
    The admin is assigned the MINTER role when the contract is deployed
     */
    it('testCanBeMintedByAdmin', async function () {
      // Arrange - Assert
      // Check first balance
      (await this.cmtat.balanceOf(admin)).should.be.bignumber.equal('0');

      // Act
      // Issue 20 and check balances and total supply
      ({ logs: this.logs1 } = await this.cmtat.mint(address1, 20, {
        from: admin
      }));

      // Assert
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal('20');
      (await this.cmtat.totalSupply()).should.be.bignumber.equal('20');

      // Act
      // Issue 50 and check intermediate balances and total supply
      ({ logs: this.logs2 } = await this.cmtat.mint(address2, 50, {
        from: admin
      }));

      // Assert
      (await this.cmtat.balanceOf(address2)).should.be.bignumber.equal('50');
      (await this.cmtat.totalSupply()).should.be.bignumber.equal('70')

      // Assert event
      // emits a Transfer event
      expectEvent.inLogs(this.logs2, 'Transfer', {
        from: ZERO_ADDRESS,
        to: address2,
        value: '50'
      })
      // emits a Mint event
      expectEvent.inLogs(this.logs2, 'Mint', {
        beneficiary: address2,
        amount: '50'
      })
    })

    it('testCanBeMintedByANewMinter', async function () {
      // Arrange
      await this.cmtat.grantRole(MINTER_ROLE, address1, { from: admin });
      // Arrange - Assert
      // Check first balance
      (await this.cmtat.balanceOf(admin)).should.be.bignumber.equal('0');

      // Act
      // Issue 20
      ({ logs: this.logs1 } = await this.cmtat.mint(address1, 20, {
        from: address1
      }));
      // Assert
      // Check balances and total supply
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal('20');
      (await this.cmtat.totalSupply()).should.be.bignumber.equal('20')

      // Assert event
      // emits a Transfer event
      expectEvent.inLogs(this.logs1, 'Transfer', {
        from: ZERO_ADDRESS,
        to: address1,
        value: '20'
      })
      // emits a Mint event
      expectEvent.inLogs(this.logs1, 'Mint', {
        beneficiary: address1,
        amount: '20'
      })
    })

    // reverts when issuing by a non minter
    it('testCannotIssuingByNonMinter', async function () {
      await expectRevert(
        this.cmtat.mint(address1, 20, { from: address1 }),
        'AccessControl: account ' +
            address1.toLowerCase() +
            ' is missing role ' +
            MINTER_ROLE
      )
    })
  })
}
module.exports = MintModuleCommon
