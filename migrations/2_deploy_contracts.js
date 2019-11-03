// This script needs to be executed by BMAIN DAO's Agent App.

// The executor acquires "ownership" roles over the Sponsorships,
// Subscriptions, SponsorshipsMinter, and SubscriptionsMinter contracts.
// Look for the "onlyOwner" modifier on contract functions.

// The executor acquires a permanent ability to mint both Sponsorships
// and Subscriptions to any address, and to claim Sponsorships from 
// Subscriptions held by any address. Look for the "onlyMinter" modifier.

// The executor acquires a permanent ability to pause mint and claim
// functions for Subscriptions and mint and assignContext functions for
// Sponsorships. Look for the "whenNotPaused" modifier.

var Sp = artifacts.require('Sponsorships.sol');
var SpMinter = artifacts.require('SponsorshipsMinter.sol');

var Subs = artifacts.require('Subscriptions.sol');
var SubsMinter = artifacts.require('SubscriptionsMinter.sol');

// This needs to match the total number of Subscriptions in all 
// steps defined in the SubscriptionsMinter contract.
const cap = 900000;
// The contract address of the Finance app of BMAIN DAO.
const financeAddr = '';
// The purchase token needs to be DAI or an equivalent. Several places define
// a starting or base price of "1."
const purchaseTokenAddr = '';

module.exports = function (deployer) {
  deployer.then(async () => {

    await deployer.deploy(Sp);
    const instanceSp = await Sp.deployed();

    await deployer.deploy(Subs, cap);
    const instanceSubs = await Subs.deployed();

    // The token used to purchase Sponsorships can be changed later.
    await deployer.deploy(SpMinter, instanceSp.address, purchaseTokenAddr, financeAddr);
    const instanceSpMinter = await SpMinter.deployed();

    // The token used to purchase Subscriptions can't be changed, but the sale has a cap and is meant to end.
    await deployer.deploy(SubsMinter, instanceSp.address, instanceSubs.address, purchaseTokenAddr, financeAddr);
    const instanceSubsMinter = await SubsMinter.deployed();

    await instanceSp.addMinter(instanceSpMinter.address);
    await instanceSubs.addMinter(instanceSubsMinter.address);
    await instanceSp.addMinter(instanceSubsMinter.address);

    await instanceSp.setFinance(financeAddr);
    await instanceSubs.setFinance(financeAddr);

  })

}
