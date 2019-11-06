pragma solidity ^0.5.0;

import "/openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "/openzeppelin-solidity/contracts/utils/Address.sol";
import "./Finance.sol";

contract FinanceManager is Ownable {
    using Address for address;
    Finance public finance;

    string private constant APPROVE_ERROR = "Approve error.";
    string private constant RECLAIM_MESSAGE = "Reclaiming tokens sent by mistake.";
    string private constant IS_NOT_CONTRACT = "Address doesn't belong to a smart contract.";
    string private constant ZERO_BALANCE = "There are no tokens of this type to be reclaimed.";

    event ClaimedTokens(address tokenAddr, uint256 amount);
    event FinanceSet(address financeAddr);

    /**
    * @notice Set the DAO finance app address where deposited or reclaimed tokens will go.
    * @param financeAddr Address of a DAO's finance app with a deposit() function.
    */
    function setFinance(address financeAddr)
        public
        onlyOwner
    {
        require(financeAddr.isContract(), IS_NOT_CONTRACT);

        finance = Finance(financeAddr);
        emit FinanceSet(financeAddr);
    }

    /**
    * @notice Reclaim tokens of the specified type sent to the smart contract.
    * @dev Reclaim the specified type of ERC20 tokens sent to the smart contract.
    * Tokens will be deposited into the finance app set with setFinance(). 
    * @param tokenAddr Address of the token contract.
    */
    function reclaimTokens(address tokenAddr)
        external
        onlyOwner
    {
        require(tokenAddr.isContract(), IS_NOT_CONTRACT);

        ERC20 token = ERC20(tokenAddr);
        uint256 balance = token.balanceOf(address(this));
        require(0 < balance, ZERO_BALANCE);

        deposit(address(tokenAddr), balance, RECLAIM_MESSAGE);
        emit ClaimedTokens(tokenAddr, balance);
    }

    /**
    * @notice Deposit tokens of the specified type.
    * @dev Deposit the specified type of ERC20 tokens using the finance app set
    * with setFinance().
    * @param tokenAddr Address of the token contract.
    * @param amount Number of tokens to deposit.
    * @param _reference Reason for the deposit.
    */
    function deposit(address tokenAddr, uint256 amount, string memory _reference)
        internal
    {
        ERC20 token = ERC20(tokenAddr);
        require(token.approve(address(finance), amount), APPROVE_ERROR);

        finance.deposit(tokenAddr, amount, _reference);
    }

}
