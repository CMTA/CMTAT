const {
  getAdminAddress,
  verifyOnExplorer
} = require('../utils')

async function main () {
  const CMTATFactoryAddress = '0x53633587537FFA97084BE82F2Ef8671440Cf17F0'
  const CMTATProxyAdminAddress = '0xdb1d9B95D72e5cb4B007C7f23BcAec215e9a6Fc9'
  const CMTATImplementationAddress = '0x45E36B26a2717c131c6F9b2B3720A9241Da1714E'
  const admin = await getAdminAddress()
  console.log(admin)

  // await verifyOnExplorer(
  //   CMTATProxyAdminAddress
  // )
  // await verifyOnExplorer(
  //   CMTATImplementationAddress
  // )

  await verifyOnExplorer(
    CMTATFactoryAddress,
    [
      CMTATImplementationAddress,
      admin
    ]
  )
}

main().then(() => process.exit(0))
