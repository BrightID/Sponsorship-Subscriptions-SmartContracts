pragma solidity ^0.5.0;

import "./NonTransferable.sol";

/**
 * @dev Extension of `NonTransferable` that adds a cap to the supply of tokens.
 * Copied from https://github.com/BrightID/Sponsorship-Subscriptions-SmartContracts/blob/master/node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Capped.sol .
 */
contract NonTransferableCapped is NonTransferable {
    uint256 private _cap;

    /**
     * @dev Sets the value of the `cap`. This value is immutable, it can only be
     * set once during construction.
     */
    constructor (uint256 cap) public {
        require(cap > 0, "NonTransferableTokenCapped: cap is 0");
        _cap = cap;
    }

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view returns (uint256) {
        return _cap;
    }

    /**
     * @dev See `NonTransferableToken.mint`.
     *
     * Requirements:
     *
     * - `value` must not cause the total supply to go over the cap.
     */
    function _mint(address account, uint256 value) internal {
        require(totalSupply().add(value) <= _cap, "NonTransferableTokenCapped: cap exceeded");
        super._mint(account, value);
    }

}
