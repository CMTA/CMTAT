const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('FixDescriptorEngineModule', function () {
  let owner;
  let other;
  let harness;
  let engine;

  beforeEach(async function () {
    [owner, other] = await ethers.getSigners();

    const Harness = await ethers.getContractFactory('FixDescriptorEngineModuleHarness');
    harness = await Harness.deploy();
    await harness.waitForDeployment();

    const EngineMock = await ethers.getContractFactory('FixDescriptorEngineMock');
    engine = await EngineMock.deploy();
    await engine.waitForDeployment();

    await harness.initialize(owner.address, ethers.ZeroAddress);
  });

  it('initializes with no engine configured', async function () {
    expect(await harness.fixDescriptorEngine()).to.equal(ethers.ZeroAddress);
  });

  it('stores the engine address and emits an event', async function () {
    const descriptor = {
      fixMajor: 5,
      fixMinor: 0,
      dictHash: ethers.ZeroHash,
      dictionaryContract: owner.address,
      fixRoot: ethers.ZeroHash,
      fixCBORPtr: ethers.ZeroAddress,
      fixCBORLen: 0,
      fixURI: 'ipfs://fixture/minimal'
    };
    await engine.setFixDescriptor(descriptor, '0x');

    await expect(harness.setFixDescriptorEngine(await engine.getAddress()))
      .to.emit(harness, 'FixDescriptorEngine')
      .withArgs(await engine.getAddress());

    expect(await harness.fixDescriptorEngine()).to.equal(await engine.getAddress());
  });

  it('allows reading descriptor data directly from the engine', async function () {
    const cborData = ethers.toUtf8Bytes('mock-cbor-data');
    const descriptor = {
      fixMajor: 5,
      fixMinor: 0,
      dictHash: ethers.keccak256(cborData),
      dictionaryContract: owner.address,
      fixRoot: ethers.keccak256(ethers.toUtf8Bytes('root')),
      fixCBORPtr: ethers.ZeroAddress,
      fixCBORLen: cborData.length,
      fixURI: 'ipfs://fixture/fix.json'
    };
    await engine.setFixDescriptor(descriptor, cborData);
    await harness.setFixDescriptorEngine(await engine.getAddress());

    const forwarded = await engine.getFixDescriptor();
    expect(forwarded.fixMajor).to.equal(5);
    expect(forwarded.fixMinor).to.equal(0);
    expect(forwarded.fixURI).to.equal('ipfs://fixture/fix.json');
  });

  it('allows clearing the engine back to address(0)', async function () {
    await harness.setFixDescriptorEngine(await engine.getAddress());
    await harness.setFixDescriptorEngine(ethers.ZeroAddress);

    expect(await harness.fixDescriptorEngine()).to.equal(ethers.ZeroAddress);
  });

  it('enforces FIX_DESCRIPTOR_ROLE for updates', async function () {
    await expect(
      harness.connect(other).setFixDescriptorEngine(await engine.getAddress())
    ).to.be.revertedWithCustomError(harness, 'AccessControlUnauthorizedAccount');

    await harness.grantFixRole(other.address);
    await expect(harness.connect(other).setFixDescriptorEngine(await engine.getAddress()))
      .to.emit(harness, 'FixDescriptorEngine')
      .withArgs(await engine.getAddress());
  });

  it('reverts when setting the same engine twice', async function () {
    await harness.setFixDescriptorEngine(await engine.getAddress());

    await expect(
      harness.setFixDescriptorEngine(await engine.getAddress())
    ).to.be.revertedWithCustomError(harness, 'CMTAT_FixDescriptorEngineModule_SameValue');
  });
});

