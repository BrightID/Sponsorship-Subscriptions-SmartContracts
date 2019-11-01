pragma solidity ^0.5.0;

import "/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "/openzeppelin-solidity/contracts/access/roles/MinterRole.sol";

/**
 * @dev Copied from https://github.com/BrightID/Sponsorship-Subscriptions-SmartContracts/blob/master/node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol
 * omitting parts related to transferring or burning tokens.
 */
contract NonTransferable is MinterRole {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    uint256 private _totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a `Transfer` event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "NonTransferableToken: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
}
