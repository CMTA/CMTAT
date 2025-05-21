const { expect } = require("chai");
const { ethers } = require("hardhat");
const TERMS = [
  'doc1',
  'https://example.com/doc1',
  '0x6a12eff2f559a5e529ca2c563c53194f6463ed5c61d1ae8f8731137467ab0279'
]
const {
  fixture,
  loadFixture
} = require('../deploymentUtils')
const { ZERO_ADDRESS } = require('../utils')
const DocumentModuleCommon = require('../common/DocumentModule/DocumentModuleCommon')
const DebtModuleCommon = require('../common/DebtModule/DebtModuleCommon')
describe("ERC721MockUpgradeable", function () {
  
  const SYMBOL = "ERC721MockS"
  const NAME = "ERC721MockN"
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    const ETHERS_CMTAT_PROXY_FACTORY = await ethers.getContractFactory(
        'ERC721MockUpgradeable'
      )
    this.cmtat  = await upgrades.deployProxy(
        ETHERS_CMTAT_PROXY_FACTORY,
        [
            NAME, SYMBOL,
            this.admin.address,
            ['CMTAT_ISIN', TERMS, 'CMTAT_info'],
            ZERO_ADDRESS
        ],
        {
          initializer: 'initialize',
          constructorArgs: [],
          from: this.admin.address
        }
      )
  });

  it("testHasTheRightNameAndSymbol", async function () {
    expect(await this.cmtat.name()).to.equal(NAME);
    expect(await this.cmtat.symbol()).to.equal(SYMBOL);
  });

  it("testCanMintToken", async function () {
    await this.cmtat.mint(this.address1, 1);
    expect(await this.cmtat.ownerOf(1)).to.equal(this.address1);
    expect(await this.cmtat.balanceOf(this.address1)).to.equal(1);
  });

  it("testCanTransferTokenDirectly", async function () {
    await this.cmtat.mint(this.admin, 1);
    await this.cmtat.connect(this.admin).transferFrom(this.admin, this.address1, 1);
    expect(await this.cmtat.ownerOf(1)).to.equal(this.address1);
  });

  it("testFailedTransferIfNotOwned", async function () {
    await this.cmtat.mint(this.address1, 1);
    this.cmtat.connect(this.address2).transferFrom(this.address1, this.address2, 1)
  });

  it("testApprovedAndTransfer", async function () {
    await this.cmtat.mint(this.address1, 1);
    await this.cmtat.connect(this.address1).approve(this.address2, 1);
    await this.cmtat.connect(this.address2).transferFrom(this.address1, this.address2, 1);
    expect(await this.cmtat.ownerOf(1)).to.equal(this.address2);
  });

  it("testSetAndRespectOperatorApprovals", async function () {
    await this.cmtat.mint(this.address1, 1);
    await this.cmtat.connect(this.address1).setApprovalForAll(this.address2, true);
    expect(await this.cmtat.isApprovedForAll(this.address1, this.address2)).to.be.true;
    await this.cmtat.connect(this.address2).transferFrom(this.address1, this.admin, 1);
    expect(await this.cmtat.ownerOf(1)).to.equal(this.admin);
  });

  it("testEmitTransferEventOnMint", async function () {
    await expect(this.cmtat.mint(this.address1, 1))
      .to.emit(this.cmtat, "Transfer")
      .withArgs(ZERO_ADDRESS, this.address1, 1);
  });

  it("testCannotTransferToAFrozenAddress", async function () {
    await this.cmtat.mint(this.admin, 1);
    await this.cmtat.connect(this.admin).setAddressFrozen(this.address1, true)
    await expect(this.cmtat.transferFrom(this.admin, this.address1, 1)).to.be.revertedWithCustomError(
      this.cmtat,
      'CMTAT_InvalidTransfer')
    .withArgs( this.admin,this.address1, 1);
  });

  it("testCannotTransferIfContractIsPaused", async function () {
    await this.cmtat.mint(this.admin, 1);
    await this.cmtat.connect(this.admin).pause();
    await expect(this.cmtat.transferFrom(this.admin, this.address1, 1)).to.be.revertedWithCustomError(
      this.cmtat,
      'CMTAT_InvalidTransfer')
    .withArgs( this.admin,this.address1, 1)
  });

  it("testCannotMintIfContractIsDeactivated", async function () {
    await this.cmtat.connect(this.admin).deactivateContract();
    await expect(this.cmtat.mint(this.admin, 1)).to.be.revertedWithCustomError(
      this.cmtat,
      'CMTAT_InvalidTransfer').withArgs(ZERO_ADDRESS, this.admin, 1)
  });
  DocumentModuleCommon()
  DebtModuleCommon()
});