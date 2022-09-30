pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/modules/PauseModule.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "./HelperContract.sol";

import "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
const MinimalForwarderMock = artifacts.require('MinimalForwarderMock');

const NAME = 'MinimalForwarder';
const VERSION = '0.0.1';
const EIP712Domain = [
  { name: 'name', type: 'string' },
  { name: 'version', type: 'string' },
  { name: 'chainId', type: 'uint256' },
  { name: 'verifyingContract', type: 'address' },
];

contract MetaTxModuleOwnerTest {
     bool resBool;
     uint256 privateKeyTest = 1000;
     address constant SENDER = vm.addr(privateKeyTest);
     uint256 resUint256;
     MinimalForwarderMock defaultForwarder;
     
    function setUp() public{
        vm.prank(OWNER);
        CMTAT_CONTRACT_CONTRACT = new CMTAT();
        defaultForwarder = new MinimalForwarderMock();
        CMTAT_CONTRACT_CONTRACT.initialize(OWNER, defaultForwarder, 'CMTA Token', 'CMTAT_CONTRACT', 
        'CMTAT_CONTRACT_ISIN', 'https://cmta.ch');
    }

    //can change the trustedForwarder
    function testCanChangeTrustedForwarder () {
       MinimalForwarderMock trustedForwarder = new MinimalForwarderMock();
      resBool = CMTAT_CONTRACT.isTrustedForwarder(trustedForwarder);
      assertFalse(resBool);
      resBool = CMTAT_CONTRACT.isTrustedForwarder(defaultForwarder);
      assertEq(resBool, true);
      vm.prank(OWNER);
      CMTAT_CONTRACT.setTrustedForwarder(trustedForwarder);
      resBool = CMTAT_CONTRACT.isTrustedForwarder(trustedForwarder);
      assertEq(resBool, true);
      resBool = CMTAT_CONTRACT.isTrustedForwarder(defaultForwarder);
      assertFalse(resBool);
    }

    // reverts when calling from non-owner
    function testCannnotCallByNonOwner () {
      vm.prank(ADDRESS1);
      string memory message = string(abi.encodePacked('AccessControl: account ', 
      vm.toString(ADDRESS1),' is missing role ', DEFAULT_ADMIN_ROLE_HASH));
      vm.expectRevert(bytes(message));
      CMTAT_CONTRACT.setTrustedForwarder(trustedForwarder);
    }
  }

    // Transferring without paying gas
  contract TransferWithoutPayTest () {
    function setUp () {
      forwarder = MinimalForwarderMock.new();
      forwarder.initialize();
      vm.prank(OWNER);
      CMTAT_CONTRACT.setTrustedForwarder(forwarder.address);

      domain = {
        name: NAME,
        version: VERSION,
        chainId: 1,
        verifyingContract: forwarder.address,
      };
      types = {
        EIP712Domain,
        ForwardRequest: [
          { name: 'from', type: 'address' },
          { name: 'to', type: 'address' },
          { name: 'value', type: 'uint256' },
          { name: 'gas', type: 'uint256' },
          { name: 'nonce', type: 'uint256' },
          { name: 'data', type: 'bytes' },
        ],
      };
      data = {
        types: types,
        domain: domain,
        primaryType: 'ForwardRequest',
      };
      vm.prank(OWNER);
      CMTAT_CONTRACT.mint(SENDER, 31);
      vm.prank(OWNER);
      CMTAT_CONTRACT.mint(ADDRESS2, 32);
    }

    // can send a transfer transaction without paying gas
    function () {
      const data = CMTAT_CONTRACT.contract.methods.transfer(ADDRESS2, 11).encodeABI();

      const req = {
        from: sender,
        to: CMTAT_CONTRACT.address,
        value: '0',
        gas: '100000',
        nonce: (forwarder.getNonce(SENDER)).toString(),
        data,
      };

      const sign = vm.sign(privateKeyTest, { data: { ...data, message: req } })
      uint256 balanceBefore = SENDER.balance;
      forwarder.execute(req, sign);
      resUint256 = CMTAT_CONTRACT.balanceOf(SENDER);
      assertEq(resUint256, 20);
      resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS2);
      assertEq(resUint256, 43);
      uint256 balanceAfter = SENDER.balance;
      assertEq( balanceBefore, balanceAfter);
    }
  }
}
