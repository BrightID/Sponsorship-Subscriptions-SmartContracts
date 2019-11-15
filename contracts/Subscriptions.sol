pragma solidity 0.5.0;

import "/openzeppelin-solidity/contracts/token/ERC20/ERC20Pausable.sol";
import "/openzeppelin-solidity/contracts/access/roles/MinterRole.sol";
import "./FinanceManager.sol";


/**
* @title Subscriptions contract
*/
contract Subscriptions is ERC20Pausable, MinterRole, FinanceManager {
    string public constant name = "Subscriptions";
    string public constant symbol = "Subs";
    uint8 public constant decimals = 0;

    string private constant ALL_SPONSORSHIPS_CLAIMED = "All Sponsorships claimed";
    string private constant INVALID_AMOUNT = "Amount must be greater than zero";

    struct Account {
        uint256 received;
        // Array to keep track of timestamps for the batches.
        uint256[] timestamps;
        // Batches mapped from timestamps to amounts.
        mapping (uint256 => uint256) batches;
    }

    mapping(address => Account) private accounts;

    event SubscriptionsActivated(address account, uint256 amount);

    /**
    * @notice Mint Subscriptions.
    * @dev Mint Subscriptions.
    * @param account The receiver's account address.
    * @param amount The number of Subscriptions.
    */
    function mint(address account, uint256 amount)
        public
        onlyMinter
        whenNotPaused
        onlyPositive(amount)
        returns (bool)
    {
        _mint(account, amount);
        return true;
    }

    /**
    * @notice Activate Subscriptions.
    * @dev Activate Subscriptions.
    * @param amount The number of Subscriptions.
    */
    function activate(uint256 amount)
        public
        whenNotPaused
        onlyPositive(amount)
        returns (bool)
    {
        uint256 timestamp = now;
        accounts[msg.sender].timestamps.push(timestamp);
        accounts[msg.sender].batches[timestamp] = amount;
        _burn(msg.sender, amount);
        emit SubscriptionsActivated(msg.sender, amount);
        return true;
    }

    /**
    * @notice Tells the minter how many Sponsorships the account holder can claim.
    * @dev Tells the minter how many Sponsorships the account holder can claim so it can
    * then mint them. Also increments the account's "received" counter to indicate the
    * number of Sponsorships that have been claimed.
    * @param account The claimer's account address.
    * @return The number of Sponsorships the account holder can claim.
    */
    function claim(address account)
        external
        onlyMinter
        whenNotPaused
        returns (uint256 amount)
    {
        uint256 claimableAmount = claimable(account);
        require(0 < claimableAmount, ALL_SPONSORSHIPS_CLAIMED);

        accounts[account].received = accounts[account].received.add(claimableAmount);
        return claimableAmount;
    }

    /**
    * @notice Computes the number of Sponsorships the account holder can claim.
    * @dev Computes the number of Sponsorships the account holder can claim.
    * @param account The claimer's account address.
    * @return The number of Sponsorships the account holder can claim.
    */
    function claimable(address account)
        public
        view
        returns (uint256 amount)
    {
        // The number of Sponsorships produced by all of this account's batches.
        uint256 allProduced;

        // Loop through all the batches.
        for (uint i = 0; i < accounts[account].timestamps.length; i++) {
            uint256 timestamp = accounts[account].timestamps[i];
            // The number of Subscriptions purchased in the batch that matches the timestamp.
            uint256 subsInBatch = accounts[account].batches[timestamp];
            // "months" is the number of whole 30-day periods since the batch was purchased (plus one).
            // We add one because we want each Subscription to start with one claimable sponsorship immediately.
            uint256 months = ((now - timestamp) / (30*24*3600)) + 1;
            // Subscriptions end after 71 30-day periods (a little less than 6 years).
            if (72 < months) {
                months = 72;
            }
            uint256 _years = months / 12;
            // One Subscription produces 252 Sponsorships in total.
            uint256 producedPerSub = 6 * _years * (_years + 1) + (months % 12) * (_years + 1);
            allProduced += (producedPerSub * subsInBatch);
        }
        uint256 claimableAmount = allProduced - accounts[account].received;
        return claimableAmount;
    }

    /**
    * @dev Throws if the number is not bigger than zero
    * @param number The number to validate
    */
    modifier onlyPositive(uint number) {
        require(0 < number, INVALID_AMOUNT);
        _;
    }

}
