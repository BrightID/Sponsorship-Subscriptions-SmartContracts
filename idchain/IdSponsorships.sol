// SPDX-License-Identifier: BSD 2-Clause "Simplified" License

pragma solidity >=0.6.0 <0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/token/ERC20/ERC20Burnable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/access/AccessControl.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/math/SafeMath.sol";


/**
 * @title IdSponsorships contract
 */
contract IdSponsorships is ERC20, ERC20Burnable, AccessControl {
    using SafeMath for uint256;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    string private constant INSUFFICIENT_BALANCE = "Insufficient balance";
    string private constant INVALID_AMOUNT = "Amount must be greater than zero";
    string private constant UNAUTHORIZED_MINTER = "Caller is not a minter";

    struct Account {
        mapping (bytes32 => uint256) contexts;
    }

    mapping(address => Account) private accounts;

    mapping(bytes32 => uint256) private contextsBalance;

    event IdSponsorshipsAssigned(address account, bytes32 contextName, uint256 amount);

    constructor()
        ERC20("IdSponsorships", "IdSp")
    {
        _setupDecimals(0);
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /**
     * @notice Mint IdSponsorships.
     * @dev Mint IdSponsorships.
     * @param account The receiver's account.
     * @param amount The number of IdSponsorships.
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
     * @notice Assign IdSponsorships to the context.
     * @dev Assign IdSponsorships to the context.
     * @param contextName The context's name.
     * @param amount The number of IdSponsorships.
     */
    function assignContext(bytes32 contextName, uint256 amount)
        external
        onlyPositive(amount)
    {
        require(amount <= balanceOf(_msgSender()), INSUFFICIENT_BALANCE);

        _burn(_msgSender(), amount);
        accounts[_msgSender()].contexts[contextName] = accounts[_msgSender()].contexts[contextName].add(amount);
        contextsBalance[contextName] = contextsBalance[contextName].add(amount);
        emit IdSponsorshipsAssigned(_msgSender(), contextName, amount);
    }

    /**
     * @notice Returns the number of IdSponsorships assigned to the context.
     * @dev Returns the number of IdSponsorships assigned to the context.
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
     * @notice Returns the number of IdSponsorships assigned by the account to the context.
     * @dev Returns the number of IdSponsorships assigned by the account to the context.
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
