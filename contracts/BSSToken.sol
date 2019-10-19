pragma solidity ^0.5.0;

import "./NonTransferAbleCapped.sol";
import "./CanReclaimToken.sol";


/**
 * @title BSST contract.
 */
contract BSSToken is NonTransferAbleCapped, CanReclaimToken {
    string public constant name = "BrightID Sponsorship Subscription Token";
    string public constant symbol = "BSST";
    uint8 public constant decimals = 0;

    string private constant ALL_TOKENS_CLAIMED = "All tokens claimed";
    string private constant INVALID_AMOUNT = "Amount must be greater than zero";

    struct Account {
        uint256 received;
        uint256[] timestamps;
        mapping (uint256 => uint256) batches;
    }

    mapping(address => Account) private accounts;

    constructor(uint256 _cap) ERC20Capped(_cap) public {}

    /**
     * @notice Mint BSST.
     * @param account The receiver account.
     * @param amount number of BSST.
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
     * @notice claim BST
     * @param account The account.
     */
    function claim(address account)
        external
        onlyMinter
        returns (uint256 amount)
    {
        uint256 claimableAmount = claimable(account);
        require(0 < claimableAmount, ALL_TOKENS_CLAIMED);

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
     * @dev Throws if the number is not bigger than zero.
     * @param number The number to validate.
     */
    modifier onlyPositive(uint number) {
        require(0 < number, INVALID_AMOUNT);
        _;
    }

}
