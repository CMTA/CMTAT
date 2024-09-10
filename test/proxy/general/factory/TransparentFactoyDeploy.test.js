const { expect } = require('chai');
const { ZERO_ADDRESS } = require('../../../utils.js')
const {
  deployCMTATProxyImplementation,
  fixture, loadFixture 
} = require('../../../deploymentUtils.js')
describe(
  'Deploy TP Factory',
  function () {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture));
      this.CMTAT_PROXY_IMPL = await deployCMTATProxyImplementation(
        this._.address,
        this.deployerAddress.address
      )
      this.FACTORYCustomError =  await ethers.deployContract('CMTAT_TP_FACTORY',[
        this.CMTAT_PROXY_IMPL.target,
        this.admin,
        true
      ])
    })

    context('FactoryDeployment', function () {
      it('testCannotDeployIfImplementationIsZero', async function () {
        await expect(  ethers.deployContract('CMTAT_TP_FACTORY',[
          ZERO_ADDRESS, this.admin
        ]))
        .to.be.revertedWithCustomError(this.FACTORYCustomError, 'CMTAT_Factory_AddressZeroNotAllowedForLogicContract')
      })

      it('testCannotDeployIfFactoryAdminIsZero', async function () {
        await expect( ethers.deployContract('CMTAT_TP_FACTORY', [
          this.CMTAT_PROXY_IMPL.target, ZERO_ADDRESS
        ]))
        .to.be.revertedWithCustomError(this.FACTORYCustomError, 'CMTAT_Factory_AddressZeroNotAllowedForFactoryAdmin')
      })
    })
  }
)
