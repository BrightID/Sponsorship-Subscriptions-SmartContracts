var BSToken = artifacts.require('BSToken.sol');
var BSTMinter = artifacts.require('BSTMinter.sol');

var BSSToken = artifacts.require('BSSToken.sol');
var BSSTMinter = artifacts.require('BSSTMinter.sol');

var cap = 100000;

var financeAddr = '';
var purchaseTokenAddr = '';

module.exports = function (deployer) {
  deployer.then(async () => {

    await deployer.deploy(BSSToken, cap);
    const instanceBSSToken = await BSSToken.deployed();

    await deployer.deploy(BSToken);
    const instanceBSToken = await BSToken.deployed();

    await deployer.deploy(BSTMinter, instanceBSToken.address, purchaseTokenAddr, financeAddr);
    const instanceBSTMinter = await BSTMinter.deployed();

    await deployer.deploy(BSSTMinter, instanceBSToken.address, instanceBSSToken.address, purchaseTokenAddr, financeAddr);
    const instanceBSSTMinter = await BSSTMinter.deployed();

    await instanceBSToken.addMinter(instanceBSTMinter.address);
    await instanceBSToken.addMinter(instanceBSSTMinter.address);
    await instanceBSSToken.addMinter(instanceBSSTMinter.address);

  })
}
