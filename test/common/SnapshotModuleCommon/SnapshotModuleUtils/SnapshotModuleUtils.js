const { expect } = require('chai')
const getUnixTimestamp = () => {
  return Math.round(new Date().getTime() / 1000)
}

const timeout = function (ms) {
  return new Promise((resolve) => setTimeout(resolve, ms))
}

async function checkSnapshot (time, totalSupply, addressese, balances) {
  const addresses = [this.address1, this.address2, this.address3]
  // Values before the snapshot
  expect(await this.transferEngineMock.snapshotTotalSupply(time)).to.equal(
    totalSupply
  )
  // const result = await this.cmtat.snapshotInfoBatch(time, addresses)
  const result = await this.transferEngineMock[
    'snapshotInfoBatch(uint256,address[])'
  ](time, addresses)
  /* methods */
  const times = [time]
  const result2 = await this.transferEngineMock[
    'snapshotInfoBatch(uint256[],address[])'
  ](times, addresses)
  for (let i = 0; i < balances.length; ++i) {
    expect(
      await this.transferEngineMock.snapshotBalanceOf(time, addresses[i])
    ).to.equal(balances[i])
    await this.transferEngineMock.snapshotInfo(time, addresses[i])
    const { 0: ownerBalance, 1: totalSupplyGet } =
      await this.transferEngineMock.snapshotInfo(time, addresses[i])
    // const [ownerBalance, totalSupplyGet]
    expect(ownerBalance).to.equal(balances[i])
    expect(result[0][i]).to.equal(balances[i])
    expect(result2[0][0][i]).to.equal(balances[i])
    expect(totalSupplyGet).to.equal(totalSupply)
  }
  expect(result[1]).to.equal(totalSupply)
  expect(result2[1][0]).to.equal(totalSupply)
}

async function checkArraySnapshot (snapshots, snapshotsValue) {
  for (let i = 0; i < snapshots.length; ++i) {
    expect(snapshots[i]).to.equal(snapshotsValue[i])
  }
}
module.exports = {
  getUnixTimestamp,
  timeout,
  checkSnapshot,
  checkArraySnapshot
}
