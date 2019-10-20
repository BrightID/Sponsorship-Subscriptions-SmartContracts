pragma solidity ^0.5.0;

import "/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./Sponsorships.sol";
import "./Finance.sol";
import "./CanReclaimToken.sol";


/**
* @title Sponsorships minter contract
*/
contract SponsorshipsMinter is CanReclaimToken {
    using SafeMath for uint256;

    Sponsorships internal sp;
    ERC20 internal purchaseToken;

    uint256 public price;

    string private constant INSUFFICIENT_PAYMENT = "Insufficient payment";
    string private constant APPROVE_ERROR = "Approve error";
    string private constant MINT_ERROR = "Mint error";
    string private constant FINANCE_MESSAGE = "Revenue of Sponsorships Sale";
    string private constant INVALID_PRICE = "Price must be greater than zero";
    string private constant IS_NOT_CONTRACT = "It is not a contract's address";

    event SponsorshipsPurchased(address account, uint256 price);
    event PurchaseTokenSet(address purchaseTokenAddr);
    event PriceSet(uint256 price);

    constructor(address spAddr, address purchaseTokenAddr, address financeAddr)
        public
    {
        sp = Sponsorships(spAddr);
        finance = Finance(financeAddr);
        purchaseToken = ERC20(purchaseTokenAddr);
        price = 10**18;
    }

    /**
    * @notice Accept new token as payment token
    * @dev Set new ERC20 token as payment token
    * @param purchaseTokenAddr The address of new payment token contract
    */
    function setPurchaseToken(address purchaseTokenAddr)
        external
        onlyOwner
    {
        require(isContract(purchaseTokenAddr), IS_NOT_CONTRACT);

        purchaseToken = ERC20(purchaseTokenAddr);
        emit PurchaseTokenSet(purchaseTokenAddr);
    }

    /**
    * @notice Set new price
    * @dev Set the Sponsorship is worth how many purchase token
    * @param _price one Sponsorship price
    */
    function setPrice(uint256 _price)
        external
        onlyOwner
    {
        require(0 < _price, INVALID_PRICE);

        price = _price;
        emit PriceSet(price);
    }

    /**
    * @notice Purchase Sponsorship
    * @dev Purchase Sponsorship token
    */
    function purchase()
        external
        returns (bool success)
    {
        uint256 allowance = purchaseToken.allowance(msg.sender, address(this));
        require(price <= allowance, INSUFFICIENT_PAYMENT);

        uint256 spAmount = allowance.div(price);
        uint256 purchaseTokenAmount = spAmount.mul(price);

        if (purchaseToken.transferFrom(msg.sender, address(this), purchaseTokenAmount)) {
            require(purchaseToken.approve(address(finance), purchaseTokenAmount), APPROVE_ERROR);

            finance.deposit(address(purchaseToken), purchaseTokenAmount, FINANCE_MESSAGE);
            emit SponsorshipsPurchased(msg.sender, spAmount);
            require(sp.mint(msg.sender, spAmount), MINT_ERROR);

            return true;
        }
        return false;
    }

    /**
    * @notice Disable purchases
    * @dev Renounce minter role
    */
    function disablePurchases()
        external
        onlyOwner
    {
        sp.renounceMinter();
    }

}
