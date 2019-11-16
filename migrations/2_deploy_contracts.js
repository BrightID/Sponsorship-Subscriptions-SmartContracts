// This script needs to be executed by BMAIN DAO's Agent App.

// The executor acquires "ownership" roles over the Sponsorships,
// Subscriptions, SponsorshipsMinter, and SubscriptionsMinter contracts
// because they inherit from FinanceManager which inherits from Ownable.
// This gives the executor the ability to reclaim any tokens erroneously
// sent to those contracts by calling FinanceManager.reclaimTokens().

// The ownership role also allows the executor to change the token and
// price used to purchase Sponsorships and detach the minters from the
// Sponsorships and Subscriptions contracts for replacement. Look for the
// "onlyOwner" modifier on contract functions.

// The ownership role also allows the executor to to call the setFinance()
// function (inherited from FinanceManager) on the Sponsorships,
// Subscriptions, SponsorshipsMinter, and SubscriptionsMinter contracts.
// This will change the recipient of reclaimed tokens; for the two minter
// contracts, it will also change the recipient of funds from purchases.

// The executor acquires the ability to mint both Sponsorships and
// Subscriptions to any address, and to mark Sponsorships from
// Subscriptions as claimed (without actually minting them) for any address
// by calling Subscriptions.claim() directly. Look for the "onlyMinter"
// modifier on contract functions.

// The executor acquires the ability to pause mint, claim, and activate
// functions for Subscriptions and mint and assignContext functions for
// Sponsorships. Look for the "whenNotPaused" modifier on contract functions.

var Sp = artifacts.require('Sponsorships.sol');
var SpMinter = artifacts.require('SponsorshipsMinter.sol');

var Subs = artifacts.require('Subscriptions.sol');
var SubsMinter = artifacts.require('SubscriptionsMinter.sol');

// The contract address of the Finance app of BMAIN DAO.
const financeAddr = '';
// The purchase token needs to be DAI or an equivalent. Several places define
// a starting or base price of "1."
const purchaseTokenAddr = '';

module.exports = function (deployer) {
  deployer.then(async () => {

    await deployer.deploy(Sp);
    const instanceSp = await Sp.deployed();

    await deployer.deploy(Subs);
    const instanceSubs = await Subs.deployed();

    // The token used to purchase Sponsorships can be changed later.
    await deployer.deploy(SpMinter, instanceSp.address, purchaseTokenAddr);
    const instanceSpMinter = await SpMinter.deployed();

    // The token used to purchase Subscriptions can't be changed, but the sale has a cap and is meant to end.
    await deployer.deploy(SubsMinter, instanceSp.address, instanceSubs.address, purchaseTokenAddr);
    const instanceSubsMinter = await SubsMinter.deployed();

    await instanceSp.addMinter(instanceSpMinter.address);
    await instanceSubs.addMinter(instanceSubsMinter.address);
    await instanceSp.addMinter(instanceSubsMinter.address);

    await instanceSp.setFinance(financeAddr);
    await instanceSubs.setFinance(financeAddr);
    await instanceSpMinter.setFinance(financeAddr);
    await instanceSubsMinter.setFinance(financeAddr);

  })

}
