pragma solidity ^0.5.0;

import "/openzeppelin-solidity/contracts/token/ERC20/ERC20Capped.sol";
import "./CanReclaimToken.sol";


/**
 * @title BSST contract.
  * @dev ERC20 token contract.
 */
contract BSSToken is ERC20Capped, CanReclaimToken {

    string private constant TRANSFER_ERROR = "BSST is not transferable.";
    string private constant ALL_TOKENS_CLAIMED = "All tokens claimed";
    string private constant INVALID_AMOUNT = "Amount must be greater than zero";

    string public constant name = "BrightID Sponsorship Subscription Token";
    string public constant symbol = "BSST";
    uint32 public constant decimals = 0;

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
     * @notice count claimable amount
     * @param account The account.
     */
    function claim(address account)
        public
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
        uint256 allRevenue;

        for (uint i = 0; i < accounts[account].timestamps.length; i++) {
            uint256 timestamp = accounts[account].timestamps[i];
            uint256 batch = accounts[account].batches[timestamp];
            uint256 m = (now - timestamp) / (30*24*3600);
            if (120 < m) {
                m = 120;
            }
            uint256 y = m / 12;
            uint256 revenue = 6 * y * (y + 1) + (m % 12) * (y + 1);
            allRevenue += (revenue * batch);
        }
        uint256 claimableAmount = allRevenue - accounts[account].received;
        return claimableAmount;
    }

    /**
     * @dev override inherited method to make tokens non-transferable.
     */
    function transfer(address recipient, uint256 amount)
        public
        returns (bool)
    {
        revert(TRANSFER_ERROR);
        return false;
    }

    /**
     * @dev override inherited method to make tokens non-transferable.
     */
    function approve(address spender, uint256 value)
        public
        returns (bool)
    {
        revert(TRANSFER_ERROR);
        return false;
    }

    /**
     * @dev override inherited method to make tokens non-transferable.
     */
    function transferFrom(address sender, address recipient, uint256 amount)
        public
        returns (bool)
    {
        revert(TRANSFER_ERROR);
        return false;
    }

    /**
     * @dev override inherited method to make tokens non-transferable.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        revert(TRANSFER_ERROR);
        return false;
    }

    /**
     * @dev override inherited method to make tokens non-transferable.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        revert(TRANSFER_ERROR);
        return false;
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
