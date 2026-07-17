const { expect } = require('chai')
const { ethers } = require('hardhat')

const TERMS = [
  'doc1',
  'https://example.com/doc1',
  '0x6a12eff2f559a5e529ca2c563c53194f6463ed5c61d1ae8f8731137467ab0279'
]
const ZERO = ethers.ZeroAddress

/*
 * Vulnerability: overfrozen balance accounting corruption (ERC20EnforcementModule.setFrozenTokens).
 * setFrozenTokens writes the ABSOLUTE frozen amount without the `value <= balanceOf(account)`
 * cap that _freezePartialTokens enforces, so getActiveBalanceOf underflows (Panic 0x11).
 */
describe('PoC: setFrozenTokens above balance corrupts active-balance accounting', function () {
  it('a frozen amount greater than the balance must not brick getActiveBalanceOf', async function () {
    const [deployer, admin, forwarder, holder] = await ethers.getSigners()
    const cmtat = await ethers.deployContract('CMTATStandalone', [
      forwarder.address, admin.address, ['CMTA Token', 'CMTAT', 0], ['CMTAT_ISIN', TERMS, 'CMTAT_info'], [ZERO]
    ])
    await cmtat.waitForDeployment()
    await cmtat.connect(admin).mint(holder.address, 50n)
    await cmtat.connect(admin).setFrozenTokens(holder.address, 100n)
    // FIXED: getActiveBalanceOf returns a bounded value. VULNERABLE: 50-100 underflows -> assertion FAILS.
    await expect(cmtat.getActiveBalanceOf(holder.address)).to.not.be.reverted
  })
})
