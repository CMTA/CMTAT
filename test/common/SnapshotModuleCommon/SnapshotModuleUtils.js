
const getUnixTimestamp = () => {
    return Math.round(new Date().getTime() / 1000)
}

const timeout = function (ms) {
    return new Promise((resolve) => setTimeout(resolve, ms))
}

async function checkSnapshot (time, totalSupply, addresses, balances) {
    // Values before the snapshot
    (
      await this.cmtat.snapshotTotalSupply(time)
    ).should.be.bignumber.equal(totalSupply);
  
    for(let i = 0; i < balances.length; ++i){
      (
        await this.cmtat.snapshotBalanceOf(
          time,
          addresses[i]
        )
      ).should.be.bignumber.equal(balances[i]);
    }
  }
  module.exports = { getUnixTimestamp, timeout, checkSnapshot }
  