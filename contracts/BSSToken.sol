pragma solidity ^0.5.0;

import "/openzeppelin-solidity/contracts/token/ERC20/ERC20Capped.sol";


/**
 * @title BSS token contract.
  * @dev ERC20 token contract.
 */
contract BSSToken is ERC20Capped {
    string private constant TRANSFER_ERROR = "BSST is not transferable.";

    string public constant name = "BrightID Sponsorship Subscription Token";
    string public constant symbol = "BSST";
    uint32 public constant decimals = 0;

   constructor(uint256 _cap) ERC20Capped(_cap) public {}

    function transfer(address recipient, uint256 amount) public returns (bool) {
        revert(TRANSFER_ERROR);
        return false;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        revert(TRANSFER_ERROR);
        return false;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        revert(TRANSFER_ERROR);
        return false;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        revert(TRANSFER_ERROR);
        return false;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        revert(TRANSFER_ERROR);
        return false;
    }
}
