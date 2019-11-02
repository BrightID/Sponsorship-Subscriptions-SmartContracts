var Sp = artifacts.require('Sponsorships.sol');
var SpMinter = artifacts.require('SponsorshipsMinter.sol');

var Subs = artifacts.require('Subscriptions.sol');
var SubsMinter = artifacts.require('SubscriptionsMinter.sol');

const cap = 900000;
const financeAddr = '';
const purchaseTokenAddr = '';

module.exports = function (deployer) {
  deployer.then(async () => {

    await deployer.deploy(Sp);
    const instanceSp = await Sp.deployed();

    await deployer.deploy(Subs, cap);
    const instanceSubs = await Subs.deployed();

    await deployer.deploy(SpMinter, instanceSp.address, purchaseTokenAddr, financeAddr);
    const instanceSpMinter = await SpMinter.deployed();

    await deployer.deploy(SubsMinter, instanceSp.address, instanceSubs.address, purchaseTokenAddr, financeAddr);
    const instanceSubsMinter = await SubsMinter.deployed();

    await instanceSp.addMinter(instanceSpMinter.address);
    await instanceSubs.addMinter(instanceSubsMinter.address);
    await instanceSp.addMinter(instanceSubsMinter.address);

    await instanceSp.setFinance(financeAddr);
    await instanceSubs.setFinance(financeAddr);

  })

}
