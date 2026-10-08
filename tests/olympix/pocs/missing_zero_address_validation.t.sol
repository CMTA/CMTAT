const { expect } = require('chai')
const { ethers } = require('hardhat')
const {
  deployCMTATLightStandalone,
  fixture,
  loadFixture
} = require('../deploymentUtils')

// PoC for contracts/modules/internal/common/EnforcementModuleLibrary.sol:_checkInput().
// The vulnerable batch freeze path accepts address(0). In CMTATBaseCore.transfer(),
// direct ERC20 transfers validate with address(0) as the spender sentinel, so a frozen
// zero address makes every direct transfer fail even though the token is not paused.
describe('PoC - batch freeze of address(0) disables direct transfers', function () {
  async function deployFixture () {
    const ctx = await fixture()
    const cmtat = await deployCMTATLightStandalone(
      ctx.admin.address,
      ctx.deployerAddress.address
    )
    return { ...ctx, cmtat }
  }

  it('does not let ENFORCER_ROLE globally block direct transfers by freezing address(0)', async function () {
    const { cmtat, admin, address1, address2 } = await loadFixture(deployFixture)

    // Arrange: admin is the default admin and is implicitly authorized to mint/freeze.
    // A normal holder-to-holder direct transfer succeeds before the zero-address freeze.
    await cmtat.connect(admin).mint(address1.address, 100n)
    await expect(cmtat.connect(address1).transfer(address2.address, 1n))
      .to.emit(cmtat, 'Transfer')
      .withArgs(address1.address, address2.address, 1n)

    // Act: attempt the exact vulnerable batch path. A fixed implementation should
    // reject address(0) here; if so, direct transfers remain available and the test passes.
    let zeroAddressFreezeAccepted = false
    try {
      await cmtat
        .connect(admin)
        .batchSetAddressFrozen([ethers.ZeroAddress], [true])
      zeroAddressFreezeAccepted = true
    } catch (e) {
      zeroAddressFreezeAccepted = false
    }

    if (!zeroAddressFreezeAccepted) {
      expect(await cmtat.isFrozen(ethers.ZeroAddress)).to.equal(false)
      await expect(cmtat.connect(address1).transfer(address2.address, 1n))
        .to.emit(cmtat, 'Transfer')
        .withArgs(address1.address, address2.address, 1n)
      return
    }

    // Vulnerable state: address(0) was written into the frozen-address mapping/list,
    // while the global pause switch remains off. This should not be enough to stop
    // ordinary direct ERC20 transfers; if it is, the ENFORCER_ROLE has bypassed PAUSER_ROLE.
    expect(await cmtat.isFrozen(ethers.ZeroAddress)).to.equal(true)
    expect(await cmtat.paused()).to.equal(false)

    // Secure expectation: targeted account freezing must not globally disable all direct
    // transfers. On the vulnerable code this assertion fails because transfer() uses
    // address(0) as the spender sentinel and ValidationModule rejects frozen spenders.
    await expect(cmtat.connect(address1).transfer(address2.address, 1n))
      .to.emit(cmtat, 'Transfer')
      .withArgs(address1.address, address2.address, 1n)
  })
})
