const { expect } = require('chai')
const { ethers } = require('hardhat')

const TERMS = [
  'doc1',
  'https://example.com/doc1',
  '0x6a12eff2f559a5e529ca2c563c53194f6463ed5c61d1ae8f8731137467ab0279'
]
const ZERO = ethers.ZeroAddress

/*
 * Vulnerability: inconsistent compliance view (ValidationModule._canTransferGenericByModule).
 * A zero-to-zero request is classified as a mint and can return true even though it is not a
 * valid transfer, so canTransfer reports an impossible movement as compliant.
 */
describe('PoC: canTransfer reports a zero-to-zero movement as valid', function () {
  it('canTransfer(address(0), address(0), 1) must be false', async function () {
    const [deployer, admin, forwarder] = await ethers.getSigners()
    const cmtat = await ethers.deployContract('CMTATStandalone', [
      forwarder.address, admin.address, ['CMTA Token', 'CMTAT', 0], ['CMTAT_ISIN', TERMS, 'CMTAT_info'], [ZERO]
    ])
    await cmtat.waitForDeployment()
    // FIXED: false. VULNERABLE: true -> assertion FAILS.
    expect(await cmtat.canTransfer(ZERO, ZERO, 1n)).to.equal(false)
  })
})
