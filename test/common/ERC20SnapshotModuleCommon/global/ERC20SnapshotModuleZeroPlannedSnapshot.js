const { time } = require('@nomicfoundation/hardhat-network-helpers')
const { expect } = require('chai')
const {
  checkSnapshot
} = require('../ERC20SnapshotModuleUtils/ERC20SnapshotModuleUtils')

function ERC20SnapshotModuleCommonGlobal () {
  context('zeroPlannedSnapshotTest', function () {
    const ADDRESSES = [this.address1, this.address2, this.address3]
    const ADDRESS1_INITIAL_MINT = '31'
    const ADDRESS2_INITIAL_MINT = '32'
    const ADDRESS3_INITIAL_MINT = '33'
    const TOTAL_SUPPLY_INITIAL_MINT = '96'
    beforeEach(async function () {
      await this.cmtat
        .connect(this.admin)
        .mint(this.address1, ADDRESS1_INITIAL_MINT)
      await this.cmtat
        .connect(this.admin)
        .mint(this.address2, ADDRESS2_INITIAL_MINT)
      await this.cmtat
        .connect(this.admin)
        .mint(this.address3, ADDRESS3_INITIAL_MINT)
    })

    context('Before any snapshot', function () {
      it('testCanGetBalanceAddress&TotalSupply', async function () {
        // Act + Assert
        await checkSnapshot.call(
          this,
          await time.latest(),
          TOTAL_SUPPLY_INITIAL_MINT,
          ADDRESSES,
          [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT]
        )
      })
    })
  })
}
module.exports = ERC20SnapshotModuleCommonGlobal
