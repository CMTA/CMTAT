const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { ZERO_ADDRESS, MINTER_ROLE } = require('../utils')
const { should } = require('chai').should()

function MintModuleCommon (admin, address1, address2) {
  context('Minting', function () {
    const VALUE1 = new BN(20)
    const VALUE2 = new BN(50)
    /**
    The admin is assigned the MINTER role when the contract is deployed
     */
    it('testCanBeMintedByAdmin', async function () {
      // Arrange

      // Arrange - Assert
      // Check first balance
      (await this.cmtat.balanceOf(admin)).should.be.bignumber.equal(BN(0));

      // Act
      // Issue 20 and check balances and total supply
      ({ logs: this.logs1 } = await this.cmtat.mint(address1, VALUE1, {
        from: admin
      }));

      // Assert
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal(VALUE1);
      (await this.cmtat.totalSupply()).should.be.bignumber.equal(VALUE1)

      // Assert event
      // emits a Transfer event
      expectEvent.inLogs(this.logs1, 'Transfer', {
        from: ZERO_ADDRESS,
        to: address1,
        value: VALUE1
      })
      // emits a Mint event
      expectEvent.inLogs(this.logs1, 'Mint', {
        beneficiary: address1,
        amount: VALUE1
      });

      // Act
      // Issue 50 and check intermediate balances and total supply
      ({ logs: this.logs2 } = await this.cmtat.mint(address2, VALUE2, {
        from: admin
      }));

      // Assert
      (await this.cmtat.balanceOf(address2)).should.be.bignumber.equal(VALUE2);
      (await this.cmtat.totalSupply()).should.be.bignumber.equal(VALUE1.add(VALUE2))

      // Assert event
      // emits a Transfer event
      expectEvent.inLogs(this.logs2, 'Transfer', {
        from: ZERO_ADDRESS,
        to: address2,
        value: VALUE2
      })
      // emits a Mint event
      expectEvent.inLogs(this.logs2, 'Mint', {
        beneficiary: address2,
        amount: VALUE2
      })
    })

    it('testCanBeMintedByANewMinter', async function () {
      // Arrange
      await this.cmtat.grantRole(MINTER_ROLE, address1, { from: admin });
      // Arrange - Assert
      // Check first balance
      (await this.cmtat.balanceOf(admin)).should.be.bignumber.equal(BN(0));

      // Act
      // Issue 20
      ({ logs: this.logs1 } = await this.cmtat.mint(address1, VALUE1, {
        from: address1
      }));
      // Assert
      // Check balances and total supply
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal(VALUE1);
      (await this.cmtat.totalSupply()).should.be.bignumber.equal(VALUE1)

      // Assert event
      // emits a Transfer event
      expectEvent.inLogs(this.logs1, 'Transfer', {
        from: ZERO_ADDRESS,
        to: address1,
        value: VALUE1
      })
      // emits a Mint event
      expectEvent.inLogs(this.logs1, 'Mint', {
        beneficiary: address1,
        amount: VALUE1
      })
    })

    // reverts when issuing by a non minter
    it('testCannotIssuingByNonMinter', async function () {
      await expectRevert(
        this.cmtat.mint(address1, VALUE1, { from: address1 }),
        'AccessControl: account ' +
            address1.toLowerCase() +
            ' is missing role ' +
            MINTER_ROLE
      )
    })
  })

  context('Batch Minting', function () {
    const TOKEN_HOLDER = [admin, address1, address2]
    const TOKEN_SUPPLY_BY_HOLDERS = [BN(10), BN(100), BN(1000)]

    /**
    The admin is assigned the MINTER role when the contract is deployed
     */
    it('testCanBeMintedByAdmin', async function () {
      // Arrange - Assert
      // Check first balance
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        (await this.cmtat.balanceOf(TOKEN_HOLDER[i])).should.be.bignumber.equal(BN(0))
      }

      // Act
      // Issue 20 and check balances and total supply
      ({ logs: this.logs1 } = await this.cmtat.mintBatch(TOKEN_HOLDER, TOKEN_SUPPLY_BY_HOLDERS, {
        from: admin
      }))

      // Assert
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        (await this.cmtat.balanceOf(TOKEN_HOLDER[i])).should.be.bignumber.equal(TOKEN_SUPPLY_BY_HOLDERS[i])
      }

      (await this.cmtat.totalSupply()).should.be.bignumber.equal(TOKEN_SUPPLY_BY_HOLDERS.reduce((a, b) => { return a.add(b) }))

      // Assert event
      // emits a Transfer event
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        // emits a Mint event
        expectEvent.inLogs(this.logs1, 'Transfer', {
          from: ZERO_ADDRESS,
          to: TOKEN_HOLDER[i],
          value: TOKEN_SUPPLY_BY_HOLDERS[i]
        })
      }

      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        // emits a Mint event
        expectEvent.inLogs(this.logs1, 'Mint', {
          beneficiary: TOKEN_HOLDER[i],
          amount: TOKEN_SUPPLY_BY_HOLDERS[i]
        })
      }
    })

    it('testCanBeMintedByANewMinter', async function () {
      // Arrange
      await this.cmtat.grantRole(MINTER_ROLE, address1, { from: admin })
      const TOKEN_HOLDER = [admin, address1, address2]
      const TOKEN_SUPPLY_BY_HOLDERS = [BN(10), BN(100), BN(1000)]

      // Arrange - Assert
      // Check first balance
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        (await this.cmtat.balanceOf(TOKEN_HOLDER[i])).should.be.bignumber.equal(BN(0))
      }

      // Act
      // Issue 20 and check balances and total supply
      ({ logs: this.logs1 } = await this.cmtat.mintBatch(TOKEN_HOLDER, TOKEN_SUPPLY_BY_HOLDERS, {
        from: address1
      }))

      // Assert
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        (await this.cmtat.balanceOf(TOKEN_HOLDER[i])).should.be.bignumber.equal(TOKEN_SUPPLY_BY_HOLDERS[i])
      }

      (await this.cmtat.totalSupply()).should.be.bignumber.equal(TOKEN_SUPPLY_BY_HOLDERS.reduce((a, b) => { return a.add(b) }))

      // Assert event
      // emits a Transfer event
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        // emits a Mint event
        expectEvent.inLogs(this.logs1, 'Transfer', {
          from: ZERO_ADDRESS,
          to: TOKEN_HOLDER[i],
          value: TOKEN_SUPPLY_BY_HOLDERS[i]
        })
      }

      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        // emits a Mint event
        expectEvent.inLogs(this.logs1, 'Mint', {
          beneficiary: TOKEN_HOLDER[i],
          amount: TOKEN_SUPPLY_BY_HOLDERS[i]
        })
      }
    })

    // reverts when issuing by a non minter
    it('testCannotIssuingByNonMinter', async function () {
      const TOKEN_HOLDER = [admin, address1, address2]
      const TOKEN_SUPPLY_BY_HOLDERS = [BN(10), BN(100), BN(1000)]
      await expectRevert(
        this.cmtat.mintBatch(TOKEN_HOLDER, TOKEN_SUPPLY_BY_HOLDERS, { from: address1 }),
        'AccessControl: account ' +
            address1.toLowerCase() +
            ' is missing role ' +
            MINTER_ROLE
      )
    })
  })
}
module.exports = MintModuleCommon
