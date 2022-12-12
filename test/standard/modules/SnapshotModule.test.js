const CMTAT = artifacts.require('CMTAT')
const SnapshotModuleCommon = require('../../common/SnapshotModuleCommon')

contract(
  'Standard - SnapshotModule',
  function ([_, admin, address1, address2, address3]) {
    beforeEach(async function () {
      this.cmtat = await CMTAT.new(_, false, admin, 'CMTA Token', 'CMTAT', 'CMTAT_ISIN', 'https://cmta.ch', { from: admin })
    })

    SnapshotModuleCommon(admin, address1, address2, address3)
  }
)
