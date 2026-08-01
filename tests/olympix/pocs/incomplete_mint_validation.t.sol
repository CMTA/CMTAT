const { expect } = require('chai')
const { ethers } = require('hardhat')

const TERMS = [
  'doc1',
  'https://example.com/doc1',
  '0x6a12eff2f559a5e529ca2c563c53194f6463ed5c61d1ae8f8731137467ab0279'
]
const ZERO = ethers.ZeroAddress

/*
 * Vulnerability: incomplete mint validation via base _checkTransferred (CMTATBaseCommon._mintOverride).
 * Mint validation runs _checkTransferred(address(0), address(0), to, value); over-freezing the
 * address(0) sentinel makes the active-balance check underflow and bricks every mint path.
 */
describe('PoC: freezing address(0) bricks minting through base validation', function () {
  it('mint must still succeed when a benign frozen amount is set on address(0)', async function () {
    const [deployer, admin, forwarder, holder] = await ethers.getSigners()
    const cmtat = await ethers.deployContract('CMTATStandalone', [
      forwarder.address, admin.address, ['CMTA Token', 'CMTAT', 0], ['CMTAT_ISIN', TERMS, 'CMTAT_info'], [ZERO]
    ])
    await cmtat.waitForDeployment()
    await cmtat.connect(admin).setFrozenTokens(ZERO, 1n)
    // FIXED: mint succeeds (sentinel ignored). VULNERABLE: mint reverts -> assertion FAILS.
    await expect(cmtat.connect(admin).mint(holder.address, 10n)).to.not.be.reverted
  })
})
