const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
// TODO : Update the library
// const ethSigUtil = require('@metamask/eth-sig-util')
const ethSigUtil = require('eth-sig-util')
const Wallet = require('ethereumjs-wallet').default
const { DEFAULT_ADMIN_ROLE } = require('../../utils')
const { should } = require('chai').should()
const { deployProxy } = require('@openzeppelin/truffle-upgrades')
const CMTAT = artifacts.require('CMTAT')
const MinimalForwarderMock = artifacts.require('MinimalForwarderMock')
const MetaTxModuleCommon = require('../../common/MetaTxModuleCommon')
const NAME = 'MinimalForwarder'
const VERSION = '0.0.1'
const EIP712Domain = [
  { name: 'name', type: 'string' },
  { name: 'version', type: 'string' },
  { name: 'chainId', type: 'uint256' },
  { name: 'verifyingContract', type: 'address' }
]

contract(
  'MetaTxModule',
  function ([
    _,
    owner,
    address1,
    address2
  ]) {
    beforeEach(async function () {
      this.trustedForwarder = await MinimalForwarderMock.new()
      await this.trustedForwarder.initialize()
      this.cmtat = await deployProxy(CMTAT, [owner, this.trustedForwarder.address, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch'], { initializer: 'initialize', constructorArgs: [] })
    })

    MetaTxModuleCommon(owner, address1)
  }
)
