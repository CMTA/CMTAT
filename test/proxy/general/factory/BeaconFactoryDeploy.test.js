const { ZERO_ADDRESS } = require('../../../utils.js')
const { expect } = require('chai');
const {
  deployCMTATProxyImplementation,
  fixture, loadFixture 
} = require('../../../deploymentUtils.js')
describe(
  'Deploy Beacon with Factory',
  function () {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture));
      this.CMTAT_PROXY_IMPL = await deployCMTATProxyImplementation(
        this._.address,
        this.deployerAddress.address
      )
      this.FACTORYCustomError = await  ethers.deployContract("CMTAT_BEACON_FACTORY",[
        this.CMTAT_PROXY_IMPL.target,
        this.admin,
        this.admin,
        true
      ])
    })
    context('BeaconDeployment', function () {
      it('testCannotDeployIfImplementationIsZero', async function () {
        await expect(ethers.deployContract("CMTAT_BEACON_FACTORY",[ZERO_ADDRESS, this.admin.address, this.admin.address]))
        .to.be.revertedWithCustomError(this.FACTORYCustomError, 'CMTAT_Factory_AddressZeroNotAllowedForLogicContract')
      })
      it('testCannotDeployIfFactoryAdminIsZero', async function () {
        await expect( ethers.deployContract("CMTAT_BEACON_FACTORY",[ this.CMTAT_PROXY_IMPL.target,
          ZERO_ADDRESS,
          this.admin.address]
        ))
        .to.be.revertedWithCustomError(this.FACTORYCustomError, 'CMTAT_Factory_AddressZeroNotAllowedForFactoryAdmin')
      })
      it('testCannotDeployIfBeaconOwnerIsZero', async function () {
        await expect(ethers.deployContract("CMTAT_BEACON_FACTORY",[ this.CMTAT_PROXY_IMPL.target,
          this.admin.address,
          ZERO_ADDRESS]
        ))
        .to.be.revertedWithCustomError(this.FACTORYCustomError, 'CMTAT_Factory_AddressZeroNotAllowedForBeaconOwner')
      })
    })
  }
)
