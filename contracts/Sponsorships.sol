pragma solidity ^0.5.0;

import "./NonTransferAble.sol";
import "./CanReclaimToken.sol";


/**
 * @title Sponsorships contract.
 */
contract Sponsorships is NonTransferAble, CanReclaimToken {
    string public constant name = "Sponsorships";
    string public constant symbol = "SP";
    uint8 public constant decimals = 0;

    string private constant INSUFFICIENT_UNASSIGNED = "Insufficient unassigned balance";
    string private constant INVALID_AMOUNT = "Amount must be greater than zero";

    struct Account {
        uint256 assigned;
        uint256 unassigned;
        mapping (bytes32 => uint256) contexts;
    }

    mapping(address => Account) private accounts;

    mapping(bytes32 => uint256) private contextsBalance;

    /**
     * @notice Mint Sponsorships.
     * @param account The receiver account.
     * @param amount number of Sponsorships.
     */
    function mint(address account, uint256 amount)
        public
        onlyMinter
        onlyPositive(amount)
        returns (bool)
    {
        accounts[account].unassigned = accounts[account].unassigned.add(amount);
        _mint(account, amount);
        return true;
    }

    /**
     * @notice Assign some Sponsorships to a context.
     * @param contextName The context's name.
     * @param amount number of Sponsorships.
     */
    function assignContext(bytes32 contextName, uint256 amount)
        external
        onlyPositive(amount)
    {
        require(amount <= accounts[msg.sender].unassigned, INSUFFICIENT_UNASSIGNED);

        accounts[msg.sender].unassigned = accounts[msg.sender].unassigned.sub(amount);
        accounts[msg.sender].assigned = accounts[msg.sender].assigned.add(amount);
        accounts[msg.sender].contexts[contextName] = accounts[msg.sender].contexts[contextName].add(amount);
        contextsBalance[contextName] = contextsBalance[contextName].add(amount);
    }

    /**
     * @notice Returns the amount of Sponsorships assigned to a context.
     * @param contextName The context's name.
     */
    function totalContextBalance(bytes32 contextName)
        external
        view
        returns (uint256)
    {
        return contextsBalance[contextName];
    }

    /**
     * @notice Returns the amount of Sponsorships assigned by an account to a contextName.
     * @param account The Sponsorships holder.
     * @param contextName The context's name.
     */
    function contextBalance(address account, bytes32 contextName)
        external
        view
        returns (uint256)
    {
        return accounts[account].contexts[contextName];
    }

    /**
     * @notice Returns the amount of unassigned Sponsorships owned by the account.
     * @param account The Sponsorships holder.
     */
    function unassignedBalance(address account)
        external
        view
        returns (uint256)
    {
        return accounts[account].unassigned;
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
