const { getProxyContract, verifyContract } = require('./utils')

async function main () {
  const proxyContract = await getProxyContract('0x0000000000000000000000000000000000000000')

  await verifyContract(proxyContract)
}

main().then(() => process.exit(0))
