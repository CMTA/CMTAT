var CMTA20 = artifacts.require(CMTA20);
module.exports = function(deployer) {
    // Sample token deployment
    deployer.deploy(CMTA20, 'CMTA Test Token', 'CMTATST', 'admin.at.cmta.ch (replace .at. with @)');
};