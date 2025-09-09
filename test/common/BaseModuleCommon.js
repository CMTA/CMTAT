const { expect } = require('chai')

function BaseModuleCommon () {
  context('Token structure', function () {
    it('testHasTheDefinedVersion', async function () {
      // Act + Assert
      expect(await this.cmtat.version()).to.equal('3.1.0')
    })
  })
}
module.exports = BaseModuleCommon
