pragma solidity ^0.5.0;

import "./NonTransferAble.sol";

/**
 * @dev Extension of `NonTransferAble` that adds a cap to the supply of tokens.
 */
contract NonTransferAbleCapped is NonTransferAble {
    uint256 private _cap;

    /**
     * @dev Sets the value of the `cap`. This value is immutable, it can only be
     * set once during construction.
     */
    constructor (uint256 cap) public {
        require(cap > 0, "NonTransferAbleTokenCapped: cap is 0");
        _cap = cap;
    }

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view returns (uint256) {
        return _cap;
    }

    /**
     * @dev See `NonTransferAbleToken.mint`.
     *
     * Requirements:
     *
     * - `value` must not cause the total supply to go over the cap.
     */
    function _mint(address account, uint256 value) internal {
        require(totalSupply().add(value) <= _cap, "NonTransferAbleTokenCapped: cap exceeded");
        super._mint(account, value);
    }

}
