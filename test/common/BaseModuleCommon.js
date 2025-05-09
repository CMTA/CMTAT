const { expect } = require('chai')
const { DEFAULT_ADMIN_ROLE } = require('../utils')
const { TERMS } = require('../deploymentUtils')

function BaseModuleCommon () {
  context('Token structure', function () {
  
    it('testHasTheDefinedVersion', async function () {
      // Act + Assert
      expect(await this.cmtat.version()).to.equal('3.0.0')
    })
  })
}
module.exports = BaseModuleCommon
