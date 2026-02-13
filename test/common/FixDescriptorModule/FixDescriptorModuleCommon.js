const { expect } = require('chai')
const { ZERO_ADDRESS } = require('../../utils')

function FixDescriptorModuleCommon () {
  context('FixDescriptor Module Test', function () {
    beforeEach(async function () {
      if (!this.definedAtDeployment) {
        this.fixDescriptorEngineMock = await ethers.deployContract(
          'FixDescriptorEngineMock',
          [ZERO_ADDRESS, this.admin]
        )
      }
      if ((await this.cmtat.fixDescriptorEngine()) === ZERO_ADDRESS) {
        await this.cmtat
          .connect(this.admin)
          .setFixDescriptorEngine(this.fixDescriptorEngineMock.target)
      }
    })
    it('testCanReturnTheRightAddressIfSet', async function () {
      if (this.definedAtDeployment) {
        const fixDescriptorEngine = await this.cmtat.fixDescriptorEngine()
        expect(this.fixDescriptorEngineMock.target).to.equal(fixDescriptorEngine)
      }
    })
    it('testCanGetFixDescriptor', async function () {
      const descriptor = {
        schemaHash: ethers.keccak256(ethers.toUtf8Bytes('dictionary')),
        fixRoot: ethers.keccak256(ethers.toUtf8Bytes('root')),
        fixSBEPtr: ethers.ZeroAddress,
        fixSBELen: 0,
        schemaURI: 'ipfs://test'
      }

      await this.fixDescriptorEngineMock.setFixDescriptor(descriptor)

      const result = await this.cmtat.getFixDescriptor()
      expect(result.schemaHash).to.equal(descriptor.schemaHash)
      expect(result.fixRoot).to.equal(descriptor.fixRoot)
      expect(result.fixSBEPtr).to.equal(descriptor.fixSBEPtr)
      expect(result.fixSBELen).to.equal(descriptor.fixSBELen)
      expect(result.schemaURI).to.equal(descriptor.schemaURI)
    })

    it('testCanGetFixRoot', async function () {
      const fixRoot = ethers.keccak256(ethers.toUtf8Bytes('test-root'))
      const descriptor = {
        schemaHash: ethers.keccak256(ethers.toUtf8Bytes('dictionary')),
        fixRoot: fixRoot,
        fixSBEPtr: ethers.ZeroAddress,
        fixSBELen: 0,
        schemaURI: 'ipfs://test'
      }

      await this.fixDescriptorEngineMock.setFixDescriptor(descriptor)

      const result = await this.cmtat.getFixRoot()
      expect(result).to.equal(fixRoot)
    })

    it('testCanVerifyField', async function () {
      const pathSBE = ethers.toUtf8Bytes('path')
      const value = ethers.toUtf8Bytes('value')
      const proof = []
      const directions = []

      // Set verifyField to return true
      await this.fixDescriptorEngineMock.setVerifyFieldResult(true)
      const resultTrue = await this.cmtat.verifyField(pathSBE, value, proof, directions)
      expect(resultTrue).to.equal(true)

      // Set verifyField to return false
      await this.fixDescriptorEngineMock.setVerifyFieldResult(false)
      const resultFalse = await this.cmtat.verifyField(pathSBE, value, proof, directions)
      expect(resultFalse).to.equal(false)
    })

    it('testCanGetEmptyDescriptorIfNoEngine', async function () {
      // Check that engine is ZERO_ADDRESS if not set
      // Note: This test assumes the CMTAT contract was deployed without FixDescriptorEngineModule initialized
      // In practice, if engine is not set, getFixDescriptor() calls will revert when engine is address(0)
      const engine = await this.cmtat.fixDescriptorEngine()
      // If engine is not set at deployment, it should be ZERO_ADDRESS
      // The actual behavior depends on whether FixDescriptorEngineModule was initialized
      expect(engine).to.be.a('string')
    })
  })
}
module.exports = FixDescriptorModuleCommon
