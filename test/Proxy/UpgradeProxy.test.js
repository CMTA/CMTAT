const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { should } = require('chai').should()

const { deployProxy, upgradeProxy  } = require('@openzeppelin/truffle-upgrades')
const CMTAT1 = artifacts.require('CMTAT')
const CMTAT2 = artifacts.require('CMTAT')

contract("UpgradeableCMTAT - Proxy", function ([_, owner, address1]) {
  it("should increment the balance value", async function () {
    // With the first version of CMTAT
    this.upgradeableCMTATInstance = await deployProxy(CMTAT1, [owner, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch'], { initializer: 'initialize', constructorArgs: [_] });

    (await this.upgradeableCMTATInstance.balanceOf(owner)).should.be.bignumber.equal('0');

    // Issue 20 and check balances and total supply
    ({ logs: this.logs1 } = await this.upgradeableCMTATInstance.mint(address1, 20, {
      from: owner
    }));
    (await this.upgradeableCMTATInstance.balanceOf(address1)).should.be.bignumber.equal('20');
    (await this.upgradeableCMTATInstance.totalSupply()).should.be.bignumber.equal('20');

    // With the new version
    // With the first version of CMTAT
    //this.upgradeableCMTATV2Instance = await upgradeProxy(this.upgradeableCMTATInstance.address, CMTAT2, [owner, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch']);
    this.upgradeableCMTATV2Instance = await upgradeProxy(this.upgradeableCMTATInstance.address, CMTAT2, { constructorArgs: [_] });

    (await this.upgradeableCMTATV2Instance.balanceOf(address1)).should.be.bignumber.equal('20');

    // Issue 20 and check balances and total supply
    ({ logs: this.logs1 } = await this.upgradeableCMTATV2Instance.mint(address1, 20, {
      from: owner
    }));
    (await this.upgradeableCMTATV2Instance.balanceOf(address1)).should.be.bignumber.equal('40');
    (await this.upgradeableCMTATV2Instance.totalSupply()).should.be.bignumber.equal('40');
    })
})
