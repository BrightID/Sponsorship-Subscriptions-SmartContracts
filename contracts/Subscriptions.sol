pragma solidity ^0.5.0;

import "./NonTransferableCapped.sol";
import "./CanReclaimToken.sol";


/**
* @title Subscriptions contract
*/
contract Subscriptions is NonTransferableCapped, CanReclaimToken {
    string public constant name = "Subscriptions";
    string public constant symbol = "Subs";
    uint8 public constant decimals = 0;

    string private constant ALL_SPONSORSHIPS_CLAIMED = "All Sponsorships claimed";
    string private constant INVALID_AMOUNT = "Amount must be greater than zero";

    struct Account {
        uint256 received;
        uint256[] timestamps;
        mapping (uint256 => uint256) batches;
    }

    mapping(address => Account) private accounts;

    constructor(uint256 _cap) NonTransferableCapped(_cap) public {}

    /**
    * @notice Mint Subscriptions
    * @dev Mint Subscriptions token
    * @param account The receiver account
    * @param amount The number of Subscriptions
    */
    function mint(address account, uint256 amount)
        public
        onlyMinter
        whenNotPaused
        onlyPositive(amount)
        returns (bool)
    {
        uint256 timestamp = now;
        accounts[account].timestamps.push(timestamp);
        accounts[account].batches[timestamp] = amount;
        _mint(account, amount);
        return true;
    }

    /**
    * @notice Claim Sponsorships
    * @dev Claim Sponsorships tokens
    * @param account The claimer account
    */
    function claim(address account)
        external
        onlyMinter
        whenNotPaused
        returns (uint256 amount)
    {
        uint256 claimableAmount = claimable(account);
        require(0 < claimableAmount, ALL_SPONSORSHIPS_CLAIMED);

        accounts[account].received += claimableAmount;
        return claimableAmount;
    }

    /**
    * @notice Count claimable Sponsorships amount
    * @dev Count claimable Sponsorships token amount
    * @param account The claimer account
    */
    function claimable(address account)
        public
        view
        returns (uint256 amount)
    {
        uint256 allProduced;

        for (uint i = 0; i < accounts[account].timestamps.length; i++) {
            uint256 timestamp = accounts[account].timestamps[i];
            uint256 batch = accounts[account].batches[timestamp];
            // Start with one claimable sponsorship immediately.
            uint256 m = ((now - timestamp) / (30*24*3600)) + 1;
            // Subscriptions end after 252 sponsorships (a little less than 6 years).
            if (72 < m) {
                m = 72;
            }
            uint256 y = m / 12;
            uint256 produced = 6 * y * (y + 1) + (m % 12) * (y + 1);
            allProduced += (produced * batch);
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
