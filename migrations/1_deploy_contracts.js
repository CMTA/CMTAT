require('dotenv').config()

const CMTAT_PROXY = artifacts.require("CMTAT_PROXY")
const { deployProxy } = require("@openzeppelin/truffle-upgrades")
const { Address } = require("ethereumjs-util")
const { time } = require('@openzeppelin/test-helpers')
module.exports = async function (deployer, _network, account) {
  const admin = process.env.ADMIN_ADDRESS ? process.env.ADMIN_ADDRESS : account[0]
  const flag = 0
  const ZERO_ADDRESS = Address.zero().toString()
  const delayTime = BigInt(time.duration.days(3))
  const proxyContract = await deployProxy(
    CMTAT_PROXY,
    [
      admin,
	  delayTime,
      "Test CMTA Token",
      "TCMTAT",
      0,
      "TCMTAT_ISIN",
      "https://cmta.ch",
      ZERO_ADDRESS,
      "TCMTAT_info",
      flag,
    ],
    {
      deployer,
      constructorArgs: [ZERO_ADDRESS]
    }
  );
  await CMTAT_PROXY.deployed()
  console.log("Proxy deployed at: ", proxyContract.address)
}
