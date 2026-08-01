const { expect } = require('chai')
const { ethers } = require('hardhat')

const TERMS = [
  'doc1',
  'https://example.com/doc1',
  '0x6a12eff2f559a5e529ca2c563c53194f6463ed5c61d1ae8f8731137467ab0279'
]
const ZERO = ethers.ZeroAddress

/*
 * Vulnerability: zero-address transfer validation mismatch (ValidationModuleCore.canTransfer).
 * canTransfer does not reject zero-address endpoints; a zero `from` is treated as a mint and
 * can return true for an impossible ERC-20 transfer.
 */
describe('PoC: canTransfer reports a zero-from transfer as valid', function () {
  it('canTransfer(address(0), holder, 1) must be false', async function () {
    const [deployer, admin, forwarder, holder] = await ethers.getSigners()
    const cmtat = await ethers.deployContract('CMTATStandalone', [
      forwarder.address, admin.address, ['CMTA Token', 'CMTAT', 0], ['CMTAT_ISIN', TERMS, 'CMTAT_info'], [ZERO]
    ])
    await cmtat.waitForDeployment()
    // FIXED: false (invalid endpoint). VULNERABLE: true -> assertion FAILS.
    expect(await cmtat.canTransfer(ZERO, holder.address, 1n)).to.equal(false)
  })
})
