pragma solidity 0.5.0;

import "/openzeppelin-solidity/contracts/token/ERC20/ERC20Pausable.sol";
import "/openzeppelin-solidity/contracts/access/roles/MinterRole.sol";
import "/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./FinanceManager.sol";


/**
* @title Sponsorships contract
*/
contract Sponsorships is ERC20Pausable, MinterRole, FinanceManager {
     using SafeMath for uint256;

    string public constant name = "Sponsorships";
    string public constant symbol = "Sp";
    uint8 public constant decimals = 0;

    string private constant INSUFFICIENT_BALANCE = "Insufficient balance";
    string private constant INVALID_AMOUNT = "Amount must be greater than zero";

    struct Account {
        mapping (bytes32 => uint256) contexts;
    }

    mapping(address => Account) private accounts;

    mapping(bytes32 => uint256) private contextsBalance;

    event SponsorshipsAssigned(address account, bytes32 contextName, uint256 amount);

    /**
    * @notice Mint Sponsorships.
    * @dev Mint Sponsorships.
    * @param account The receiver's account.
    * @param amount The number of Sponsorships.
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
    * @notice Assign Sponsorships to the context.
    * @dev Assign Sponsorships to the context.
    * @param contextName The context's name.
    * @param amount The number of Sponsorships.
    */
    function assignContext(bytes32 contextName, uint256 amount)
        external
        whenNotPaused
        onlyPositive(amount)
    {
        require(amount <= balanceOf(msg.sender), INSUFFICIENT_BALANCE);

        accounts[msg.sender].contexts[contextName] = accounts[msg.sender].contexts[contextName].add(amount);
        contextsBalance[contextName] = contextsBalance[contextName].add(amount);
        _burn(msg.sender, amount);
        emit SponsorshipsAssigned(msg.sender, contextName, amount);
    }

    /**
    * @notice Returns the number of Sponsorships assigned to the context.
    * @dev Returns the number of Sponsorships assigned to the context.
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
    * @notice Returns the number of Sponsorships assigned by the account to the context.
    * @dev Returns the number of Sponsorships assigned by the account to the context.
    * @param account The assigner's address.
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
    * @dev Throws if the number is not bigger than zero.
    * @param number The number to validate.
    */
    modifier onlyPositive(uint number) {
        require(0 < number, INVALID_AMOUNT);
        _;
    }

}
