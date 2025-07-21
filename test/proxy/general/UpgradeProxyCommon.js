const { expect } = require('chai')
const { ethers, upgrades } = require('hardhat')
function UpgradeProxyCommon () {
  /*
   * Functions used: balanceOf, totalSupply, mint
   */
  it('testKeepStorageForTokens', async function () {
    // Get Proxy Address
    const CMTAT_PROXY_ADDRESS = await this.CMTAT.getAddress()
    const IMPLEMENTATION_CONTRACT_ADDRESS_V1 =
      await upgrades.erc1967.getImplementationAddress(CMTAT_PROXY_ADDRESS)

    // With the first version of CMTAT
    expect(await this.CMTAT.balanceOf(this.admin)).to.equal('0');

    // Issue 20 and check balances and total supply
    ({ logs: this.logs1 } = await this.CMTAT.connect(this.admin).mint(
      this.address1,
      20
    ))

    expect(await this.CMTAT.balanceOf(this.address1)).to.equal('20')
    expect(await this.CMTAT.totalSupply()).to.equal('20')

    // Upgrade the proxy with a new implementation contract
    let CMTAT_PROXY_V2
    if (this.IsUUPSProxy) {
      CMTAT_PROXY_V2 = await upgrades.upgradeProxy(
        CMTAT_PROXY_ADDRESS,
        this.CMTAT_PROXY_TestFactory.connect(this.admin),
        {
          constructorArgs: [this._.address],
          kind: 'uups',
          unsafeAllow: ['missing-initializer', 'missing-initializer-call']
        }
      )
    } else {
      CMTAT_PROXY_V2 = await upgrades.upgradeProxy(
        CMTAT_PROXY_ADDRESS,
        this.CMTAT_PROXY_TestFactory,
        {
          constructorArgs: [this._.address],
          unsafeAllow: ['missing-initializer', 'missing-initializer-call']
        }
      )
    }

    const PROXY_ADDRESS_V2_INSTANCE = await CMTAT_PROXY_V2.getAddress()

    // Get the new implementation contract address
    const IMPLEMENTATION_CONTRACT_ADDRESS_V2 =
      await upgrades.erc1967.getImplementationAddress(
        PROXY_ADDRESS_V2_INSTANCE
      )

    // Just to be sure that the proxy address remains unchanged
    expect(CMTAT_PROXY_ADDRESS).to.equal(PROXY_ADDRESS_V2_INSTANCE)

    // The address of the implementation contract has changed
    expect(IMPLEMENTATION_CONTRACT_ADDRESS_V1).to.not.equal(
      IMPLEMENTATION_CONTRACT_ADDRESS_V2
    );

    ({ logs: this.logs1 } = await CMTAT_PROXY_V2.balanceOf(this.address1))

    expect(await CMTAT_PROXY_V2.balanceOf(this.address1)).to.equal(20);

    // keep the storage

    // Issue 20 and check balances and total supply
    ({ logs: this.logs1 } = await CMTAT_PROXY_V2.connect(this.admin).mint(
      this.address1,
      20
    ))
    expect(await CMTAT_PROXY_V2.balanceOf(this.address1)).to.equal('40')
    expect(await CMTAT_PROXY_V2.totalSupply()).to.equal('40')
  })
}
module.exports = UpgradeProxyCommon
