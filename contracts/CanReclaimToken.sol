pragma solidity ^0.5.0;

import "/openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "/openzeppelin-solidity/contracts/utils/Address.sol";
import "./Finance.sol";

contract CanReclaimToken is Ownable {
    using Address for address;
    Finance public finance;
    ERC20 internal token;

    string private constant APPROVE_ERROR = "Approve error";
    string private constant RECLAIM_MESSAGE = "Reclaim tokens";
    string private constant IS_NOT_CONTRACT = "It is not a contract's address";
    string private constant ZERO_BALANCE = "There is no coin";

    event ClaimedTokens(address tokenAddr, uint256 amount);
    event FinanceSet(address financeAddr);

    /**
    * @notice Set the DAO finance app address where reclaimed tokens will go.
    * @param financeAddr Address of a DAO's finance app with a deposit() function.
    */
    function setFinance(address financeAddr)
        external
        onlyOwner
    {
        require(financeAddr.isContract(), IS_NOT_CONTRACT);

        finance = Finance(financeAddr);
        emit FinanceSet(financeAddr);
    }

    /**
    * @notice Reclaim tokens of the specified type sent to the smart contract.
    * @dev Reclaim the specified type of ERC20 tokens sent to the smart contract.
    * Tokens will be deposited using the deposit() function of the finance app set on this contract with setFinance(). 
    * @param tokenAddr The address of the token contract.
    */
    function reclaimTokens(address tokenAddr)
        external
        onlyOwner
    {
        require(tokenAddr.isContract(), IS_NOT_CONTRACT);

        token = ERC20(tokenAddr);
        uint256 balance = token.balanceOf(address(this));
        require(0 < balance, ZERO_BALANCE);

        require(token.approve(address(finance), balance), APPROVE_ERROR);

        finance.deposit(address(tokenAddr), balance, RECLAIM_MESSAGE);
        emit ClaimedTokens(tokenAddr, balance);
    }

}
