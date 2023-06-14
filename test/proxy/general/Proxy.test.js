const { expectRevert } = require('@openzeppelin/test-helpers')

const { deployProxy, erc1967 } = require('@openzeppelin/truffle-upgrades')
const CMTAT1 = artifacts.require('CMTAT_BASE')
const { DEFAULT_ADMIN_ROLE } = require('../../utils')
const CMTAT = artifacts.require('CMTAT_BASE')

contract(
  'Proxy - Security Test',
  function ([_, admin, attacker]) {
    beforeEach(async function () {
      this.flag = 5
      this.CMTAT_BASE = await deployProxy(CMTAT1, [admin, 'CMTA Token', 'CMTAT', 18, 'CMTAT_ISIN', 'https://cmta.ch', 'CMTAT_info', this.flag])
      const implementationContractAddress = await erc1967.getImplementationAddress(this.CMTAT_BASE.address, { from: admin })
      this.implementationContract = await CMTAT.at(implementationContractAddress)
    })

    context('Attacker', function () {
      // Here the argument to indicate if it is deployed with a proxy, set at false by the attacker
      it('testCannotBeTakenControlByAttacker1', async function () {
        await expectRevert(
          this.implementationContract.initialize(attacker, 'CMTA Token', 'CMTAT', 18, 'CMTAT_ISIN', 'https://cmta.ch', 'CMTAT_info', this.flag, { from: attacker }),
          'Initializable: contract is already initialized'
        )
        await expectRevert(
          this.implementationContract.setFlag(0, { from: attacker }),
          'AccessControl: account ' +
          attacker.toLowerCase() +
          ' is missing role ' +
          DEFAULT_ADMIN_ROLE
        )
      })
      // Here the argument to indicate if it is deployed with a proxy, set at true by the attacker
      it('testCannotBeTakenControlByAttacker2', async function () {
        await expectRevert(
          this.implementationContract.initialize(attacker, 'CMTA Token', 'CMTAT', 18, 'CMTAT_ISIN', 'https://cmta.ch', 'CMTAT_info', this.flag, { from: attacker }),
          'Initializable: contract is already initialized'
        )
        await expectRevert(
          this.implementationContract.setFlag(0, { from: attacker }),
          'AccessControl: account ' +
          attacker.toLowerCase() +
          ' is missing role ' +
          DEFAULT_ADMIN_ROLE
        )
      })
    })
  })
