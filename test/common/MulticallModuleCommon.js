const { expect } = require('chai')

function MulticallModuleCommon () {
  context('Multicall', function () {
    it('batches state-changing calls', async function () {
      const data = [
        this.cmtat.interface.encodeFunctionData('mint(address,uint256,bytes)', [
          this.address1.address,
          10n,
          '0x'
        ]),
        this.cmtat.interface.encodeFunctionData('mint(address,uint256,bytes)', [
          this.address2.address,
          20n,
          '0x'
        ])
      ]

      await this.cmtat.connect(this.admin).multicall(data)

      expect(await this.cmtat.balanceOf(this.address1)).to.equal(10n)
      expect(await this.cmtat.balanceOf(this.address2)).to.equal(20n)
    })

    it('returns results for view calls', async function () {
      const data = [
        this.cmtat.interface.encodeFunctionData('name', []),
        this.cmtat.interface.encodeFunctionData('symbol', [])
      ]

      const results = await this.cmtat.multicall.staticCall(data)
      const [name] = this.cmtat.interface.decodeFunctionResult(
        'name',
        results[0]
      )
      const [symbol] = this.cmtat.interface.decodeFunctionResult(
        'symbol',
        results[1]
      )

      expect(name).to.equal('CMTA Token')
      expect(symbol).to.equal('CMTAT')
    })
  })
}

module.exports = MulticallModuleCommon
