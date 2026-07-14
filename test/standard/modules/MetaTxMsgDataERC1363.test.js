const { expect } = require('chai')
const {
  DEPLOYMENT_DECIMAL,
  TERMS,
  fixture,
  loadFixture
} = require('../../deploymentUtils.js')
const { ZERO_ADDRESS, ERC2771ForwarderDomain } = require('../../utils.js')

describe('Standard - MetaTxModule - _msgData (CMTATBaseERC1363)', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture))
    this.forwarder = await ethers.deployContract('MinimalForwarderMock')
    await this.forwarder.initialize(ERC2771ForwarderDomain)
    const factory = await ethers.getContractFactory('CMTATUpgradeableERC1363MsgDataMock')
    this.cmtat = await upgrades.deployProxy(
      factory,
      [
        this.admin.address,
        ['CMTA Token', 'CMTAT', DEPLOYMENT_DECIMAL],
        ['CMTAT_ISIN', TERMS, 'CMTAT_info'],
        [ZERO_ADDRESS]
      ],
      {
        initializer: 'initialize',
        constructorArgs: [this.forwarder.target],
        unsafeAllow: ['missing-initializer']
      }
    )
    await this.cmtat.waitForDeployment()
  })

  it('returns correct msgData for direct call', async function () {
    const expectedData = this.cmtat.interface.encodeFunctionData('getMsgData')
    const result = await this.cmtat.getMsgData.staticCall()
    expect(result).to.equal(ethers.keccak256(expectedData))
  })

  it('returns correct msgData for trusted forwarder calldata shape', async function () {
    const data = this.cmtat.interface.encodeFunctionData('getMsgData')
    const appendedData = ethers.concat([data, ethers.zeroPadValue(this.address1.address, 20)])
    const returnData = await ethers.provider.call({
      to: this.cmtat.target,
      from: this.forwarder.target,
      data: appendedData
    })
    expect(returnData).to.equal(ethers.keccak256(data))
  })
})
