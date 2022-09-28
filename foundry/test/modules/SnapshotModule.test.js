const { expectEvent, expectRevert } = require('openzeppelin-test-helpers');
const { SNAPSHOOTER_ROLE } = require('../utils');
require('chai/register-should');

const CMTAT = artifacts.require('CMTAT');

const getUnixTimestamp = () => {
  return Math.round(new Date().getTime()/1000);
}

const timeout = function (ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

contract('SnapshotModule', function ([_, owner, address1, address2, address3, fakeRuleEngine]) {
  beforeEach(async function () {
    this.cmtat = await CMTAT.new({ from: owner });
    this.cmtat.initialize(owner, _, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', { from: owner });
  });

  context('Snapshot scheduling', function () {
    it('can schedule a snapshot with the snapshoter role', async function () {
      this.snapshotTime = `${getUnixTimestamp() + 60}`;
      ({ logs: this.logs } = await this.cmtat.scheduleSnapshot(this.snapshotTime, {from: owner}));
      const snapshots = await this.cmtat.getNextSnapshots();
      snapshots.length.should.equal(1);
      snapshots[0].should.be.bignumber.equal(this.snapshotTime);
    }); 
    
    it('emits a SnapshotSchedule event', function () {
      expectEvent.inLogs(this.logs, 'SnapshotSchedule', { oldTime: '0', newTime: this.snapshotTime });
    });

    it('reverts when calling from non-owner', async function () {
      await expectRevert(this.cmtat.scheduleSnapshot(this.snapshotTime, { from: address1 }), 'AccessControl: account ' + address1.toLowerCase() + ' is missing role ' + SNAPSHOOTER_ROLE);
    });

    it('reverts when trying to schedule a snapshot in the past', async function () {
      await expectRevert(this.cmtat.scheduleSnapshot(`${getUnixTimestamp() - 60}`, { from: owner }), 'Snapshot scheduled in the past');
    });

    it('reverts when trying to schedule a snapshot with the same time twice', async function () {
      await this.cmtat.scheduleSnapshot(this.snapshotTime, {from: owner})
      await expectRevert(this.cmtat.scheduleSnapshot(this.snapshotTime, { from: owner }), 'Snapshot already scheduled for this time');
      const snapshots = await this.cmtat.getNextSnapshots();
      snapshots.length.should.equal(1);
      snapshots[0].should.be.bignumber.equal(this.snapshotTime);
    });

  });

  context('Snapshot unscheduling', function () {
    beforeEach(async function () {
      this.snapshotTime = `${getUnixTimestamp() + 60}`;
      await this.cmtat.scheduleSnapshot(this.snapshotTime, {from: owner});
    });
    it('can unschedule a snapshot with the snapshoter role and emits a SnapshotUnschedule event', async function () {
      ({ logs: this.logs } = await this.cmtat.unscheduleSnapshot(this.snapshotTime, {from: owner}));
      expectEvent.inLogs(this.logs, 'SnapshotUnschedule', { time: this.snapshotTime });
      const snapshots = await this.cmtat.getNextSnapshots();
      snapshots.length.should.equal(0);
    }); 
  

    it('reverts when calling from non-owner', async function () {
      await expectRevert(this.cmtat.unscheduleSnapshot(this.snapshotTime, { from: address1 }), 'AccessControl: account ' + address1.toLowerCase() + ' is missing role ' + SNAPSHOOTER_ROLE);
    });

    it('reverts when snapshot is not found', async function () {
      await expectRevert(this.cmtat.unscheduleSnapshot(`${getUnixTimestamp() + 90}`, { from: owner }), 'Snapshot not found');
    });

    it('reverts when snapshot has been processed', async function () {
      await expectRevert(this.cmtat.unscheduleSnapshot(`${getUnixTimestamp() - 60}`, { from: owner }), 'Snapshot already done');
    });
  });

  context('Snapshot rescheduling', function () {
    beforeEach(async function () {
      this.snapshotTime = `${getUnixTimestamp() + 60}`;
      this.newSnapshotTime = `${getUnixTimestamp() + 90}`;
      await this.cmtat.scheduleSnapshot(this.snapshotTime, {from: owner});
    });

    it('can reschedule a snapshot with the snapshoter role and emits a SnapshotSchedule event', async function () {
      ({ logs: this.logs } = await this.cmtat.rescheduleSnapshot(this.snapshotTime, this.newSnapshotTime, {from: owner}));
      expectEvent.inLogs(this.logs, 'SnapshotSchedule', { oldTime: this.snapshotTime, newTime: this.newSnapshotTime });
      const snapshots = await this.cmtat.getNextSnapshots();
      snapshots.length.should.equal(1);
      snapshots[0].should.be.bignumber.equal(this.newSnapshotTime);
    }); 

    it('reverts when calling from non-owner', async function () {
      await expectRevert(this.cmtat.rescheduleSnapshot(this.snapshotTime, this.newSnapshotTime, { from: address1 }), 'AccessControl: account ' + address1.toLowerCase() + ' is missing role ' + SNAPSHOOTER_ROLE);
    });

    it('reverts when trying to reschedule a snapshot in the past', async function () {
      await expectRevert(this.cmtat.rescheduleSnapshot(this.snapshotTime, `${getUnixTimestamp() - 60}`, { from: owner }), 'Snapshot scheduled in the past');
    });

    it('reverts when trying to schedule a snapshot with the same time twice', async function () {
      await this.cmtat.rescheduleSnapshot(this.snapshotTime, this.newSnapshotTime, {from: owner})
      await expectRevert(this.cmtat.rescheduleSnapshot(this.snapshotTime, this.newSnapshotTime, {from: owner}), 'Snapshot already scheduled for this time');
      const snapshots = await this.cmtat.getNextSnapshots();
      snapshots.length.should.equal(1);
      snapshots[0].should.be.bignumber.equal(this.newSnapshotTime);
    });

    it('reverts when snapshot is not found', async function () {
      await expectRevert(this.cmtat.rescheduleSnapshot(`${getUnixTimestamp() + 90}`, this.newSnapshotTime, { from: owner }), 'Snapshot not found');
    });

    it('reverts when snapshot has been processed', async function () {
      await expectRevert(this.cmtat.rescheduleSnapshot(`${getUnixTimestamp() - 60}`, this.newSnapshotTime, { from: owner }), 'Snapshot already done');
    });
  });


  context('Snapshoting', function () {
    beforeEach(async function () {
      await this.cmtat.mint(address1, 31, {from: owner});
      await this.cmtat.mint(address2, 32, {from: owner});
      await this.cmtat.mint(address3, 33, {from: owner});
    });

    context('Before any snapshot', function () {
      it('can get the total supply', async function () {
        (await this.cmtat.snapshotTotalSupply(getUnixTimestamp())).should.be.bignumber.equal('96');
      });

      it('can get the balance of an address', async function () {
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)).should.be.bignumber.equal('31');
      });
    });

    context('With one planned snapshot', function () {
      beforeEach(async function () {
        this.snapshotTime = `${getUnixTimestamp() + 1}`;
        this.beforeSnapshotTime = `${getUnixTimestamp() - 60}`
        await this.cmtat.scheduleSnapshot(this.snapshotTime, {from: owner});
        await timeout(3000);
      });

      it('can mint tokens', async function () {
        (await this.cmtat.snapshotTotalSupply(getUnixTimestamp())).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)).should.be.bignumber.equal('31');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)).should.be.bignumber.equal('32');
        await this.cmtat.mint(address1, 20, {from: owner});
        (await this.cmtat.snapshotTotalSupply(this.beforeSnapshotTime)).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(this.beforeSnapshotTime, address1)).should.be.bignumber.equal('31');
        (await this.cmtat.snapshotBalanceOf(this.beforeSnapshotTime, address2)).should.be.bignumber.equal('32');
        (await this.cmtat.snapshotTotalSupply(getUnixTimestamp())).should.be.bignumber.equal('116');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)).should.be.bignumber.equal('51');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)).should.be.bignumber.equal('32');
        const snapshots = await this.cmtat.getNextSnapshots();
        snapshots.length.should.equal(0);
      });

      it('can burn tokens', async function () {
        await this.cmtat.approve(owner, 50, {from: address1 });
        (await this.cmtat.snapshotTotalSupply(getUnixTimestamp())).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)).should.be.bignumber.equal('31');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)).should.be.bignumber.equal('32');
        await this.cmtat.burnFrom(address1, 20, {from: owner});
        (await this.cmtat.snapshotTotalSupply(this.beforeSnapshotTime)).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(this.beforeSnapshotTime, address1)).should.be.bignumber.equal('31');
        (await this.cmtat.snapshotBalanceOf(this.beforeSnapshotTime, address2)).should.be.bignumber.equal('32');
        (await this.cmtat.snapshotTotalSupply(getUnixTimestamp())).should.be.bignumber.equal('76');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)).should.be.bignumber.equal('11');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)).should.be.bignumber.equal('32');
        const snapshots = await this.cmtat.getNextSnapshots();
        snapshots.length.should.equal(0);
      });

      it('can transfer tokens', async function () {
        (await this.cmtat.snapshotTotalSupply(getUnixTimestamp())).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)).should.be.bignumber.equal('31');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)).should.be.bignumber.equal('32');
        await this.cmtat.transfer(address2, 20, {from: address1});
        (await this.cmtat.snapshotTotalSupply(this.beforeSnapshotTime)).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(this.beforeSnapshotTime, address1)).should.be.bignumber.equal('31');
        (await this.cmtat.snapshotBalanceOf(this.beforeSnapshotTime, address2)).should.be.bignumber.equal('32');
        (await this.cmtat.snapshotTotalSupply(getUnixTimestamp())).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)).should.be.bignumber.equal('11');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)).should.be.bignumber.equal('52');
        const snapshots = await this.cmtat.getNextSnapshots();
        snapshots.length.should.equal(0);
      });
    });

    context('With multiple planned snapshot', function () {
      beforeEach(async function () {
        this.snapshotTime1 = `${getUnixTimestamp() + 1}`;
        this.snapshotTime2 = `${getUnixTimestamp() + 6}`;
        this.snapshotTime3 = `${getUnixTimestamp() + 11}`;
        this.beforeSnapshotTime = `${getUnixTimestamp() - 60}`
        await this.cmtat.scheduleSnapshot(this.snapshotTime1, {from: owner});
        await this.cmtat.scheduleSnapshot(this.snapshotTime2, {from: owner});
        await this.cmtat.scheduleSnapshot(this.snapshotTime3, {from: owner});
        await timeout(3000);
      });

      it('can transfer tokens after first snapshot', async function () {
        (await this.cmtat.snapshotTotalSupply(getUnixTimestamp())).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)).should.be.bignumber.equal('31');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)).should.be.bignumber.equal('32');
        await this.cmtat.transfer(address2, 20, {from: address1});
        (await this.cmtat.snapshotTotalSupply(this.beforeSnapshotTime)).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(this.beforeSnapshotTime, address1)).should.be.bignumber.equal('31');
        (await this.cmtat.snapshotBalanceOf(this.beforeSnapshotTime, address2)).should.be.bignumber.equal('32');
        (await this.cmtat.snapshotTotalSupply(getUnixTimestamp())).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)).should.be.bignumber.equal('11');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)).should.be.bignumber.equal('52');
        const snapshots = await this.cmtat.getNextSnapshots();
        snapshots.length.should.equal(2);
      });

      it('can transfer tokens after second snapshot', async function () {
        await timeout(5000);
        (await this.cmtat.snapshotTotalSupply(getUnixTimestamp())).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)).should.be.bignumber.equal('31');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)).should.be.bignumber.equal('32');
        await this.cmtat.transfer(address2, 20, {from: address1});
        (await this.cmtat.snapshotTotalSupply(this.snapshotTime1)).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(this.snapshotTime1, address1)).should.be.bignumber.equal('31');
        (await this.cmtat.snapshotBalanceOf(this.snapshotTime1, address2)).should.be.bignumber.equal('32');
        (await this.cmtat.snapshotTotalSupply(getUnixTimestamp())).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)).should.be.bignumber.equal('11');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)).should.be.bignumber.equal('52');
        const snapshots = await this.cmtat.getNextSnapshots();
        snapshots.length.should.equal(1);
      });

      it('can transfer tokens after third snapshot', async function () {
        await timeout(10000);
        (await this.cmtat.snapshotTotalSupply(getUnixTimestamp())).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)).should.be.bignumber.equal('31');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)).should.be.bignumber.equal('32');
        await this.cmtat.transfer(address2, 20, {from: address1});
        (await this.cmtat.snapshotTotalSupply(this.snapshotTime1)).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(this.snapshotTime1, address1)).should.be.bignumber.equal('31');
        (await this.cmtat.snapshotBalanceOf(this.snapshotTime1, address2)).should.be.bignumber.equal('32');
        (await this.cmtat.snapshotTotalSupply(getUnixTimestamp())).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)).should.be.bignumber.equal('11');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)).should.be.bignumber.equal('52');
        const snapshots = await this.cmtat.getNextSnapshots();
        snapshots.length.should.equal(0);
      });

      it('can transfer tokens multiple times between snapshots', async function () {
        (await this.cmtat.snapshotTotalSupply(getUnixTimestamp())).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)).should.be.bignumber.equal('31');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)).should.be.bignumber.equal('32');
        await this.cmtat.transfer(address2, 20, {from: address1});
        (await this.cmtat.snapshotTotalSupply(this.beforeSnapshotTime)).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(this.beforeSnapshotTime, address1)).should.be.bignumber.equal('31');
        (await this.cmtat.snapshotBalanceOf(this.beforeSnapshotTime, address2)).should.be.bignumber.equal('32');
        (await this.cmtat.snapshotTotalSupply(getUnixTimestamp())).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)).should.be.bignumber.equal('11');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)).should.be.bignumber.equal('52');
        (await this.cmtat.getNextSnapshots()).length.should.equal(2);
        await timeout(5000);
        await this.cmtat.transfer(address1, 10, {from: address2});
        (await this.cmtat.snapshotTotalSupply(this.beforeSnapshotTime)).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(this.beforeSnapshotTime, address1)).should.be.bignumber.equal('31');
        (await this.cmtat.snapshotBalanceOf(this.beforeSnapshotTime, address2)).should.be.bignumber.equal('32');
        (await this.cmtat.snapshotTotalSupply(this.snapshotTime1)).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(this.snapshotTime1, address1)).should.be.bignumber.equal('31');
        (await this.cmtat.snapshotBalanceOf(this.snapshotTime1, address2)).should.be.bignumber.equal('32');
        (await this.cmtat.snapshotTotalSupply(this.snapshotTime2)).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(this.snapshotTime2, address1)).should.be.bignumber.equal('11');
        (await this.cmtat.snapshotBalanceOf(this.snapshotTime2, address2)).should.be.bignumber.equal('52');
        (await this.cmtat.snapshotTotalSupply(getUnixTimestamp())).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)).should.be.bignumber.equal('21');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)).should.be.bignumber.equal('42');
        (await this.cmtat.getNextSnapshots()).length.should.equal(1);
        await timeout(5000);
        await this.cmtat.transfer(address2, 5, {from: address1});
        (await this.cmtat.snapshotTotalSupply(this.beforeSnapshotTime)).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(this.beforeSnapshotTime, address1)).should.be.bignumber.equal('31');
        (await this.cmtat.snapshotBalanceOf(this.beforeSnapshotTime, address2)).should.be.bignumber.equal('32');
        (await this.cmtat.snapshotTotalSupply(this.snapshotTime1)).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(this.snapshotTime1, address1)).should.be.bignumber.equal('31');
        (await this.cmtat.snapshotBalanceOf(this.snapshotTime1, address2)).should.be.bignumber.equal('32');
        (await this.cmtat.snapshotTotalSupply(this.snapshotTime2)).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(this.snapshotTime2, address1)).should.be.bignumber.equal('11');
        (await this.cmtat.snapshotBalanceOf(this.snapshotTime2, address2)).should.be.bignumber.equal('52');
        (await this.cmtat.snapshotTotalSupply(this.snapshotTime3)).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(this.snapshotTime3, address1)).should.be.bignumber.equal('21');
        (await this.cmtat.snapshotBalanceOf(this.snapshotTime3, address2)).should.be.bignumber.equal('42');
        (await this.cmtat.snapshotTotalSupply(getUnixTimestamp())).should.be.bignumber.equal('96');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address1)).should.be.bignumber.equal('16');
        (await this.cmtat.snapshotBalanceOf(getUnixTimestamp(), address2)).should.be.bignumber.equal('47');
        (await this.cmtat.getNextSnapshots()).length.should.equal(0);
      });
    });
  });
});
