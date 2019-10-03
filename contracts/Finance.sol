pragma solidity ^0.5.0;


/**
 * @title Finance interface.
 */
contract Finance {
    function deposit(address _token, uint256 _amount, string calldata _reference) external payable;
}
