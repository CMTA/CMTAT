const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { SNAPSHOOTER_ROLE } = require('../../utils')
const { should } = require('chai').should()
const CMTAT = artifacts.require('CMTAT')

const getUnixTimestamp = () => {
  return Math.round(new Date().getTime() / 1000)
}

const timeout = function (ms) {
  return new Promise((resolve) => setTimeout(resolve, ms))
}

function SnapshotModuleCommon (owner, address1, address2, address3) {
  context('Snapshoting', function () {
    beforeEach(async function () {
      await this.cmtat.mint(address1, 31, { from: owner })
      await this.cmtat.mint(address2, 32, { from: owner })
      await this.cmtat.mint(address3, 33, { from: owner })
    })
    
    context('Before any snapshot', function () {
      it('can get the total supply', async function () {
        (
          await this.cmtat.snapshotTotalSupply(getUnixTimestamp())
        ).should.be.bignumber.equal('96')
      })
    
      it('can get the balance of an address', async function () {
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)
        ).should.be.bignumber.equal('31')
      })
    })
    
    context('With one planned snapshot', function () {
      beforeEach(async function () {
        this.snapshotTime = `${getUnixTimestamp() + 1}`
        this.beforeSnapshotTime = `${getUnixTimestamp() - 60}`
        await this.cmtat.scheduleSnapshot(this.snapshotTime, { from: owner })
        await timeout(3000)
      })
    
      it('can mint tokens', async function () {
        (
          await this.cmtat.snapshotTotalSupply(getUnixTimestamp())
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)
        ).should.be.bignumber.equal('31');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)
        ).should.be.bignumber.equal('32')
    
        // Gas and gasPrice are fixed arbitrarily
        await this.cmtat.mint(address1, 20, {
          from: owner,
          gas: 5000000,
          gasPrice: 500000000
        });
    
        (
          await this.cmtat.snapshotTotalSupply(this.beforeSnapshotTime)
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(
            this.beforeSnapshotTime,
            address1
          )
        ).should.be.bignumber.equal('31');
        (
          await this.cmtat.snapshotBalanceOf(
            this.beforeSnapshotTime,
            address2
          )
        ).should.be.bignumber.equal('32');
        (
          await this.cmtat.snapshotTotalSupply(getUnixTimestamp())
        ).should.be.bignumber.equal('116');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)
        ).should.be.bignumber.equal('51');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)
        ).should.be.bignumber.equal('32')
        const snapshots = await this.cmtat.getNextSnapshots()
        snapshots.length.should.equal(0)
      })
    
      it('can burn tokens', async function () {
        (
          await this.cmtat.snapshotTotalSupply(getUnixTimestamp())
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)
        ).should.be.bignumber.equal('31');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)
        ).should.be.bignumber.equal('32');
        (await this.cmtat.forceBurn(address1, 20, {
          from: owner,
          gas: 5000000,
          gasPrice: 500000000
        }));
        (
          await this.cmtat.snapshotTotalSupply(this.beforeSnapshotTime)
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(
            this.beforeSnapshotTime,
            address1
          )
        ).should.be.bignumber.equal('31');
        (
          await this.cmtat.snapshotBalanceOf(
            this.beforeSnapshotTime,
            address2
          )
        ).should.be.bignumber.equal('32');
        (
          await this.cmtat.snapshotTotalSupply(getUnixTimestamp())
        ).should.be.bignumber.equal('76');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)
        ).should.be.bignumber.equal('11');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)
        ).should.be.bignumber.equal('32')
        const snapshots = await this.cmtat.getNextSnapshots()
        snapshots.length.should.equal(0)
      })
    
      it('can transfer tokens', async function () {
        (
          await this.cmtat.snapshotTotalSupply(getUnixTimestamp())
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)
        ).should.be.bignumber.equal('31');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)
        ).should.be.bignumber.equal('32')
        // Gas and gasPrice are fixed arbitrarily
        await this.cmtat.transfer(address2, 20, {
          from: address1,
          gas: 5000000,
          gasPrice: 500000000
        });
        (
          await this.cmtat.snapshotTotalSupply(this.beforeSnapshotTime)
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(
            this.beforeSnapshotTime,
            address1
          )
        ).should.be.bignumber.equal('31');
        (
          await this.cmtat.snapshotBalanceOf(
            this.beforeSnapshotTime,
            address2
          )
        ).should.be.bignumber.equal('32');
        (
          await this.cmtat.snapshotTotalSupply(getUnixTimestamp())
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)
        ).should.be.bignumber.equal('11');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)
        ).should.be.bignumber.equal('52')
        const snapshots = await this.cmtat.getNextSnapshots()
        snapshots.length.should.equal(0)
      })
    })
    
    context('With multiple planned snapshot', function () {
      beforeEach(async function () {
        this.snapshotTime1 = `${getUnixTimestamp() + 1}`
        this.snapshotTime2 = `${getUnixTimestamp() + 6}`
        this.snapshotTime3 = `${getUnixTimestamp() + 11}`
        this.beforeSnapshotTime = `${getUnixTimestamp() - 60}`
        await this.cmtat.scheduleSnapshot(this.snapshotTime1, {
          from: owner
        })
        await this.cmtat.scheduleSnapshot(this.snapshotTime2, {
          from: owner
        })
        await this.cmtat.scheduleSnapshot(this.snapshotTime3, {
          from: owner
        })
        await timeout(3000)
      })
    
      it('can transfer tokens after first snapshot', async function () {
        (
          await this.cmtat.snapshotTotalSupply(getUnixTimestamp())
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)
        ).should.be.bignumber.equal('31');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)
        ).should.be.bignumber.equal('32')
        // Gas and gasPrice are fixed arbitrarily
        await this.cmtat.transfer(address2, 20, {
          from: address1,
          gas: 5000000,
          gasPrice: 500000000
        });
        (
          await this.cmtat.snapshotTotalSupply(this.beforeSnapshotTime)
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(
            this.beforeSnapshotTime,
            address1
          )
        ).should.be.bignumber.equal('31');
        (
          await this.cmtat.snapshotBalanceOf(
            this.beforeSnapshotTime,
            address2
          )
        ).should.be.bignumber.equal('32');
        (
          await this.cmtat.snapshotTotalSupply(getUnixTimestamp())
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)
        ).should.be.bignumber.equal('11');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)
        ).should.be.bignumber.equal('52')
        const snapshots = await this.cmtat.getNextSnapshots()
        snapshots.length.should.equal(2)
      })
    
      it('can transfer tokens after second snapshot', async function () {
        await timeout(5000);
        (
          await this.cmtat.snapshotTotalSupply(getUnixTimestamp())
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)
        ).should.be.bignumber.equal('31');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)
        ).should.be.bignumber.equal('32')
        // Gas and gasPrice are fixed arbitrarily
        await this.cmtat.transfer(address2, 20, {
          from: address1,
          gas: 5000000,
          gasPrice: 500000000
        });
        (
          await this.cmtat.snapshotTotalSupply(this.snapshotTime1)
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(this.snapshotTime1, address1)
        ).should.be.bignumber.equal('31');
        (
          await this.cmtat.snapshotBalanceOf(this.snapshotTime1, address2)
        ).should.be.bignumber.equal('32');
        (
          await this.cmtat.snapshotTotalSupply(getUnixTimestamp())
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)
        ).should.be.bignumber.equal('11');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)
        ).should.be.bignumber.equal('52')
        const snapshots = await this.cmtat.getNextSnapshots()
        snapshots.length.should.equal(1)
      })
    
      it('can transfer tokens after third snapshot', async function () {
        await timeout(10000);
        (
          await this.cmtat.snapshotTotalSupply(getUnixTimestamp())
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)
        ).should.be.bignumber.equal('31');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)
        ).should.be.bignumber.equal('32')
        // Gas and gasPrice are fixed arbitrarily
        await this.cmtat.transfer(address2, 20, {
          from: address1,
          gas: 5000000,
          gasPrice: 500000000
        });
        (
          await this.cmtat.snapshotTotalSupply(this.snapshotTime1)
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(this.snapshotTime1, address1)
        ).should.be.bignumber.equal('31');
        (
          await this.cmtat.snapshotBalanceOf(this.snapshotTime1, address2)
        ).should.be.bignumber.equal('32');
        (
          await this.cmtat.snapshotTotalSupply(getUnixTimestamp())
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)
        ).should.be.bignumber.equal('11');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)
        ).should.be.bignumber.equal('52')
        const snapshots = await this.cmtat.getNextSnapshots()
        snapshots.length.should.equal(0)
      })
    
      it('can transfer tokens multiple times between snapshots', async function () {
        (
          await this.cmtat.snapshotTotalSupply(getUnixTimestamp())
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)
        ).should.be.bignumber.equal('31');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)
        ).should.be.bignumber.equal('32')
        // Gas and gasPrice are fixed arbitrarily
        await this.cmtat.transfer(address2, 20, {
          from: address1,
          gas: 5000000,
          gasPrice: 500000000
        });
        (
          await this.cmtat.snapshotTotalSupply(this.beforeSnapshotTime)
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(
            this.beforeSnapshotTime,
            address1
          )
        ).should.be.bignumber.equal('31');
        (
          await this.cmtat.snapshotBalanceOf(
            this.beforeSnapshotTime,
            address2
          )
        ).should.be.bignumber.equal('32');
        (
          await this.cmtat.snapshotTotalSupply(getUnixTimestamp())
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)
        ).should.be.bignumber.equal('11');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)
        ).should.be.bignumber.equal('52');
        (await this.cmtat.getNextSnapshots()).length.should.equal(2)
        await timeout(5000)
        // Gas and gasPrice are fixed arbitrarily
        await this.cmtat.transfer(address1, 10, {
          from: address2,
          gas: 5000000,
          gasPrice: 500000000
        });
        (
          await this.cmtat.snapshotTotalSupply(this.beforeSnapshotTime)
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(
            this.beforeSnapshotTime,
            address1
          )
        ).should.be.bignumber.equal('31');
        (
          await this.cmtat.snapshotBalanceOf(
            this.beforeSnapshotTime,
            address2
          )
        ).should.be.bignumber.equal('32');
        (
          await this.cmtat.snapshotTotalSupply(this.snapshotTime1)
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(this.snapshotTime1, address1)
        ).should.be.bignumber.equal('31');
        (
          await this.cmtat.snapshotBalanceOf(this.snapshotTime1, address2)
        ).should.be.bignumber.equal('32');
        (
          await this.cmtat.snapshotTotalSupply(this.snapshotTime2)
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(this.snapshotTime2, address1)
        ).should.be.bignumber.equal('11');
        (
          await this.cmtat.snapshotBalanceOf(this.snapshotTime2, address2)
        ).should.be.bignumber.equal('52');
        (
          await this.cmtat.snapshotTotalSupply(getUnixTimestamp())
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)
        ).should.be.bignumber.equal('21');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)
        ).should.be.bignumber.equal('42');
        (await this.cmtat.getNextSnapshots()).length.should.equal(1)
        await timeout(5000)
        // Gas and gasPrice are fixed arbitrarily
        await this.cmtat.transfer(address2, 5, {
          from: address1,
          gas: 5000000,
          gasPrice: 500000000
        });
        (
          await this.cmtat.snapshotTotalSupply(this.beforeSnapshotTime)
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(
            this.beforeSnapshotTime,
            address1
          )
        ).should.be.bignumber.equal('31');
        (
          await this.cmtat.snapshotBalanceOf(
            this.beforeSnapshotTime,
            address2
          )
        ).should.be.bignumber.equal('32');
        (
          await this.cmtat.snapshotTotalSupply(this.snapshotTime1)
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(this.snapshotTime1, address1)
        ).should.be.bignumber.equal('31');
        (
          await this.cmtat.snapshotBalanceOf(this.snapshotTime1, address2)
        ).should.be.bignumber.equal('32');
        (
          await this.cmtat.snapshotTotalSupply(this.snapshotTime2)
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(this.snapshotTime2, address1)
        ).should.be.bignumber.equal('11');
        (
          await this.cmtat.snapshotBalanceOf(this.snapshotTime2, address2)
        ).should.be.bignumber.equal('52');
        (
          await this.cmtat.snapshotTotalSupply(this.snapshotTime3)
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(this.snapshotTime3, address1)
        ).should.be.bignumber.equal('21');
        (
          await this.cmtat.snapshotBalanceOf(this.snapshotTime3, address2)
        ).should.be.bignumber.equal('42');
        (
          await this.cmtat.snapshotTotalSupply(getUnixTimestamp())
        ).should.be.bignumber.equal('96');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)
        ).should.be.bignumber.equal('16');
        (
          await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)
        ).should.be.bignumber.equal('47');
        (await this.cmtat.getNextSnapshots()).length.should.equal(0)
      })
    })
  })
}
module.exports = SnapshotModuleCommon
