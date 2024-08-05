const { expect } = require('chai');
const { ZERO_ADDRESS } = require('../../utils')
const {
  DEPLOYMENT_DECIMAL,
  fixture, loadFixture 
} = require('../../deploymentUtils')
const { ethers, upgrades } = require('hardhat')
describe(
  'UpgradeableCMTAT - Proxy',
  function () {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture));
    })

    /*
  Functions used: balanceOf, totalSupply, mint
  */
    it('testKeepStorageForTokens', async function () {
      /* Factory & Artefact */
      const ETHERS_CMTAT_PROXY_FACTORY = await ethers.getContractFactory(
        'CMTAT_PROXY'
      )
      const ETHERS_CMTAT_PROXY_FACTORY_2 = await ethers.getContractFactory(
        'CMTAT_PROXY_TEST'
      )
      // Deployment
      const ETHERS_CMTAT_PROXY = await upgrades.deployProxy(
        ETHERS_CMTAT_PROXY_FACTORY,
        [
          this.admin.address,
          'CMTA Token',
          'CMTAT',
          DEPLOYMENT_DECIMAL,
          'CMTAT_ISIN',
          'https://cmta.ch',
          'CMTAT_info',
          [ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS]
        ],
        {
          initializer: 'initialize',
          constructorArgs: [this._.address],
          from: this.deployerAddress.address
        }
      )

      // Get Proxy Address
      /*const TRUFFLE_CMTAT_PROXY_ADDRESS = await TRUFFLE_CMTAT_PROXY.at(
        await ETHERS_CMTAT_PROXY.getAddress()
      )*/
      const ETHER_PROXY_ADDRESS = await ETHERS_CMTAT_PROXY.getAddress()
      const IMPLEMENTATION_CONTRACT_ADDRESS_V1 =
        await upgrades.erc1967.getImplementationAddress(ETHER_PROXY_ADDRESS);

      // With the first version of CMTAT
      expect(
        await ETHERS_CMTAT_PROXY.balanceOf(this.admin)
      ).to.equal('0');

      // Issue 20 and check balances and total supply
      ({ logs: this.logs1 } = await ETHERS_CMTAT_PROXY.connect(this.admin).mint(
        this.address1,
        20
      ));

      expect(
        await ETHERS_CMTAT_PROXY.balanceOf(this.address1)
      ).to.equal('20');
      expect(
        await ETHERS_CMTAT_PROXY.totalSupply()
      ).to.equal('20')

      // Upgrade the proxy with a new implementation contract
      const ETHERS_CMTAT_PROXY_V2 = await upgrades.upgradeProxy(
        ETHER_PROXY_ADDRESS,
        ETHERS_CMTAT_PROXY_FACTORY_2,
        {
          constructorArgs: [this._.address]
        }
      )
      const PROXY_ADDRESS_V2_INSTANCE =
        await ETHERS_CMTAT_PROXY_V2.getAddress()

      // Get the new implementation contract address
      const IMPLEMENTATION_CONTRACT_ADDRESS_V2 =
        await upgrades.erc1967.getImplementationAddress(
          PROXY_ADDRESS_V2_INSTANCE
        )

      // Just to be sure that the proxy address remains unchanged
      expect(ETHER_PROXY_ADDRESS).to.equal(PROXY_ADDRESS_V2_INSTANCE);

      // The address of the implementation contract has changed
      expect(IMPLEMENTATION_CONTRACT_ADDRESS_V1).to.not.equal(
        IMPLEMENTATION_CONTRACT_ADDRESS_V2
      );
        // Just to be sure that the proxy address remains unchanged

        // TRUFFLE_CMTAT_PROXY_ADDRESS.to.equal(TRUFFLE_CMTAT_PROXY_ADDRESS_2);

      ({ logs: this.logs1 } = await ETHERS_CMTAT_PROXY_V2.balanceOf(
        this.address1
      ))

      expect(
        await ETHERS_CMTAT_PROXY_V2.balanceOf(this.address1)
      ).to.equal(20);

      // keep the storage

      // Issue 20 and check balances and total supply
      ({ logs: this.logs1 } = await ETHERS_CMTAT_PROXY_V2.connect(this.admin).mint(
        this.address1,
        20
      ));
      expect(
        await ETHERS_CMTAT_PROXY_V2.balanceOf(this.address1)
      ).to.equal('40');
      expect(
        await ETHERS_CMTAT_PROXY_V2.totalSupply()
      ).to.equal('40')
    })
  }
)
