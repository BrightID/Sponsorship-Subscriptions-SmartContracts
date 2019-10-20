pragma solidity ^0.5.0;

import "/openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "./Finance.sol";


contract CanReclaimToken is Ownable {
    Finance public finance;
    ERC20 internal token;

    string private constant APPROVE_ERROR = "Approve error";
    string private constant RECLAIM_MESSAGE = "Reclaim tokens";
    string private constant IS_NOT_CONTRACT = "It is not a contract's address";
    string private constant ZERO_BALANCE = "There is no coin";

    event ClaimedTokens(address tokenAddr, uint256 amount);
    event FinanceSet(address financeAddr);

    /**
    * @notice Set new DAO to deposite revenues
    * @dev Set DAO's finance address to deposit for approved ERC20 tokens or ETH
    * @param financeAddr Address of DAO's finance
    */
    function setFinance(address financeAddr)
        external
        onlyOwner
    {
        require(isContract(financeAddr), IS_NOT_CONTRACT);

        finance = Finance(financeAddr);
        emit FinanceSet(financeAddr);
    }

    /**
    * @notice Reclaim the tokens which sent to the smart contract
    * @dev Reclaim all ERC20 tokens which sent to the smart contract
    * @param tokenAddr The address of the token contract
    */
    function reclaimTokens(address tokenAddr)
        external
        onlyOwner
    {
        require(isContract(tokenAddr), IS_NOT_CONTRACT);

        token = ERC20(tokenAddr);
        uint256 balance = token.balanceOf(address(this));
        require(0 < balance, ZERO_BALANCE);

        require(token.approve(address(finance), balance), APPROVE_ERROR);

        finance.deposit(address(tokenAddr), balance, RECLAIM_MESSAGE);
        emit ClaimedTokens(tokenAddr, balance);
    }

    /**
    * @notice Check an address belongs to the smart contract
    * @dev Check an address belongs to the smart contract
    * @param addr The Ethereum address
    */
    function isContract(address addr)
        internal
        view
        returns (bool)
    {
        uint size;
        if (addr == address(0)) {
            return false;
        }
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

}
