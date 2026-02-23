const { expect } = require('chai')
const { SNAPSHOOTER_ROLE, ZERO_ADDRESS } = require('../../utils.js')
const { ethers, upgrades } = require('hardhat')

// hash = keccak256("doc1Hash");
const TERMS = [
  'doc1',
  'https://example.com/doc1',
  '0x6a12eff2f559a5e529ca2c563c53194f6463ed5c61d1ae8f8731137467ab0279'
]

function SnapshotModuleSetSnapshotEngineCommon () {
  context('SnapshotEngineInitializerTest', function () {
    it('testCanInitializeWithSnapshotEngine', async function () {
      // Deploy a snapshot engine mock
      const snapshotEngineMock = await ethers.deployContract(
        'SnapshotEngineMock',
        [ZERO_ADDRESS, this.admin]
      )

      // Deploy CMTATEngineInitializerMock via proxy
      const ETHERS_CMTAT_PROXY_FACTORY = await ethers.getContractFactory(
        'CMTATEngineInitializerMock'
      )
      const engineMock = await upgrades.deployProxy(
        ETHERS_CMTAT_PROXY_FACTORY,
        [
          this.admin.address,
          ['CMTA Token', 'CMTAT', 0],
          ['CMTAT_ISIN', TERMS, 'CMTAT_info'],
          [ZERO_ADDRESS]
        ],
        {
          initializer: 'initialize',
          constructorArgs: [ZERO_ADDRESS],
          from: this.deployerAddress.address,
          unsafeAllow: ['missing-initializer']
        }
      )

      // Call initializeWithEngines to cover __SnapshotEngineModule_init_unchained
      await engineMock
        .connect(this.admin)
        .initializeWithEngines(
          snapshotEngineMock.target,
          ZERO_ADDRESS // No document engine
        )

      // Verify snapshot engine was set
      expect(await engineMock.snapshotEngine()).to.equal(
        snapshotEngineMock.target
      )
    })
  })

  context('SnapshotEngineSetTest', function () {
    it('testCanBeSetByAdmin', async function () {
      this.transferEngineMock = await ethers.deployContract(
        'SnapshotEngineMock',
        [ZERO_ADDRESS, this.admin]
      )
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .setSnapshotEngine(this.transferEngineMock.target)
      // Assert
      // emits a SnapshotEngineSet event
      await expect(this.logs)
        .to.emit(this.cmtat, 'SnapshotEngine')
        .withArgs(this.transferEngineMock.target)
    })

    it('testCannotBeSetByAdminWithTheSameValue', async function () {
      const snapshotEngineCurrent = await this.cmtat.snapshotEngine()
      // Act
      await expect(
        this.cmtat.connect(this.admin).setSnapshotEngine(snapshotEngineCurrent)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_SnapshotModule_SameValue'
      )
    })

    it('testCannotBeSetByNonAdmin', async function () {
      // Act
      await expect(
        this.cmtat
          .connect(this.address1)
          .setSnapshotEngine(this.transferEngineMock.target)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, SNAPSHOOTER_ROLE)
    })
  })
}
module.exports = SnapshotModuleSetSnapshotEngineCommon
