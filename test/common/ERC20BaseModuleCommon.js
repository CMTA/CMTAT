const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { DEFAULT_ADMIN_ROLE } = require('../utils')
const { should } = require('chai').should()

function BaseModuleCommon (owner, address1, address2, address3, proxyTest) {
  context('Token structure', function () {
    it('testHasTheDefinedName', async function () {
      // Act + Assert
      (await this.cmtat.name()).should.equal('CMTA Token')
    })
    it('testHasTheDefinedSymbol', async function () {
      // Act + Assert
      (await this.cmtat.symbol()).should.equal('CMTAT')
    })
    it('testDecimalsEqual0', async function () {
      // Act + Assert
      (await this.cmtat.decimals()).should.be.bignumber.equal('0')
    })
  })

  context('Allowance', function () {
    // address1 -> address3
    it('testApproveAllowance', async function () {
      // Arrange - Assert
      (
        await this.cmtat.allowance(address1, address3)
      ).should.be.bignumber.equal('0');
      // Act
      ({ logs: this.logs } = await this.cmtat.approve(address3, 20, {
        from: address1
      }));
      // Assert
      (
        await this.cmtat.allowance(address1, address3)
      ).should.be.bignumber.equal('20')
      // emits an Approval event
      expectEvent.inLogs(this.logs, 'Approval', {
        owner: address1,
        spender: address3,
        value: '20'
      })
    })

    // ADDRESS1 -> ADDRESS3
    it('testIncreaseAllowance', async function () {
      // Arrange
      (
        await this.cmtat.allowance(address1, address3)
      ).should.be.bignumber.equal('0')
      await this.cmtat.approve(address3, 20, { from: address1 });
      // Arrange - Assert
      (
        await this.cmtat.allowance(address1, address3)
      ).should.be.bignumber.equal('20');
      // Act
      ({ logs: this.logs } = await this.cmtat.increaseAllowance(address3, 10, {
        from: address1
      }));
      // Assert
      (
        await this.cmtat.allowance(address1, address3)
      ).should.be.bignumber.equal('30')
      // emits an Approval event
      expectEvent.inLogs(this.logs, 'Approval', {
        owner: address1,
        spender: address3,
        value: '30'
      })
    })

    // ADDRESS1 -> ADDRESS3
    it('testDecreaseAllowance', async function () {
      // Arrange
      (
        await this.cmtat.allowance(address1, address3)
      ).should.be.bignumber.equal('0')
      await this.cmtat.approve(address3, 20, { from: address1 });
      // Arrange - Assert
      (
        await this.cmtat.allowance(address1, address3)
      ).should.be.bignumber.equal('20');
      // Act
      ({ logs: this.logs } = await this.cmtat.decreaseAllowance(address3, 10, {
        from: address1
      }));
      // Assert
      (
        await this.cmtat.allowance(address1, address3)
      ).should.be.bignumber.equal('10')
      // emits an Approval event
      expectEvent.inLogs(this.logs, 'Approval', {
        owner: address1,
        spender: address3,
        value: '10'
      })
    })

    // ADDRESS1 -> ADDRESS3
    it('testRedefinedAllowanceWithApprove', async function () {
      // Arrange
      (
        await this.cmtat.allowance(address1, address3)
      ).should.be.bignumber.equal('0')
      await this.cmtat.approve(address3, 20, { from: address1 });
      // Arrange - Assert
      (
        await this.cmtat.allowance(address1, address3)
      ).should.be.bignumber.equal('20');
      // Act
      ({ logs: this.logs } = await this.cmtat.approve(address3, 50, {
        from: address1
      }));
      // Assert
      (
        await this.cmtat.allowance(address1, address3)
      ).should.be.bignumber.equal('50')
      // emits an Approval event
      expectEvent.inLogs(this.logs, 'Approval', {
        owner: address1,
        spender: address3,
        value: '50'
      })
    })

    it('testDefinedAllowanceByTakingInAccountTheCurrentAllowance', async function () {
      // Arrange
      (
        await this.cmtat.allowance(address1, address3)
      ).should.be.bignumber.equal('0')
      await this.cmtat.approve(address3, 20, { from: address1 });
      // Arrange - Assert
      (
        await this.cmtat.allowance(address1, address3)
      ).should.be.bignumber.equal('20');
      // Act
      ({ logs: this.logs } = await this.cmtat.methods[
        'approve(address,uint256,uint256)'
      ](address3, 30, 20, { from: address1 }));
      // Assert
      (
        await this.cmtat.allowance(address1, address3)
      ).should.be.bignumber.equal('30')
      // emits an Approval event
      expectEvent.inLogs(this.logs, 'Approval', {
        owner: address1,
        spender: address3,
        value: '30'
      })
    })

    it('testCannotDefinedAllowanceByTakingInAccountTheWrongCurrentAllowance', async function () {
      // Arrange
      (
        await this.cmtat.allowance(address1, address3)
      ).should.be.bignumber.equal('0')
      await this.cmtat.approve(address3, 20, { from: address1 });
      // Arrange - Assert
      (
        await this.cmtat.allowance(address1, address3)
      ).should.be.bignumber.equal('20')
      // Act
      await expectRevert(
        this.cmtat.methods['approve(address,uint256,uint256)'](
          address3,
          30,
          10,
          { from: address1 }
        ),
        'CMTAT: current allowance is not right'
      );
      // Assert
      (
        await this.cmtat.allowance(address1, address3)
      ).should.be.bignumber.equal('20')
    })
  })

  context('Transfer', function () {
    beforeEach(async function () {
      await this.cmtat.mint(address1, 31, { from: owner })
      await this.cmtat.mint(address2, 32, { from: owner })
      await this.cmtat.mint(address3, 33, { from: owner })
    })

    it('testTransferFromOneAccountToAnother', async function () {
      // Act
      ({ logs: this.logs } = await this.cmtat.transfer(address2, 11, {
        from: address1
      }));
      // Assert
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal('20');
      (await this.cmtat.balanceOf(address2)).should.be.bignumber.equal('43');
      (await this.cmtat.balanceOf(address3)).should.be.bignumber.equal('33');
      (await this.cmtat.totalSupply()).should.be.bignumber.equal('96')
      // emits a Transfer event
      expectEvent.inLogs(this.logs, 'Transfer', {
        from: address1,
        to: address2,
        value: '11'
      })
    })

    // ADDRESS1 -> ADDRESS2
    it('testCannotTransferMoreTokensThanOwn', async function () {
      // Act
      await expectRevert(
        this.cmtat.transfer(address2, 50, { from: address1 }),
        'ERC20: transfer amount exceeds balance'
      )
    })

    // allows address3 to transfer tokens from address1 to address2 with the right allowance
    // ADDRESS3 : ADDRESS1 -> ADDRESS2
    it('testTransferByAnotherAccountWithTheRightAllowance', async function () {
      // Arrange
      await this.cmtat.approve(address3, 20, { from: address1 });
      // Act
      // Transfer
      ({ logs: this.logs } = await this.cmtat.transferFrom(
        address1,
        address2,
        11,
        { from: address3 }
      ));
      // Assert
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal('20');
      (await this.cmtat.balanceOf(address2)).should.be.bignumber.equal('43');
      (await this.cmtat.balanceOf(address3)).should.be.bignumber.equal('33');
      (await this.cmtat.totalSupply()).should.be.bignumber.equal('96')

      // emits a Transfer event
      expectEvent.inLogs(this.logs, 'Transfer', {
        from: address1,
        to: address2,
        value: '11'
      })
      // emits a Spend event
      expectEvent.inLogs(this.logs, 'Spend', {
        owner: address1,
        spender: address3,
        amount: '11'
      })
    })

    // reverts if address3 transfers more tokens than the allowance from address1 to address2
    it('testCannotTransferByAnotherAccountWithInsufficientAllowance', async function () {
      // Arrange
      // Define allowance
      (
        await this.cmtat.allowance(address1, address3)
      ).should.be.bignumber.equal('0')
      await this.cmtat.approve(address3, 20, { from: address1 });
      // Arrange - Assert
      (
        await this.cmtat.allowance(address1, address3)
      ).should.be.bignumber.equal('20')
      // Act
      // Transfer
      await expectRevert(
        this.cmtat.transferFrom(address1, address2, 31, { from: address3 }),
        'ERC20: insufficient allowance'
      )
    })

    // reverts if address3 transfers more tokens than address1 owns from address1 to address2
    it('testCannotTransferByAnotherAccountWithInsufficientBalance', async function () {
      // Arrange
      await this.cmtat.approve(address3, 1000, { from: address1 })
      // Act
      await expectRevert(
        this.cmtat.transferFrom(address1, address2, 50, { from: address3 }),
        'ERC20: transfer amount exceeds balance'
      )
    })
  })
}
module.exports = BaseModuleCommon
