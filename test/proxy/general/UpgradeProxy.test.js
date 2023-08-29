const { BN } = require('@openzeppelin/test-helpers')
const { should } = require('chai').should()
const { ZERO_ADDRESS } = require('../../utils')
const {
  deployCMTATProxy,
  DEPLOYMENT_FLAG,
  DEPLOYMENT_DECIMAL
} = require('../../deploymentUtils')
const { ethers, upgrades } = require('hardhat')
contract(
  'UpgradeableCMTAT - Proxy',
  function ([_, admin, address1, deployerAddress]) {
    /*
  Functions used: balanceOf, totalSupply, mint
  */
    it('testKeepStorageForTokens', async function () {
      /// // ADAPT TRUFFLE TEST TO HARDHAT
      /* Factory & Artefact */
      const ETHERS_CMTAT_PROXY_FACTORY = await ethers.getContractFactory(
        'CMTAT_PROXY'
      )
      const ETHERS_CMTAT_PROXY_FACTORY_2 = await ethers.getContractFactory(
        'CMTAT_PROXY_TEST'
      )
      const TRUFFLE_CMTAT_PROXY = artifacts.require('CMTAT_PROXY')
      const TRUFFLE_CMTAT_PROXY_V2 = artifacts.require('CMTAT_PROXY_TEST')
      // Deployment
      const ETHERS_CMTAT_PROXY = await upgrades.deployProxy(
        ETHERS_CMTAT_PROXY_FACTORY,
        [
          admin,
          'CMTA Token',
          'CMTAT',
          DEPLOYMENT_DECIMAL,
          'CMTAT_ISIN',
          'https://cmta.ch',
          ZERO_ADDRESS,
          'CMTAT_info',
          DEPLOYMENT_FLAG
        ],
        {
          initializer: 'initialize',
          constructorArgs: [_],
          from: deployerAddress
        }
      )

      // Get Proxy Address
      const TRUFFLE_CMTAT_PROXY_ADDRESS = await TRUFFLE_CMTAT_PROXY.at(
        await ETHERS_CMTAT_PROXY.getAddress()
      )
      const ETHER_PROXY_ADDRESS = await ETHERS_CMTAT_PROXY.getAddress()
      const IMPLEMENTATION_CONTRACT_ADDRESS_V1 =
        await upgrades.erc1967.getImplementationAddress(ETHER_PROXY_ADDRESS, {
          from: admin
        });

      // With the first version of CMTAT
      (
        await TRUFFLE_CMTAT_PROXY_ADDRESS.balanceOf(admin)
      ).should.be.bignumber.equal('0');

      // Issue 20 and check balances and total supply
      ({ logs: this.logs1 } = await TRUFFLE_CMTAT_PROXY_ADDRESS.mint(
        address1,
        20,
        {
          from: admin
        }
      ));

      (
        await TRUFFLE_CMTAT_PROXY_ADDRESS.balanceOf(address1)
      ).should.be.bignumber.equal('20');
      (
        await TRUFFLE_CMTAT_PROXY_ADDRESS.totalSupply()
      ).should.be.bignumber.equal('20')

      // Upgrade the proxy with a new implementation contract
      const ETHERS_CMTAT_PROXY_V2 = await upgrades.upgradeProxy(
        ETHER_PROXY_ADDRESS,
        ETHERS_CMTAT_PROXY_FACTORY_2,
        {
          constructorArgs: [_]
        }
      )
      const PROXY_ADDRESS_V2_INSTANCE =
        await ETHERS_CMTAT_PROXY_V2.getAddress()

      // Get the new implementation contract address
      const IMPLEMENTATION_CONTRACT_ADDRESS_V2 =
        await upgrades.erc1967.getImplementationAddress(
          PROXY_ADDRESS_V2_INSTANCE,
          {
            from: admin
          }
        )

      // Just to be sure that the proxy address remains unchanged
      ETHER_PROXY_ADDRESS.should.be.equal(PROXY_ADDRESS_V2_INSTANCE)

      // The address of the implementation contract has changed
      IMPLEMENTATION_CONTRACT_ADDRESS_V1.should.not.be.equal(
        IMPLEMENTATION_CONTRACT_ADDRESS_V2
      )

      // Just to be sure that the proxy address remains unchanged
      const TRUFFLE_CMTAT_PROXY_ADDRESS_2 = await TRUFFLE_CMTAT_PROXY_V2.at(
        PROXY_ADDRESS_V2_INSTANCE
      );
      // TRUFFLE_CMTAT_PROXY_ADDRESS.should.be.equal(TRUFFLE_CMTAT_PROXY_ADDRESS_2);

      ({ logs: this.logs1 } = await TRUFFLE_CMTAT_PROXY_ADDRESS_2.balanceOf(
        address1
      ));

      (
        await TRUFFLE_CMTAT_PROXY_ADDRESS_2.balanceOf(address1)
      ).should.be.bignumber.equal(BN(20));

      // keep the storage

      // Issue 20 and check balances and total supply
      ({ logs: this.logs1 } = await TRUFFLE_CMTAT_PROXY_ADDRESS_2.mint(
        address1,
        20,
        {
          from: admin
        }
      ));
      (
        await TRUFFLE_CMTAT_PROXY_ADDRESS_2.balanceOf(address1)
      ).should.be.bignumber.equal('40');
      (
        await TRUFFLE_CMTAT_PROXY_ADDRESS_2.totalSupply()
      ).should.be.bignumber.equal('40')
    })
  }
)
