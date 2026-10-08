const { expect } = require('chai')
const { ethers } = require('hardhat')
const { ZERO_ADDRESS } = require('../../utils')
const { fixture, loadFixture, TERMS } = require('../../deploymentUtils')
const CMTAT_V320 = require('./fixtures/v3.2.0/CMTATUpgradeable.json')
const DOCUMENT_ENGINE_V320 = require('./fixtures/v3.2.0/DocumentEngineMock.json')
const TRANSPARENT_PROXY = require('@openzeppelin/contracts/build/contracts/TransparentUpgradeableProxy.json')
const PROXY_ADMIN = require('@openzeppelin/contracts/build/contracts/ProxyAdmin.json')

/*
 * Upgrade of a real CMTAT v3.2.0 proxy to v3.3.0.
 *
 * The v3.2.0 implementation is the bytecode compiled from the v3.2.0 tag with its own locked
 * dependencies (fixtures/v3.2.0). These tests check the storage-related breaking changes listed in
 * doc/technical/breaking-changes.md and the migration procedure it describes:
 * - S1: `name` / `symbol` moved to `CMTAT.storage.TokenAttributeModule`;
 * - S2: documents are stored in the token instead of an external DocumentEngine;
 * - S3: the Standard variant no longer calls the SnapshotEngine; the Snapshot variant does.
 */

// keccak256(abi.encode(uint256(keccak256("CMTAT.storage.ERC20BaseModule")) - 1)) & ~bytes32(uint256(0xff))
const ERC20_BASE_MODULE_SLOT =
  0x9bd8d607565c0370ae5f91651ca67fd26d4438022bf72037316600e29e6a3a00n
// ERC-1967 admin slot: bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1)
const ERC1967_ADMIN_SLOT =
  '0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103'

const NAME = 'CMTA Token'
const SYMBOL = 'CMTAT'
const DECIMALS = 6n
const TOKEN_ID = 'CMTAT_ISIN'
const INFORMATION = 'CMTAT_info'
const BALANCE = 1000n
const FROZEN_TOKENS = 100n
const AMOUNT = 10n
const DOCUMENT_V320 = [
  'prospectus',
  'https://example.com/prospectus',
  '0x6a12eff2f559a5e529ca2c563c53194f6463ed5c61d1ae8f8731137467ab0279'
]

