var BSToken = artifacts.require('BSToken.sol');
var BSMinter = artifacts.require('BSMinter.sol');

var BSSToken = artifacts.require('BSSToken.sol');
var BSSMinter = artifacts.require('BSSMinter.sol');

var cap = 10**5;

var financeAddr = '';
var purchaseTokenAddr = '';

module.exports = function (deployer) {
  deployer.then(async () => {

    await deployer.deploy(BSSToken, cap);
    const instanceBSSToken = await BSSToken.deployed();

    await deployer.deploy(BSToken);
    const instanceBSToken = await BSToken.deployed();

    await deployer.deploy(BSMinter, instanceBSToken.address, purchaseTokenAddr, financeAddr);
    const instanceBSMinter = await BSMinter.deployed();

    await deployer.deploy(BSSMinter, instanceBSToken.address, instanceBSSToken.address, purchaseTokenAddr, financeAddr);
    const instanceBSSMinter = await BSSMinter.deployed();

    await instanceBSToken.addMinter(instanceBSMinter.address);
    await instanceBSToken.addMinter(instanceBSSMinter.address);
    await instanceBSSToken.addMinter(instanceBSSMinter.address);

  })
}
