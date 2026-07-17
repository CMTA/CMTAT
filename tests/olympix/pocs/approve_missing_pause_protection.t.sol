const { expect } = require('chai')
const { ethers } = require('hardhat')

const TERMS = [
  'doc1',
  'https://example.com/doc1',
  '0x6a12eff2f559a5e529ca2c563c53194f6463ed5c61d1ae8f8731137467ab0279'
]
const ZERO = ethers.ZeroAddress

/*
 * Vulnerability: approve missing pause protection (CMTATBaseCore / Light approve()).
 * The Light deployment does not gate approve with whenNotPaused, so allowances can be
 * created while the token is paused, unlike the full variants.
 */
describe('PoC: Light approve() is callable while paused', function () {
  it('approve must revert while the contract is paused', async function () {
    const [deployer, admin, holder, spender] = await ethers.getSigners()
    const cmtat = await ethers.deployContract('CMTATStandaloneLight', [admin.address, ['CMTA Token', 'CMTAT', 0]])
    await cmtat.waitForDeployment()
    await cmtat.connect(admin).pause()
    // FIXED: approve reverts while paused. VULNERABLE: it succeeds -> assertion FAILS.
    await expect(cmtat.connect(holder).approve(spender.address, 100n)).to.be.reverted
  })
})
