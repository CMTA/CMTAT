const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { SNAPSHOOTER_ROLE } = require('../utils')
const { should } = require('chai').should()
const CMTAT = artifacts.require('CMTAT')

const getUnixTimestamp = () => {
  return Math.round(new Date().getTime() / 1000)
}

const timeout = function (ms) {
  return new Promise((resolve) => setTimeout(resolve, ms))
}

function SnapshotModuleCommon (owner, address1, address2, address3) {



  
}

module.exports = SnapshotModuleCommon
