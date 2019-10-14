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

    event ClaimedTokens(address tokenAddr, uint256 amount);
    event FinanceSet(address financeAddr);

    /**
     * @notice Set financeAddr as DAO finance.
     * @param financeAddr The DAO finance's address.
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
     * @dev Reclaim all ERC20 tokens
     * @param tokenAddr The address of the token contract
     */
    function reclaimToken(address tokenAddr)
        external
        onlyOwner
    {
        require(isContract(tokenAddr), IS_NOT_CONTRACT);

        token = ERC20(tokenAddr);
        uint256 balance = token.balanceOf(address(this));
        require(token.approve(address(finance), balance), APPROVE_ERROR);

        finance.deposit(address(tokenAddr), balance, RECLAIM_MESSAGE);
        emit ClaimedTokens(tokenAddr, balance);
    }

    /**
     * @notice Check an address is a contract or not
     * @param addr The address that should check
     */
    function isContract(address addr)
        internal
        view
        returns(bool)
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
