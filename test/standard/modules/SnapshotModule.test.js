const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { SNAPSHOOTER_ROLE } = require('../../utils')
const { should } = require('chai').should()
const CMTAT = artifacts.require('CMTAT')
const SnapshotModuleCommon = require('../../common/SnapshotModuleCommon')

const getUnixTimestamp = () => {
  return Math.round(new Date().getTime() / 1000)
}

const timeout = function (ms) {
  return new Promise((resolve) => setTimeout(resolve, ms))
}

contract(
  'Standard - SnapshotModule',
  function ([_, owner, address1, address2, address3]) {
    beforeEach(async function () {
      this.cmtat = await CMTAT.new(owner, _, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', { from: owner })
    })

    SnapshotModuleCommon(owner, address1, address2, address3)
  }
)
