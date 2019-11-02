pragma solidity ^0.5.0;


/**
 * @title Finance interface.
 * @dev Copied from https://github.com/aragon/aragon-apps/blob/master/apps/finance/contracts/Finance.sol#L198 .
 */
contract Finance {

    /**
    * @notice Deposit Some token in the DAO
    * @dev Deposit for approved ERC20 tokens or ETH
    * @param _token Address of deposited token
    * @param _amount Amount of tokens sent
    * @param _reference Reason for payment
    */
    function deposit(address _token, uint256 _amount, string calldata _reference) external payable;
}
