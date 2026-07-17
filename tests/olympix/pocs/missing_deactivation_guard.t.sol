const { expect } = require('chai')
const { ethers } = require('hardhat')
const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers')
const { deployCMTATLightStandalone } = require('../deploymentUtils')

// PoC for contracts/modules/0_CMTATBaseCore.sol:CMTATBaseCore.forcedBurn()
// CMTATStandaloneLight is the concrete deployment artifact that inherits CMTATBaseCore
// and exposes forcedBurn().
describe('CMTATBaseCore forcedBurn deactivation guard PoC', function () {
  const INITIAL_SUPPLY = 50n
  const BURN_AMOUNT = 20n
  const REASON = '0x'

  async function deployFixture () {
    const [deployer, admin, holder] = await ethers.getSigners()
    const cmtat = await deployCMTATLightStandalone(
      admin.address,
      deployer.address
    )
    await cmtat.waitForDeployment()

    return { cmtat, admin, holder }
  }

  it('should not allow forcedBurn to reduce balances or totalSupply after deactivateContract()', async function () {
    const { cmtat, admin, holder } = await loadFixture(deployFixture)

    // Arrange: mint tokens to a holder, then permanently deactivate the token.
    await cmtat.connect(admin).mint(holder.address, INITIAL_SUPPLY)
    expect(await cmtat.balanceOf(holder.address)).to.equal(INITIAL_SUPPLY)
    expect(await cmtat.totalSupply()).to.equal(INITIAL_SUPPLY)

    await cmtat.connect(admin).pause()
    await cmtat.connect(admin).deactivateContract()
    expect(await cmtat.paused()).to.equal(true)
    expect(await cmtat.deactivated()).to.equal(true)

    // Sanity check: the normal burn path routes through _burnOverride(), which
    // calls ValidationModule._canMintBurnByModuleAndRevert() and rejects a
    // deactivated contract.
    await expect(cmtat.connect(admin).burn(holder.address, 1n))
      .to.be.revertedWithCustomError(cmtat, 'EnforcedDeactivation')

    // The holder can still be frozen after deactivation; forcedBurn only checks
    // this frozen flag and then calls ERC20Upgradeable._burn() directly.
    await cmtat.connect(admin).setAddressFrozen(holder.address, true)
    expect(await cmtat.isFrozen(holder.address)).to.equal(true)

    // Security expectation: deactivation guarantees burn operations stop
    // permanently, so forcedBurn should also revert with EnforcedDeactivation.
    // On the vulnerable implementation this transaction succeeds, reducing both
    // holder balance and totalSupply, so this assertion fails and proves the bug.
    await expect(cmtat.connect(admin).forcedBurn(holder.address, BURN_AMOUNT, REASON))
      .to.be.revertedWithCustomError(cmtat, 'EnforcedDeactivation')

    // These post-conditions are reachable only on a fixed implementation.
    expect(await cmtat.balanceOf(holder.address)).to.equal(INITIAL_SUPPLY)
    expect(await cmtat.totalSupply()).to.equal(INITIAL_SUPPLY)
  })
})