describe('Upgrade from v3.2.0 to v3.3.0 - Proxy', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))

    // v3.2.0 implementation behind a Transparent proxy owned by `admin`
    const implV320 = await new ethers.ContractFactory(
      CMTAT_V320.abi,
      CMTAT_V320.bytecode,
      this.deployerAddress
    ).deploy(this._.address)
    const initData = implV320.interface.encodeFunctionData('initialize', [
      this.admin.address,
      [NAME, SYMBOL, DECIMALS],
      [TOKEN_ID, TERMS, INFORMATION],
      [ZERO_ADDRESS]
    ])
    const proxy = await new ethers.ContractFactory(
      TRANSPARENT_PROXY.abi,
      TRANSPARENT_PROXY.bytecode,
      this.deployerAddress
    ).deploy(implV320.target, this.admin.address, initData)
    this.proxyAddress = proxy.target
    this.cmtatV320 = new ethers.Contract(
      this.proxyAddress,
      CMTAT_V320.abi,
      this.admin
    )
    const adminSlot = await ethers.provider.getStorage(
      this.proxyAddress,
      ERC1967_ADMIN_SLOT
    )
    this.proxyAdmin = new ethers.Contract(
      ethers.getAddress('0x' + adminSlot.slice(26)),
      PROXY_ADMIN.abi,
      this.admin
    )

    // v3.2.0 state: balances, partial freeze, address freeze, a RuleEngine, a SnapshotEngine
    // and a DocumentEngine holding one document
    await this.cmtatV320['mint(address,uint256)'](this.address1, BALANCE)
    await this.cmtatV320['freezePartialTokens(address,uint256)'](
      this.address1,
      FROZEN_TOKENS
    )
    await this.cmtatV320['setAddressFrozen(address,bool)'](this.address3, true)
    this.ruleEngine = await ethers.deployContract('RuleEngineMock', [
      this.admin
    ])
    await this.cmtatV320.setRuleEngine(this.ruleEngine.target)
    this.snapshotEngine = await ethers.deployContract(
      'SnapshotEngineRecorderMock'
    )
    await this.cmtatV320.setSnapshotEngine(this.snapshotEngine.target)
    this.documentEngine = await new ethers.ContractFactory(
      DOCUMENT_ENGINE_V320.abi,
      DOCUMENT_ENGINE_V320.bytecode,
      this.admin
    ).deploy()
    await this.documentEngine.setDocument(DOCUMENT_V320)
    await this.cmtatV320.setDocumentEngine(this.documentEngine.target)
  })

  async function upgradeTo (ctx, contractName, migrate) {
    const impl = await ethers.deployContract(contractName, [ctx._.address], {
      signer: ctx.deployerAddress
    })
    const data = migrate
      ? impl.interface.encodeFunctionData('migrateFromV32')
      : '0x'
    await ctx.proxyAdmin.upgradeAndCall(ctx.proxyAddress, impl.target, data)
    // Connect as admin: the first signer is the trusted ERC-2771 forwarder in these tests
    return ethers.getContractAt(contractName, ctx.proxyAddress, ctx.admin)
  }

  it('testV320FixtureHasExpectedState', async function () {
    expect(await this.cmtatV320.version()).to.equal('3.2.0')
    expect(await this.cmtatV320.name()).to.equal(NAME)
    expect(await this.cmtatV320.getAllDocuments()).to.deep.equal([
      DOCUMENT_V320[0]
    ])
    // The v3.2.0 Standard variant calls its SnapshotEngine on every balance change
    await this.cmtatV320.connect(this.address1).transfer(this.address2, AMOUNT)
    expect(await this.snapshotEngine.callCount()).to.equal(1n)
  })

  context('S1 - name / symbol', function () {
    it('testPlainUpgradeLeavesNameAndSymbolEmpty', async function () {
      const cmtat = await upgradeTo(this, 'CMTATStandardUpgradeable', false)

      expect(await cmtat.version()).to.equal('3.3.0')
      expect(await cmtat.name()).to.equal('')
      expect(await cmtat.symbol()).to.equal('')
      // decimals did not move
      expect(await cmtat.decimals()).to.equal(DECIMALS)
    })

    it('testMigrationRestoresNameAndSymbolAndClearsLegacySlots', async function () {
      const cmtat = await upgradeTo(
        this,
        'CMTATStandardUpgradeableV33MigrationMock',
        true
      )

      expect(await cmtat.name()).to.equal(NAME)
      expect(await cmtat.symbol()).to.equal(SYMBOL)
      expect(await cmtat.decimals()).to.equal(DECIMALS)
      // v3.2.0 `_name` / `_symbol` slots (ERC20BaseModule + 1 / + 2) are cleared
      for (const offset of [1n, 2n]) {
        expect(
          await ethers.provider.getStorage(
            this.proxyAddress,
            ERC20_BASE_MODULE_SLOT + offset
          )
        ).to.equal(ethers.ZeroHash)
      }
    })

    it('testMigrationCannotRunTwice', async function () {
      const cmtat = await upgradeTo(
        this,
        'CMTATStandardUpgradeableV33MigrationMock',
        true
      )
      await expect(
        cmtat.connect(this.attacker).migrateFromV32()
      ).to.be.revertedWithCustomError(cmtat, 'InvalidInitialization')
    })

    it('testUnchangedStateIsPreservedAcrossTheUpgrade', async function () {
      const cmtat = await upgradeTo(
        this,
        'CMTATStandardUpgradeableV33MigrationMock',
        true
      )

      // Balances, supply and enforcement
      expect(await cmtat.balanceOf(this.address1)).to.equal(BALANCE)
      expect(await cmtat.totalSupply()).to.equal(BALANCE)
      expect(await cmtat.getFrozenTokens(this.address1)).to.equal(
        FROZEN_TOKENS
      )
      expect(await cmtat.isFrozen(this.address3)).to.equal(true)
      // Access control and RuleEngine
      expect(
        await cmtat.hasRole(await cmtat.DEFAULT_ADMIN_ROLE(), this.admin)
      ).to.equal(true)
      expect(await cmtat.ruleEngine()).to.equal(this.ruleEngine.target)
      // Extra information
      expect(await cmtat.tokenId()).to.equal(TOKEN_ID)
      expect(await cmtat.information()).to.equal(INFORMATION)
      const terms = await cmtat.terms()
      expect(terms.name).to.equal(TERMS[0])
      expect(terms.doc.uri).to.equal(TERMS[1])
      expect(terms.doc.documentHash).to.equal(TERMS[2])
      // The token is still operational
      await cmtat.connect(this.address1).transfer(this.address2, AMOUNT)
      expect(await cmtat.balanceOf(this.address2)).to.equal(AMOUNT)
    })
  })

  context('S2 - documents', function () {
    it('testDocumentsOfTheV320DocumentEngineAreNoLongerReturned', async function () {
      const cmtat = await upgradeTo(
        this,
        'CMTATStandardUpgradeableV33MigrationMock',
        true
      )

      // The token reads its own (empty) document storage, not the old engine
      expect(await cmtat.getAllDocuments()).to.deep.equal([])
      expect(cmtat.interface.getFunction('documentEngine')).to.equal(null)
      expect(cmtat.interface.getFunction('setDocumentEngine')).to.equal(null)

      // Documents must be registered again on the token (bytes32 names)
      const name = ethers.encodeBytes32String(DOCUMENT_V320[0])
      await cmtat.setDocument(name, DOCUMENT_V320[1], DOCUMENT_V320[2])
      expect(await cmtat.getAllDocuments()).to.deep.equal([name])
      const [uri, documentHash] = await cmtat.getDocument(name)
      expect(uri).to.equal(DOCUMENT_V320[1])
      expect(documentHash).to.equal(DOCUMENT_V320[2])
    })
  })

  context('S3 - SnapshotEngine', function () {
    it('testStandardV330NoLongerCallsTheSnapshotEngine', async function () {
      const cmtat = await upgradeTo(
        this,
        'CMTATStandardUpgradeableV33MigrationMock',
        true
      )
      const callsBefore = await this.snapshotEngine.callCount()

      await cmtat.connect(this.address1).transfer(this.address2, AMOUNT)

      // Nothing reverts, but the engine silently stops receiving transfers
      expect(await this.snapshotEngine.callCount()).to.equal(callsBefore)
      expect(cmtat.interface.getFunction('snapshotEngine')).to.equal(null)
    })

    it('testSnapshotVariantKeepsTheSnapshotEngine', async function () {
      const cmtat = await upgradeTo(
        this,
        'CMTATUpgradeableSnapshotV33MigrationMock',
        true
      )
      const callsBefore = await this.snapshotEngine.callCount()

      // The engine address is read from the unchanged CMTAT.storage.SnapshotEngineModule
      expect(await cmtat.snapshotEngine()).to.equal(this.snapshotEngine.target)
      await cmtat.connect(this.address1).transfer(this.address2, AMOUNT)
      expect(await this.snapshotEngine.callCount()).to.equal(callsBefore + 1n)
      expect(await cmtat.name()).to.equal(NAME)
    })
  })
})
