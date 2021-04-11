// SPDX-License-Identifier: BSD 2-Clause "Simplified" License

pragma solidity >=0.6.0 <0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/token/ERC20/ERC20Burnable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/access/AccessControl.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/math/SafeMath.sol";


/**
 * @title IdSubscriptions contract
 */
contract IdSubscriptions is ERC20, ERC20Burnable, AccessControl {
    using SafeMath for uint256;

    uint256 public activated;

    uint256 public constant SCALE = 1e18;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    string private constant ALL_SPONSORSHIPS_CLAIMED = "All Sponsorships claimed";
    string private constant INVALID_AMOUNT = "Amount must be greater than zero";
    string private constant UNAUTHORIZED_MINTER = "Caller is not a minter";


    struct Account {
        uint256 received;
        // Array to keep track of timestamps for the batches.
        uint256[] timestamps;
        // Batches mapped from timestamps to amounts.
        mapping (uint256 => uint256) batches;
    }

    mapping(address => Account) private accounts;

    event IdSubscriptionsActivated(address indexed account, uint256 amount);

    constructor()
        ERC20("IdSubscriptions", "IdSubs")
    {
        activated = 0;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /**
     * @notice Mint IdSubscriptions.
     * @dev Mint IdSubscriptions.
     * @param account The receiver's account address.
     * @param amount The number of IdSubscriptions.
     */
    function mint(address account, uint256 amount)
        public
        onlyPositive(amount)
        returns (bool)
    {
        require(hasRole(MINTER_ROLE, _msgSender()), UNAUTHORIZED_MINTER);

        _mint(account, amount);
        return true;
    }

    /**
     * @notice Activate IdSubscriptions.
     * @dev Activate IdSubscriptions.
     * @param amount The number of IdSubscriptions.
     */
    function activate(uint256 amount)
        public
        onlyPositive(amount)
        returns (bool)
    {
        uint256 intPart = amount.div(SCALE);
        require(intPart > 0, INVALID_AMOUNT);

        uint256 subsAmount = intPart.mul(SCALE);
        uint256 timestamp = block.timestamp;
        _burn(_msgSender(), subsAmount);
        activated = activated.add(subsAmount);
        accounts[_msgSender()].timestamps.push(timestamp);
        accounts[_msgSender()].batches[timestamp] = subsAmount;
        emit IdSubscriptionsActivated(_msgSender(), subsAmount);
        return true;
    }

    /**
     * @notice Tells the minter how many IdSponsorships the account holder can claim.
     * @dev Tells the minter how many IdSponsorships the account holder can claim so it can
     * then mint them. Also increments the account's "received" counter to indicate the
     * number of IdSponsorships that have been claimed.
     * @param account The claimer's account address.
     * @return claimableAmount The number of IdSponsorships the account holder can claim.
     */
    function claim(address account)
        external
        returns (uint256)
    {
        require(hasRole(MINTER_ROLE, _msgSender()), UNAUTHORIZED_MINTER);

        uint256 claimableAmount = claimable(account);
        require(0 < claimableAmount, ALL_SPONSORSHIPS_CLAIMED);

        accounts[account].received = accounts[account].received.add(claimableAmount);
        return claimableAmount;
    }

    /**
     * @notice Computes the number of IdSponsorships the account holder can claim.
     * @dev Computes the number of IdSponsorships the account holder can claim.
     * @param account The claimer's account address.
     * @return claimableAmount The number of IdSponsorships the account holder can claim.
     */
    function claimable(address account)
        public
        view
        returns (uint256)
    {
        // The number of Sponsorships produced by all of this account's batches.
        uint256 allProduced;

        // Loop through all the batches.
        for (uint8 i = 0; i < accounts[account].timestamps.length; i++) {
            uint256 timestamp = accounts[account].timestamps[i];
            // The number of IdSubscriptions purchased in the batch that matches the timestamp.
            uint256 subsInBatch = accounts[account].batches[timestamp].div(SCALE);
            // "months" is the number of whole 30-day periods since the batch was purchased (plus one).
            // We add one because we want each Subscription to start with one claimable sponsorship immediately.
            uint256 months = ((block.timestamp - timestamp) / (30*24*3600)) + 1;
            // IdSubscriptions end after 71 30-day periods (a little less than 6 years).
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
