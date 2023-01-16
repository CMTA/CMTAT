const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { should } = require('chai').should()
const { getUnixTimestamp, checkSnapshot } = require('../SnapshotModuleUtils/SnapshotModuleUtils')

function SnapshotModuleCommonGlobal (admin, address1, address2, address3) {
  context('zeroPlannedSnapshotTest', function () {
    const ADDRESSES = [address1, address2, address3]
    const ADDRESS1_INITIAL_MINT = '31'
    const ADDRESS2_INITIAL_MINT = '32'
    const ADDRESS3_INITIAL_MINT = '33'
    const TOTAL_SUPPLY_INITIAL_MINT = '96'
    beforeEach(async function () {
      await this.cmtat.mint(address1, ADDRESS1_INITIAL_MINT, { from: admin })
      await this.cmtat.mint(address2, ADDRESS2_INITIAL_MINT, { from: admin })
      await this.cmtat.mint(address3, ADDRESS3_INITIAL_MINT, { from: admin })
    })

    context('Before any snapshot', function () {
      it('testCanGetBalanceAddress&TotalSupply', async function () {
        // Act + Assert
        await checkSnapshot.call(this, getUnixTimestamp(), TOTAL_SUPPLY_INITIAL_MINT, ADDRESSES, [ADDRESS1_INITIAL_MINT, ADDRESS2_INITIAL_MINT, ADDRESS3_INITIAL_MINT])
      })
    })
  })
}
module.exports = SnapshotModuleCommonGlobal
