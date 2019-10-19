pragma solidity ^0.5.0;

import "./NonTransferAbleCapped.sol";
import "./CanReclaimToken.sol";


/**
 * @title Subscriptions contract.
 */
contract Subscriptions is NonTransferAbleCapped, CanReclaimToken {
    string public constant name = "Subscriptions";
    string public constant symbol = "SUBS";
    uint8 public constant decimals = 0;

    address public spMinterAddr;

    string private constant ALL_SPONSORSHIPS_CLAIMED = "All Sponsorships claimed";
    string private constant INVALID_AMOUNT = "Amount must be greater than zero";
    string private constant ONLY_SPMINTER = "Caller is not the SponsorshipsMinter";

    struct Account {
        uint256 received;
        uint256[] timestamps;
        mapping (uint256 => uint256) batches;
    }

    mapping(address => Account) private accounts;

    constructor(uint256 _cap) NonTransferAbleCapped(_cap) public {}

    /**
     * @notice Set SponsorshipsMinter address.
     * @param _spMinterAddr SponsorshipsMinter's smart contract address.
     */
    function setSpMinter(address _spMinterAddr)
        external
        onlyOwner
    {
        require(_spMinterAddr != address(0), "SponsorshipsMinter is the zero address");

        spMinterAddr = _spMinterAddr;
    }

    /**
     * @notice Mint Subscriptions.
     * @param account The receiver account.
     * @param amount number of Subscriptions.
     */
    function mint(address account, uint256 amount)
        public
        onlyMinter
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
     * @notice claim Sponsorships.
     * @param account The account.
     */
    function claim(address account)
        external
        onlySpMinter
        returns (uint256 amount)
    {
        uint256 claimableAmount = claimable(account);
        require(0 < claimableAmount, ALL_SPONSORSHIPS_CLAIMED);

        accounts[account].received += claimableAmount;
        return claimableAmount;
    }

    /**
     * @notice Count claimable amount
     * @param account The account.
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
     * @dev ONLY FOR TEST STEP. I SHOULD REMOVE IT AFTER TEST.
     */
    function timestamps(address account)
        external
        view
        returns (uint256[] memory)
    {
        return accounts[account].timestamps;
    }

    /**
     * @dev ONLY FOR TEST STEP. I SHOULD REMOVE IT AFTER TEST.
     */
    function received(address account)
        external
        view
        returns (uint256)
    {
        return accounts[account].received;
    }

    /**
     * @dev ONLY FOR TEST STEP. I SHOULD REMOVE IT AFTER TEST.
     */
    function batch(address account, uint256 timestamp)
        external
        view
        returns (uint256)
    {
        return accounts[account].batches[timestamp];
    }

    /**
     * @dev Throws if the number is not bigger than zero.
     * @param number The number to validate.
     */
    modifier onlyPositive(uint number) {
        require(0 < number, INVALID_AMOUNT);
        _;
    }

    /**
     * @dev Throws if the caller is not SponsorshipsMinter contract.
     */
    modifier onlySpMinter() {
        require(msg.sender == spMinterAddr, ONLY_SPMINTER);
        _;
    }
}
