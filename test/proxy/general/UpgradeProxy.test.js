const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { should } = require('chai').should()

const { deployProxy, upgradeProxy, erc1967 } = require('@openzeppelin/truffle-upgrades')
const CMTAT1 = artifacts.require('CMTAT_PROXY')
const CMTAT2 = artifacts.require('CMTAT_PROXY')
const { ZERO_ADDRESS } = require('../../utils')

contract('UpgradeableCMTAT - Proxy', function ([_, admin, address1]) {
  /*
  Functions used: balanceOf, totalSupply, mint
  */
  it('testKeepStorageForTokens', async function () {
    this.flag = 5
    // With the first version of CMTAT
    this.CMTAT_PROXY = await deployProxy(CMTAT1, [admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', ZERO_ADDRESS, 'CMTAT_info', this.flag], {
      initializer: 'initialize',
      constructorArgs: [_]
    })
    const implementationContractAddress1 = erc1967.getImplementationAddress(this.CMTAT_PROXY.address, {
      from: admin
    });
    (await this.CMTAT_PROXY.balanceOf(admin)).should.be.bignumber.equal('0');

    // Issue 20 and check balances and total supply
    ({ logs: this.logs1 } = await this.CMTAT_PROXY.mint(address1, 20, {
      from: admin
    }));
    (await this.CMTAT_PROXY.balanceOf(address1)).should.be.bignumber.equal('20');
    (await this.CMTAT_PROXY.totalSupply()).should.be.bignumber.equal('20')

    // Upgrade the proxy with a new implementation contract
    this.upgradeableCMTATV2Instance = await upgradeProxy(this.CMTAT_PROXY.address, CMTAT2, {
      constructorArgs: [_]
    })
    // Get the new implementation contract address
    const implementationContractAddress2 = erc1967.getImplementationAddress(this.CMTAT_PROXY.address, {
      from: admin
    })
    // The address of the implementation contract has changed
    implementationContractAddress1.should.not.be.equal(implementationContractAddress2);
    // keep the storage
    (await this.upgradeableCMTATV2Instance.balanceOf(address1)).should.be.bignumber.equal('20');

    // Issue 20 and check balances and total supply
    ({ logs: this.logs1 } = await this.upgradeableCMTATV2Instance.mint(address1, 20, {
      from: admin
    }));
    (await this.upgradeableCMTATV2Instance.balanceOf(address1)).should.be.bignumber.equal('40');
    (await this.upgradeableCMTATV2Instance.totalSupply()).should.be.bignumber.equal('40')
  })
})
