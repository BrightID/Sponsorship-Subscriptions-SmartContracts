pragma solidity 0.5.0;

import "./Sponsorships.sol";
import "./FinanceManager.sol";


/**
* @title Sponsorships minter contract
*/
contract SponsorshipsMinter is FinanceManager {
    Sponsorships internal sp;

    uint256 public totalSold;

    ERC20 public purchaseToken;
    uint256 public price;

    string private constant INSUFFICIENT_PAYMENT = "Insufficient payment.";
    string private constant MINT_ERROR = "Mint error.";
    string private constant TRANSFER_FROM_ERROR = "Purchase token transferFrom failed.";
    string private constant FINANCE_MESSAGE = "Revenue of Sponsorships sale.";
    string private constant INVALID_PRICE = "Price must be greater than zero.";
    string private constant IS_NOT_CONTRACT = "Address doesn't belong to a smart contract.";

    event SponsorshipsPurchased(address account, uint256 amount, uint256 price);
    event PurchaseTokenSet(address purchaseTokenAddr);
    event PriceSet(uint256 price);

    constructor(Sponsorships _sp, ERC20 _purchaseToken)
        public
    {
        sp = _sp;
        purchaseToken = _purchaseToken;
        // The initial price is one.
        price = 10**18;
    }

    /**
    * @notice Set the ERC20 token used as payment for Sponsorships.
    * @dev Set the ERC20 token used as payment for Sponsorships.
    * @param _purchaseToken The token used for payments.
    */
    function setPurchaseToken(ERC20 _purchaseToken)
        external
        onlyOwner
    {
        require(address(_purchaseToken).isContract(), IS_NOT_CONTRACT);

        purchaseToken = _purchaseToken;
        emit PurchaseTokenSet(address(_purchaseToken));
    }

    /**
    * @notice Set the price per Sponsorship.
    * @dev Set the price per Sponsorship.
    * @param _price price per Sponsorship.
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
    * @notice Purchase Sponsorships.
    * @dev Purchase Sponsorships.
    */
    function purchase()
        external
        returns (bool success)
    {
        uint256 allowance = purchaseToken.allowance(msg.sender, address(this));
        require(price <= allowance, INSUFFICIENT_PAYMENT);

        uint256 spAmount = allowance.div(price);
        uint256 purchaseTokenAmount = spAmount.mul(price);
        totalSold = totalSold.add(spAmount);
        require(purchaseToken.transferFrom(msg.sender, address(this), purchaseTokenAmount), TRANSFER_FROM_ERROR);

        deposit(purchaseToken, purchaseTokenAmount, FINANCE_MESSAGE);
        require(sp.mint(msg.sender, spAmount), MINT_ERROR);

        emit SponsorshipsPurchased(msg.sender, spAmount, price);
        return true;
    }

    /**
    * @notice Disable purchases.
    * @dev Renounce minter.
    */
    function disablePurchases()
        external
        onlyOwner
    {
        sp.renounceMinter();
    }

}
