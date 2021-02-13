var EliteToken = artifacts.require("./EliteToken.sol");
var PayrollProcessor = artifacts.require("./PayrollProcessor.sol");

module.exports = function(deployer) {
    deployer.deploy(EliteToken, 1000000).then(function() {
        // Token price is 0.001 Ether
        var tokenPrice = 1000000000000000;
        return deployer.deploy(PayrollProcessor, EliteToken.address, tokenPrice);
    });
};