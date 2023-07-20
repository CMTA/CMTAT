const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { ZERO_ADDRESS, MINTER_ROLE } = require('../utils')
const { should } = require('chai').should()

function MintModuleCommon (admin, address1, address2) {
  context('Minting', function () {
    /**
    The admin is assigned the MINTER role when the contract is deployed
     */
    it('testCanBeMintedByAdmin', async function () {
      // Arrange
      const value1 = new BN(20);
      const value2 = new BN(50);
      // Arrange - Assert
      // Check first balance
      (await this.cmtat.balanceOf(admin)).should.be.bignumber.equal(BN(0));

      // Act
      // Issue 20 and check balances and total supply
      ({ logs: this.logs1 } = await this.cmtat.mint(address1, value1, {
        from: admin
      }));

      // Assert
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal(value1);
      (await this.cmtat.totalSupply()).should.be.bignumber.equal(value1);

      // Assert event
      // emits a Transfer event
      expectEvent.inLogs(this.logs1, 'Transfer', {
        from: ZERO_ADDRESS,
        to: address1,
        value: value1
      })
      // emits a Mint event
      expectEvent.inLogs(this.logs1, 'Mint', {
        beneficiary: address1,
        amount: value1
      });

      // Act
      // Issue 50 and check intermediate balances and total supply
      ({ logs: this.logs2 } = await this.cmtat.mint(address2, value2, {
        from: admin
      }));

      // Assert
      (await this.cmtat.balanceOf(address2)).should.be.bignumber.equal(value2);
      (await this.cmtat.totalSupply()).should.be.bignumber.equal(value1.add(value2))

      // Assert event
      // emits a Transfer event
      expectEvent.inLogs(this.logs2, 'Transfer', {
        from: ZERO_ADDRESS,
        to: address2,
        value: value2
      })
      // emits a Mint event
      expectEvent.inLogs(this.logs2, 'Mint', {
        beneficiary: address2,
        amount: value2
      })
    })

    it('testCanBeMintedByANewMinter', async function () {
      // Arrange
      const value1 = new BN(20);
      await this.cmtat.grantRole(MINTER_ROLE, address1, { from: admin });
      // Arrange - Assert
      // Check first balance
      (await this.cmtat.balanceOf(admin)).should.be.bignumber.equal(BN(0));

      // Act
      // Issue 20
      ({ logs: this.logs1 } = await this.cmtat.mint(address1, value1, {
        from: address1
      }));
      // Assert
      // Check balances and total supply
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal(value1);
      (await this.cmtat.totalSupply()).should.be.bignumber.equal(value1)

      // Assert event
      // emits a Transfer event
      expectEvent.inLogs(this.logs1, 'Transfer', {
        from: ZERO_ADDRESS,
        to: address1,
        value: value1
      })
      // emits a Mint event
      expectEvent.inLogs(this.logs1, 'Mint', {
        beneficiary: address1,
        amount: value1
      })
    })

    // reverts when issuing by a non minter
    it('testCannotIssuingByNonMinter', async function () {
      const value1 = new BN(20);
      await expectRevert(
        this.cmtat.mint(address1, value1, { from: address1 }),
        'AccessControl: account ' +
            address1.toLowerCase() +
            ' is missing role ' +
            MINTER_ROLE
      )
    })
  })

  context('Batch Minting', function () {
    /**
    The admin is assigned the MINTER role when the contract is deployed
     */
    it('testCanBeMintedByAdmin', async function () {
      const tokenHolder = [admin, address1, address2]
      const tokenSupplyByHolders = [BN(10), BN(100), BN(1000)]

      // Arrange - Assert
      // Check first balance
      for (let i = 0; i < tokenHolder.length; ++i) {
        (await this.cmtat.balanceOf(tokenHolder[i])).should.be.bignumber.equal(BN(0))
      }

      // Act
      // Issue 20 and check balances and total supply
      ({ logs: this.logs1 } = await this.cmtat.mintBatch(tokenHolder, tokenSupplyByHolders, {
        from: admin
      }))

      // Assert
      for (let i = 0; i < tokenHolder.length; ++i) {
        (await this.cmtat.balanceOf(tokenHolder[i])).should.be.bignumber.equal(tokenSupplyByHolders[i])
      }

      (await this.cmtat.totalSupply()).should.be.bignumber.equal(tokenSupplyByHolders.reduce((a, b) => { return a.add(b) }))

      // Assert event
      // emits a Transfer event
      for (let i = 0; i < tokenHolder.length; ++i) {
        // emits a Mint event
        expectEvent.inLogs(this.logs1, 'Transfer', {
          from: ZERO_ADDRESS,
          to: tokenHolder[i],
          value: tokenSupplyByHolders[i]
        })
      }

      for (let i = 0; i < tokenHolder.length; ++i) {
        // emits a Mint event
        expectEvent.inLogs(this.logs1, 'Mint', {
          beneficiary: tokenHolder[i],
          amount: tokenSupplyByHolders[i]
        })
      }
    })

    it('testCanBeMintedByANewMinter', async function () {
      // Arrange
      await this.cmtat.grantRole(MINTER_ROLE, address1, { from: admin })
      const tokenHolder = [admin, address1, address2]
      const tokenSupplyByHolders = [BN(10), BN(100), BN(1000)]

      // Arrange - Assert
      // Check first balance
      for (let i = 0; i < tokenHolder.length; ++i) {
        (await this.cmtat.balanceOf(tokenHolder[i])).should.be.bignumber.equal(BN(0))
      }

      // Act
      // Issue 20 and check balances and total supply
      ({ logs: this.logs1 } = await this.cmtat.mintBatch(tokenHolder, tokenSupplyByHolders, {
        from: address1
      }))

      // Assert
      for (let i = 0; i < tokenHolder.length; ++i) {
        (await this.cmtat.balanceOf(tokenHolder[i])).should.be.bignumber.equal(tokenSupplyByHolders[i].toString())
      }

      (await this.cmtat.totalSupply()).should.be.bignumber.equal(tokenSupplyByHolders.reduce((a, b) => { return a.add(b) }))

      // Assert event
      // emits a Transfer event
      for (let i = 0; i < tokenHolder.length; ++i) {
        // emits a Mint event
        expectEvent.inLogs(this.logs1, 'Transfer', {
          from: ZERO_ADDRESS,
          to: tokenHolder[i],
          value: tokenSupplyByHolders[i]
        })
      }

      for (let i = 0; i < tokenHolder.length; ++i) {
        // emits a Mint event
        expectEvent.inLogs(this.logs1, 'Mint', {
          beneficiary: tokenHolder[i],
          amount: tokenSupplyByHolders[i]
        })
      }
    })

    // reverts when issuing by a non minter
    it('testCannotIssuingByNonMinter', async function () {
      const tokenHolder = [admin, address1, address2]
      const tokenSupplyByHolders = [BN(10), BN(100), BN(1000)]
      await expectRevert(
        this.cmtat.mintBatch(tokenHolder, tokenSupplyByHolders, { from: address1 }),
        'AccessControl: account ' +
            address1.toLowerCase() +
            ' is missing role ' +
            MINTER_ROLE
      )
    })
  })
}
module.exports = MintModuleCommon
