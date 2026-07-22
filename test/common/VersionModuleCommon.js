const { expect } = require('chai')
const { VERSION } = require('../utils')

function VersionModuleCommon () {
  context('Token structure', function () {
    it('testHasTheDefinedVersion', async function () {
      // Act + Assert
      expect(await this.cmtat.version()).to.equal(VERSION)
    })
  })
}
module.exports = VersionModuleCommon
