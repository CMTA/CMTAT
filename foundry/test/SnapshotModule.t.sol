pragma solidity ^0.8.17;
import "openzeppelin-contracts/contracts/utils/Strings.sol";

contract SnapshotSchedulingModuleTest is Test, HelperContract, SnapshotModule {
    

    function setUp() public {
      vm.prank(OWNER);
      CMTAT_CONTRACT = new CMTAT();
      CMTAT_CONTRACT.initialize(OWNER, ZERO_ADDRESS, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch');
    }

    // can schedule a snapshot with the snapshoter role
    function testCanScheduleSnapshotAsSnapshoter () public {
      this.snapshotTime = block.timestamp + 60;

      vm.prank(OWNER);
      vm.expectEmit(true, true, false, false);
      emit SnapshotSchedule(0, this.snapshotTime);
      CMTAT_CONTRACT.scheduleSnapshot(this.snapshotTime);
      uint256[] memory snapshots = CMTAT_CONTRACT.getNextSnapshots();
      assertEq(snapshots.length, 1);
      assertEq(snapshots[0], this.snapshotTime);
    }
    

    // reverts when calling from non-owner
    function testCannotRevertCallByNonOwner () public {
      vm.prank(ADDRESS1);
      string memory message = string(abi.encodePacked('AccessControl: account ', 
      vm.toString(ADDRESS1),' is missing role ', SNAPSHOOTER_ROLE));
      vm.expectRevert(bytes(message));
      CMTAT_CONTRACT.scheduleSnapshot(this.snapshotTime);
    }

    // reverts when trying to schedule a snapshot in the past
    function testCannotSheduleSnapshotInThePast () public {
      vm.prank(OWNER);
      m.expectRevert(bytes('Snapshot scheduled in the past'));
      CMTAT_CONTRACT.scheduleSnapshot(block.timestamp - 60);
    }

    // reverts when trying to schedule a snapshot with the same time twice
    function testCannotScheduleSnaphostSameTime () public {
      vm.prank(OWNER);
      CMTAT_CONTRACT.scheduleSnapshot(this.snapshotTime);
      vm.prank(OWNER);
      m.expectRevert(bytes('Snapshot already scheduled for this time'));
      CMTAT_CONTRACT.scheduleSnapshot(this.snapshotTime);
      uint256[] memory snapshots = CMTAT_CONTRACT.getNextSnapshots();
      assertEq(snapshots.length, 1);
      assertEq(snapshots[0], this.snapshotTime);
    }

  }

contract SnapshotUnSchedulingModuleTest is Test, HelperContract, SnapshotModule {
  uint256 snapshotTime;
    function setUp() public {
      vm.prank(OWNER);
      CMTAT_CONTRACT = new CMTAT();
      CMTAT_CONTRACT.initialize(OWNER, ZERO_ADDRESS, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch');
    
      // Config personal
      snapshotTime = block.timestamp + 60;
      vm.prank(OWNER);
      CMTAT_CONTRACT.scheduleSnapshot(snapshotTime);
    }

    // can unschedule a snapshot with the snapshoter role and emits a SnapshotUnschedule event
    function testUnscheduleSnapshot () public {
      vm.prank(OWNER);
      vm.expectEmit(true, false, false, false);
      emit SnapshotUnschedule(this.snapshotTime);
      CMTAT_CONTRACT.unscheduleSnapshot(this.snapshotTime);
      uint256[] memory snapshots = CMTAT_CONTRACT.getNextSnapshots();
      assertEq(snapshots.length, 0);
    }
  
    // reverts when calling from non-owner
    function testCannotCallByNonOwner() public {
      vm.prank(ADDRESS1);
      string memory message = string(abi.encodePacked('AccessControl: account ', 
      vm.toString(ADDRESS1),' is missing role ', SNAPSHOOTER_ROLE));
      vm.expectRevert(bytes(message));
      CMTAT_CONTRACT.unscheduleSnapshot(this.snapshotTime);
    }

    // reverts when snapshot is not found
    function testCannotSnapshotIsNotFound() public {
      vm.prank(OWNER);
      m.expectRevert(bytes('Snapshot not found'));
      CMTAT_CONTRACT.unscheduleSnapshot(block.timestamp + 90);
    }

    // reverts when snapshot has been processed
    function testCannotUnscheduleProcessedSnapshot () public {
      vm.prank(OWNER);
      m.expectRevert(bytes('Snapshot already done'));
      CMTAT_CONTRACT.unscheduleSnapshot(block.timestamp - 60);
    }
  }
  
  // Snapshot rescheduling
  contract SnapshotReschedulingModuleTest is Test, HelperContract, SnapshotModule {
    function setUp() public {
      vm.prank(OWNER);
      CMTAT_CONTRACT = new CMTAT();
      CMTAT_CONTRACT.initialize(OWNER, ZERO_ADDRESS, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch');
    
      // Config personal
      this.snapshotTime = block.timestamp + 60;
      this.newSnapshotTime = block.timestamp + 90;
      vm.prank(OWNER);
      CMTAT_CONTRACT.scheduleSnapshot(this.snapshotTime);
    }

    // can reschedule a snapshot with the snapshoter role and emits a SnapshotSchedule event
    function testRescheduleSnapshot () public {
      vm.prank(OWNER);
      vm.expectEmit(true, true, false, false);
      emit SnapshotSchedule(this.snapshotTime, this.newSnapshotTime);
      CMTAT_CONTRACT.rescheduleSnapshot(this.snapshotTime, this.newSnapshotTime);
      uint256[] memory snapshots = CMTAT_CONTRACT.getNextSnapshots();
      assertEq(snapshots.length, 1);
      assertEq(snapshots[0], this.newSnapshotTime);
    }

    // reverts when calling from non-owner
    function testCannotRescheduleByNonOwner () public {
      string memory message = string(abi.encodePacked('AccessControl: account ', 
      vm.toString(ADDRESS1),' is missing role ', SNAPSHOOTER_ROLE));
      vm.expectRevert(bytes(message));
      vm.prank(ADDRESS1);
      CMTAT_CONTRACT.rescheduleSnapshot(this.snapshotTime, this.newSnapshotTime);
    }

    // reverts when trying to reschedule a snapshot in the past
    function testCannotRescheduleSchapshotInThePast () public {
      vm.prank(OWNER);
      m.expectRevert(bytes('Snapshot scheduled in the past'));
      expectRevert(CMTAT_CONTRACT.rescheduleSnapshot(this.snapshotTime, block.timestamp - 60));
    }

    // reverts when trying to schedule a snapshot with the same time twice
    function testCannotRescheduleSameTimeTwice () public {
      vm.prank(OWNER);
      CMTAT_CONTRACT.rescheduleSnapshot(this.snapshotTime, this.newSnapshotTime);
      vm.prank(OWNER);
      m.expectRevert(bytes('Snapshot already scheduled for this time'));
      CMTAT_CONTRACT.rescheduleSnapshot(this.snapshotTime, this.newSnapshotTime);
      uint256[] memory snapshots = CMTAT_CONTRACT.getNextSnapshots();
      assertEq(snapshots.length, 1);
      assertEq(snapshots[0], this.newSnapshotTime);
    }

    // reverts when snapshot is not found
    function testCannotRescheduleNotFoundSnapshot () public {
      vm.prank(OWNER);
      m.expectRevert(bytes('Snapshot not found'));
      CMTAT_CONTRACT.rescheduleSnapshot(block.timestamp + 90, this.newSnapshotTime);
    }

    // reverts when snapshot has been processed
    function testCannotReschuleProcessedSnapshot() public {
      vm.prank(OWNER);
      m.expectRevert(bytes('Snapshot already done'));
      expectRevert(CMTAT_CONTRACT.rescheduleSnapshot(block.timestamp - 60,this.newSnapshotTime), '');
    }
  }

  // Snapshoting
  contract SnapshotingModuleConfig is HelperContract, SnapshotModule {
    function config() public {
      vm.prank(OWNER);
      CMTAT_CONTRACT = new CMTAT();
      CMTAT_CONTRACT.initialize(OWNER, ZERO_ADDRESS, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch');
    
      // Config personal
      vm.prank(OWNER);
      CMTAT_CONTRACT.mint(ADDRESS, 31);
      vm.prank(OWNER);
      CMTAT_CONTRACT.mint(ADDRESS2, 32);
      vm.prank(OWNER);
      CMTAT_CONTRACT.mint(address3, 33);
    }
  }
  contract BeforeAnySnaphotTest is config, Test {
      SnapshotingModuleConfig = new SnapshotingModuleConfig();
      function setUp() public {
        SnapshotingModuleConfig.config()
      }
    // context : Before any snapshot'
      // can get the total supply
    function canGetTotalSupply () public {
        uint256 res1 = CMTAT_CONTRACT.snapshotTotalSupply(block.timestamp);
        assertEq(res1, 96);
    }

      // can get the balance of an address
      function () public {
        uint256 res1 = CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS1);
        assertEq(res1, 31);
    }

    context('With one planned snapshot', function () {
      beforeEach(async function () {
        this.snapshotTime = block.timestamp + 1;
        this.beforeSnapshotTime = block.timestamp - 60
        vm.prank(OWNER);
        await CMTAT_CONTRACT.scheduleSnapshot(this.snapshotTime);
        // await timeout(3000);
      }

      // can mint tokens
      function () public {
        (await CMTAT_CONTRACT.snapshotTotalSupply(block.timestamp)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS1)).should.be.bignumber.equal('31');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS2)).should.be.bignumber.equal('32');
        vm.prank(OWNER);
        await CMTAT_CONTRACT.mint(ADDRESS1, 20);
        (await CMTAT_CONTRACT.snapshotTotalSupply(this.beforeSnapshotTime)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.beforeSnapshotTime, ADDRESS1)).should.be.bignumber.equal('31');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.beforeSnapshotTime, ADDRESS2)).should.be.bignumber.equal('32');
        (await CMTAT_CONTRACT.snapshotTotalSupply(block.timestamp)).should.be.bignumber.equal('116');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS1)).should.be.bignumber.equal('51');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS2)).should.be.bignumber.equal('32');
        uint256[] memory snapshots = CMTAT_CONTRACT.getNextSnapshots();
        assertEq(snapshots.length, 0);
      }

      // can burn tokens
      function () public {
        vm.prank(ADDRESS1);
        await CMTAT_CONTRACT.approve(owner, 50);
        (await CMTAT_CONTRACT.snapshotTotalSupply(block.timestamp)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS1)).should.be.bignumber.equal('31');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS2)).should.be.bignumber.equal('32');
        vm.prank(OWNER);
        await CMTAT_CONTRACT.burnFrom(ADDRESS1, 20);
        (await CMTAT_CONTRACT.snapshotTotalSupply(this.beforeSnapshotTime)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.beforeSnapshotTime, ADDRESS1)).should.be.bignumber.equal('31');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.beforeSnapshotTime, ADDRESS2)).should.be.bignumber.equal('32');
        (await CMTAT_CONTRACT.snapshotTotalSupply(block.timestamp)).should.be.bignumber.equal('76');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS1)).should.be.bignumber.equal('11');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS2)).should.be.bignumber.equal('32');
        uint256[] memory snapshots = CMTAT_CONTRACT.getNextSnapshots();
        assertEq(snapshots.length, 0);
      }

      // can transfer tokens
      function () public {
        (await CMTAT_CONTRACT.snapshotTotalSupply(block.timestamp)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS1)).should.be.bignumber.equal('31');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS2)).should.be.bignumber.equal('32');
        vm.prank(ADDRESS1);
        await CMTAT_CONTRACT.transfer(ADDRESS2, 20);
        (await CMTAT_CONTRACT.snapshotTotalSupply(this.beforeSnapshotTime)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.beforeSnapshotTime, ADDRESS1)).should.be.bignumber.equal('31');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.beforeSnapshotTime, ADDRESS2)).should.be.bignumber.equal('32');
        (await CMTAT_CONTRACT.snapshotTotalSupply(block.timestamp)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS1)).should.be.bignumber.equal('11');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS2)).should.be.bignumber.equal('52');
        uint256[] memory snapshots = CMTAT_CONTRACT.getNextSnapshots();
        assertEq(snapshots.length, 0);
      }
    }

    context('With multiple planned snapshot', function () {
      beforeEach(async function () {
        this.snapshotTime1 = block.timestamp + 1;
        this.snapshotTime2 = block.timestamp + 6;
        this.snapshotTime3 = block.timestamp + 11;
        this.beforeSnapshotTime = block.timestamp - 60
        vm.prank(OWNER);
        await CMTAT_CONTRACT.scheduleSnapshot(this.snapshotTime1);
        vm.prank(OWNER);
        await CMTAT_CONTRACT.scheduleSnapshot(this.snapshotTime2);
        vm.prank(OWNER);
        await CMTAT_CONTRACT.scheduleSnapshot(this.snapshotTime3);
        // await timeout(3000);
      }

      // can transfer tokens after first snapshot
      function () public {
        (await CMTAT_CONTRACT.snapshotTotalSupply(block.timestamp)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS1)).should.be.bignumber.equal('31');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS2)).should.be.bignumber.equal('32');
        vm.prank(ADDRESS1);
        await CMTAT_CONTRACT.transfer(ADDRESS2, 20);
        (await CMTAT_CONTRACT.snapshotTotalSupply(this.beforeSnapshotTime)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.beforeSnapshotTime, ADDRESS1)).should.be.bignumber.equal('31');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.beforeSnapshotTime, ADDRESS2)).should.be.bignumber.equal('32');
        (await CMTAT_CONTRACT.snapshotTotalSupply(block.timestamp)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS1)).should.be.bignumber.equal('11');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS2)).should.be.bignumber.equal('52');
        uint256[] memory snapshots = CMTAT_CONTRACT.getNextSnapshots();
        assertEq(snapshots.length, 2);
      }

      // can transfer tokens after second snapshot
      function () public {
        // await timeout(5000);
        (await CMTAT_CONTRACT.snapshotTotalSupply(block.timestamp)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS1)).should.be.bignumber.equal('31');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS2)).should.be.bignumber.equal('32');
        vm.prank(ADDRESS1);
        await CMTAT_CONTRACT.transfer(ADDRESS2, 20);
        (await CMTAT_CONTRACT.snapshotTotalSupply(this.snapshotTime1)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.snapshotTime1, ADDRESS1)).should.be.bignumber.equal('31');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.snapshotTime1, ADDRESS2)).should.be.bignumber.equal('32');
        (await CMTAT_CONTRACT.snapshotTotalSupply(block.timestamp)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS1)).should.be.bignumber.equal('11');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS2)).should.be.bignumber.equal('52');
        uint256[] memory snapshots = CMTAT_CONTRACT.getNextSnapshots();
        assertEq(snapshots.length, 1);
      }

      // can transfer tokens after third snapshot
      function () public {
        // await timeout(10000);
        (await CMTAT_CONTRACT.snapshotTotalSupply(block.timestamp)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS1)).should.be.bignumber.equal('31');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS2)).should.be.bignumber.equal('32');
        vm.prank(ADDRESS1);
        await CMTAT_CONTRACT.transfer(ADDRESS2, 20);
        (await CMTAT_CONTRACT.snapshotTotalSupply(this.snapshotTime1)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.snapshotTime1, ADDRESS1)).should.be.bignumber.equal('31');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.snapshotTime1, ADDRESS2)).should.be.bignumber.equal('32');
        (await CMTAT_CONTRACT.snapshotTotalSupply(block.timestamp)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS1)).should.be.bignumber.equal('11');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS2)).should.be.bignumber.equal('52');
        uint256[] memory snapshots = CMTAT_CONTRACT.getNextSnapshots();
        assertEq(snapshots.length, 0);
      }

      // can transfer tokens multiple times between snapshots
      function () public {
        (await CMTAT_CONTRACT.snapshotTotalSupply(block.timestamp)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS1)).should.be.bignumber.equal('31');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS2)).should.be.bignumber.equal('32');
        vm.prank(ADDRESS1);
        await CMTAT_CONTRACT.transfer(ADDRESS2, 20);
        (await CMTAT_CONTRACT.snapshotTotalSupply(this.beforeSnapshotTime)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.beforeSnapshotTime, ADDRESS1)).should.be.bignumber.equal('31');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.beforeSnapshotTime, ADDRESS2)).should.be.bignumber.equal('32');
        (await CMTAT_CONTRACT.snapshotTotalSupply(block.timestamp)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS1)).should.be.bignumber.equal('11');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS2)).should.be.bignumber.equal('52');
        uint256[] memory res = CMTAT_CONTRACT.getNextSnapshots();
        assertEq(snapshots.length, 2);
        // await timeout(5000);
        await CMTAT_CONTRACT.transfer(ADDRESS1, 10, {from: ADDRESS2});
        (await CMTAT_CONTRACT.snapshotTotalSupply(this.beforeSnapshotTime)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.beforeSnapshotTime, ADDRESS1)).should.be.bignumber.equal('31');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.beforeSnapshotTime, ADDRESS2)).should.be.bignumber.equal('32');
        (await CMTAT_CONTRACT.snapshotTotalSupply(this.snapshotTime1)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.snapshotTime1, ADDRESS1)).should.be.bignumber.equal('31');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.snapshotTime1, ADDRESS2)).should.be.bignumber.equal('32');
        (await CMTAT_CONTRACT.snapshotTotalSupply(this.snapshotTime2)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.snapshotTime2, ADDRESS1)).should.be.bignumber.equal('11');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.snapshotTime2, ADDRESS2)).should.be.bignumber.equal('52');
        (await CMTAT_CONTRACT.snapshotTotalSupply(block.timestamp)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS1)).should.be.bignumber.equal('21');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS2)).should.be.bignumber.equal('42');
        uint256[] memory res = CMTAT_CONTRACT.getNextSnapshots();
        assertEq(snapshots.length, 1);
        // await timeout(5000);
        vm.prank(ADDRESS1);
        await CMTAT_CONTRACT.transfer(ADDRESS2, 5);
        (await CMTAT_CONTRACT.snapshotTotalSupply(this.beforeSnapshotTime)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.beforeSnapshotTime, ADDRESS1)).should.be.bignumber.equal('31');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.beforeSnapshotTime, ADDRESS2)).should.be.bignumber.equal('32');
        (await CMTAT_CONTRACT.snapshotTotalSupply(this.snapshotTime1)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.snapshotTime1, ADDRESS1)).should.be.bignumber.equal('31');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.snapshotTime1, ADDRESS2)).should.be.bignumber.equal('32');
        (await CMTAT_CONTRACT.snapshotTotalSupply(this.snapshotTime2)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.snapshotTime2, ADDRESS1)).should.be.bignumber.equal('11');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.snapshotTime2, ADDRESS2)).should.be.bignumber.equal('52');
        (await CMTAT_CONTRACT.snapshotTotalSupply(this.snapshotTime3)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.snapshotTime3, ADDRESS1)).should.be.bignumber.equal('21');
        (await CMTAT_CONTRACT.snapshotBalanceOf(this.snapshotTime3, ADDRESS2)).should.be.bignumber.equal('42');
        (await CMTAT_CONTRACT.snapshotTotalSupply(block.timestamp)).should.be.bignumber.equal('96');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS1)).should.be.bignumber.equal('16');
        (await CMTAT_CONTRACT.snapshotBalanceOf(block.timestamp, ADDRESS2)).should.be.bignumber.equal('47');
        uint256[] memory res = CMTAT_CONTRACT.getNextSnapshots();
        assertEq(snapshots.length, 0);
      }
    }
  }
}
