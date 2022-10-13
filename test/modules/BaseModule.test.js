const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { DEFAULT_ADMIN_ROLE } = require('../utils')
const { should } = require('chai').should()

const CMTAT = artifacts.require('CMTAT')

contract(
  'BaseModule',
  function ([_, owner, address1, address2, address3, fakeRuleEngine]) {
    beforeEach(async function () {
      this.cmtat = await CMTAT.new({ from: owner })
      await this.cmtat.initialize(
        owner,
        _,
        'CMTA Token',
        'CMTAT',
        'CMTAT_ISIN',
        'https://cmta.ch',
        { from: owner }
      )
    })

    context('Token structure', function () {
      it('has the defined name', async function () {
        (await this.cmtat.name()).should.equal('CMTA Token')
      })
      it('has the defined symbol', async function () {
        (await this.cmtat.symbol()).should.equal('CMTAT')
      })
      it('is not divisible', async function () {
        (await this.cmtat.decimals()).should.be.bignumber.equal('0')
      })
      it('is has a token ID', async function () {
        (await this.cmtat.tokenId()).should.equal('CMTAT_ISIN')
      })
      it('is has terms', async function () {
        (await this.cmtat.terms()).should.equal('https://cmta.ch')
      })
      it('allows the admin to modify the token ID', async function () {
        (await this.cmtat.tokenId()).should.equal('CMTAT_ISIN')
        await this.cmtat.setTokenId('CMTAT_TOKENID', { from: owner });
        (await this.cmtat.tokenId()).should.equal('CMTAT_TOKENID')
      })
      it('reverts when trying to modify the token ID from non-admin', async function () {
        (await this.cmtat.tokenId()).should.equal('CMTAT_ISIN')
        await expectRevert(
          this.cmtat.setTokenId('CMTAT_TOKENID', { from: address1 }),
          'AccessControl: account ' +
            address1.toLowerCase() +
            ' is missing role ' +
            DEFAULT_ADMIN_ROLE
        );
        (await this.cmtat.tokenId()).should.equal('CMTAT_ISIN')
      })
      it('allows the admin to modify the terms', async function () {
        (await this.cmtat.terms()).should.equal('https://cmta.ch')
        await this.cmtat.setTerms('https://cmta.ch/terms', { from: owner });
        (await this.cmtat.terms()).should.equal('https://cmta.ch/terms')
      })
      it('reverts when trying to modify the terms from non-admin', async function () {
        (await this.cmtat.terms()).should.equal('https://cmta.ch')
        await expectRevert(
          this.cmtat.setTerms('https://cmta.ch/terms', { from: address1 }),
          'AccessControl: account ' +
            address1.toLowerCase() +
            ' is missing role ' +
            DEFAULT_ADMIN_ROLE
        );
        (await this.cmtat.terms()).should.equal('https://cmta.ch')
      })
      it('allows the admin to kill the contract', async function () {
        this.cmtat.kill({ from: owner })
        try {
          await this.cmtat.terms()
        } catch (e) {
          e.message.should.equal(
            "Returned values aren't valid, did it run Out of Gas? You might also see this error if you are not using the correct ABI for the contract you are retrieving data from, requesting data from a block number that does not exist, or querying a node which is not fully synced."
          )
        }
      })
      it('reverts when trying to kill the contract from non-admin', async function () {
        await expectRevert(
          this.cmtat.kill({ from: address1 }),
          'AccessControl: account ' +
            address1.toLowerCase() +
            ' is missing role ' +
            DEFAULT_ADMIN_ROLE
        );
        (await this.cmtat.terms()).should.equal('https://cmta.ch')
      })
    })

    context('Allowance', function () {
      it('allows address1 to define a spending allowance for address3', async function () {
        (
          await this.cmtat.allowance(address1, address3)
        ).should.be.bignumber.equal('0');
        ({ logs: this.logs } = await this.cmtat.approve(address3, 20, {
          from: address1
        }));
        (
          await this.cmtat.allowance(address1, address3)
        ).should.be.bignumber.equal('20')
      })

      it('emits an Approval event', function () {
        expectEvent.inLogs(this.logs, 'Approval', {
          owner: address1,
          spender: address3,
          value: '20'
        })
      })

      it('allows address1 to increase the allowance for address3', async function () {
        (
          await this.cmtat.allowance(address1, address3)
        ).should.be.bignumber.equal('0')
        await this.cmtat.approve(address3, 20, { from: address1 });
        (
          await this.cmtat.allowance(address1, address3)
        ).should.be.bignumber.equal('20');
        ({ logs: this.logs } = await this.cmtat.increaseAllowance(
          address3,
          10,
          { from: address1 }
        ));
        (
          await this.cmtat.allowance(address1, address3)
        ).should.be.bignumber.equal('30')
      })

      it('emits an Approval event', function () {
        expectEvent.inLogs(this.logs, 'Approval', {
          owner: address1,
          spender: address3,
          value: '30'
        })
      })

      it('allows address1 to decrease the allowance for address3', async function () {
        (
          await this.cmtat.allowance(address1, address3)
        ).should.be.bignumber.equal('0')
        await this.cmtat.approve(address3, 20, { from: address1 });
        (
          await this.cmtat.allowance(address1, address3)
        ).should.be.bignumber.equal('20');
        ({ logs: this.logs } = await this.cmtat.decreaseAllowance(
          address3,
          10,
          { from: address1 }
        ));
        (
          await this.cmtat.allowance(address1, address3)
        ).should.be.bignumber.equal('10')
      })

      it('emits an Approval event', function () {
        expectEvent.inLogs(this.logs, 'Approval', {
          owner: address1,
          spender: address3,
          value: '10'
        })
      })

      it('allows address1 to redefine a spending allowance for address3', async function () {
        (
          await this.cmtat.allowance(address1, address3)
        ).should.be.bignumber.equal('0')
        await this.cmtat.approve(address3, 20, { from: address1 });
        (
          await this.cmtat.allowance(address1, address3)
        ).should.be.bignumber.equal('20');
        ({ logs: this.logs } = await this.cmtat.approve(address3, 50, {
          from: address1
        }));
        (
          await this.cmtat.allowance(address1, address3)
        ).should.be.bignumber.equal('50')
      })

      it('emits an Approval event', function () {
        expectEvent.inLogs(this.logs, 'Approval', {
          owner: address1,
          spender: address3,
          value: '50'
        })
      })

      it('allows address1 to define a spending allowance for address3 taking current allowance in account', async function () {
        (
          await this.cmtat.allowance(address1, address3)
        ).should.be.bignumber.equal('0')
        await this.cmtat.approve(address3, 20, { from: address1 });
        (
          await this.cmtat.allowance(address1, address3)
        ).should.be.bignumber.equal('20');
        ({ logs: this.logs } = await this.cmtat.methods[
          'approve(address,uint256,uint256)'
        ](address3, 30, 20, { from: address1 }));
        (
          await this.cmtat.allowance(address1, address3)
        ).should.be.bignumber.equal('30')
      })

      it('emits an Approval event', function () {
        expectEvent.inLogs(this.logs, 'Approval', {
          owner: address1,
          spender: address3,
          value: '30'
        })
      })

      it('reverts if trying to define a spending allowance for address3 with wrong current allowance', async function () {
        (
          await this.cmtat.allowance(address1, address3)
        ).should.be.bignumber.equal('0')
        await this.cmtat.approve(address3, 20, { from: address1 });
        (
          await this.cmtat.allowance(address1, address3)
        ).should.be.bignumber.equal('20')
        await expectRevert(
          this.cmtat.methods['approve(address,uint256,uint256)'](
            address3,
            30,
            10,
            { from: address1 }
          ),
          'CMTAT: current allowance is not right'
        );
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

      it('allows address1 to transfer tokens to address2', async function () {
        ({ logs: this.logs } = await this.cmtat.transfer(address2, 11, {
          from: address1
        }));
        (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal('20');
        (await this.cmtat.balanceOf(address2)).should.be.bignumber.equal('43');
        (await this.cmtat.balanceOf(address3)).should.be.bignumber.equal('33');
        (await this.cmtat.totalSupply()).should.be.bignumber.equal('96')
      })

      it('emits a Transfer event', function () {
        expectEvent.inLogs(this.logs, 'Transfer', {
          from: address1,
          to: address2,
          value: '11'
        })
      })

      it('reverts if address1 transfers more tokens than he owns to address2', async function () {
        await expectRevert.unspecified(
          this.cmtat.transfer(address2, 50, { from: address1 })
        )
      })

      it('allows address3 to transfer tokens from address1 to address2 with the right allowance', async function () {
        // Define allowance
        await this.cmtat.approve(address3, 20, { from: address1 });

        // Transfer
        ({ logs: this.logs } = await this.cmtat.transferFrom(
          address1,
          address2,
          11,
          { from: address3 }
        ));
        (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal('20');
        (await this.cmtat.balanceOf(address2)).should.be.bignumber.equal('43');
        (await this.cmtat.balanceOf(address3)).should.be.bignumber.equal('33');
        (await this.cmtat.totalSupply()).should.be.bignumber.equal('96')
      })

      it('emits a Transfer event', function () {
        expectEvent.inLogs(this.logs, 'Transfer', {
          from: address1,
          to: address2,
          value: '11'
        })
      })

      it('emits a Spend event', function () {
        expectEvent.inLogs(this.logs, 'Spend', {
          owner: address1,
          spender: address3,
          amount: '11'
        })
      })

      it('reverts if address3 transfers more tokens than the allowance from address1 to address2', async function () {
        // Define allowance
        (
          await this.cmtat.allowance(address1, address3)
        ).should.be.bignumber.equal('0')
        await this.cmtat.approve(address3, 20, { from: address1 });
        (
          await this.cmtat.allowance(address1, address3)
        ).should.be.bignumber.equal('20')

        // Transfer
        await expectRevert.unspecified(
          this.cmtat.transferFrom(address1, address2, 31, { from: address3 })
        )
      })

      it('reverts if address3 transfers more tokens than address1 owns from address1 to address2', async function () {
        await this.cmtat.approve(address3, 1000, { from: address1 })
        await expectRevert.unspecified(
          this.cmtat.transferFrom(address1, address2, 50, { from: address3 })
        )
      })
    })
  }
)
