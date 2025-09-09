const { expect } = require('chai')
const { DEFAULT_ADMIN_ROLE, ZERO_ADDRESS } = require('../utils')
const { TERMS } = require('../deploymentUtils')

function CCIPModuleCommon () {
  context('Set CCIP Admin', function () {
    it('testCanSetCCIPAdmin', async function () {
      // Act
      this.logs = await this.cmtat.connect(this.admin).setCCIPAdmin(this.address1)
      // Act + Assert
      expect(await this.cmtat.getCCIPAdmin()).to.equal(this.address1)

      await expect(this.logs)
      .to.emit(this.cmtat, 'CCIPAdminTransferred')
      .withArgs(ZERO_ADDRESS, this.address1)

      // Again
      this.logs = await this.cmtat.connect(this.admin).setCCIPAdmin(this.address2)
      // Act + Assert
      expect(await this.cmtat.getCCIPAdmin()).to.equal(this.address2)

      await expect(this.logs)
      .to.emit(this.cmtat, 'CCIPAdminTransferred')
      .withArgs(this.address1, this.address2)
    })
    
    it('testCannotNonAdminSetCCIPAdmin', async function () {
      // Act
      await expect(this.cmtat.connect(this.address1).setCCIPAdmin(this.address1))
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, DEFAULT_ADMIN_ROLE)
    })

    it('testCannotSetAdinWithSameValue>', async function () {
      // Act
      await expect(this.cmtat.connect(this.admin).setCCIPAdmin(ZERO_ADDRESS))
        .to.be.revertedWithCustomError(
          this.cmtat,
          'CMTAT_CCIPModule_SameValue'
        )
    })
  })
}
module.exports = CCIPModuleCommon
