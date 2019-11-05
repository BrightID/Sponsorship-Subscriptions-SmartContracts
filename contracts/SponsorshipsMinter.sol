pragma solidity ^0.5.0;

import "/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "/openzeppelin-solidity/contracts/utils/Address.sol";
import "./Sponsorships.sol";
import "./Finance.sol";
import "./CanReclaimToken.sol";


/**
* @title Sponsorships minter contract
*/
contract SponsorshipsMinter is CanReclaimToken {
    using SafeMath for uint256;
    using Address for address;

    Sponsorships internal sp;
    ERC20 internal purchaseToken;

    uint256 public price;

    string private constant INSUFFICIENT_PAYMENT = "Insufficient payment.";
    string private constant APPROVE_ERROR = "Approve error.";
    string private constant MINT_ERROR = "Mint error.";
    string private constant FINANCE_MESSAGE = "Revenue of Sponsorships sale.";
    string private constant INVALID_PRICE = "Price must be greater than zero.";
    string private constant IS_NOT_CONTRACT = "Address doesn't belong to a smart contract.";

    event SponsorshipsPurchased(address account, uint256 price);
    event PurchaseTokenSet(address purchaseTokenAddr);
    event PriceSet(uint256 price);

    constructor(address spAddr, address purchaseTokenAddr, address financeAddr)
        public
    {
        sp = Sponsorships(spAddr);
        finance = Finance(financeAddr);
        purchaseToken = ERC20(purchaseTokenAddr);
        // The initial price is one.
        price = 10**18;
    }

    /**
    * @notice Set the ERC20 token used as payment for Sponsorships.
    * @dev Set the ERC20 token used as payment for Sponsorships.
    * @param purchaseTokenAddr The address of the smart contract of the token used for payments.
    */
    function setPurchaseToken(address purchaseTokenAddr)
        external
        onlyOwner
    {
        require(purchaseTokenAddr.isContract(), IS_NOT_CONTRACT);

        purchaseToken = ERC20(purchaseTokenAddr);
        emit PurchaseTokenSet(purchaseTokenAddr);
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

        if (purchaseToken.transferFrom(msg.sender, address(this), purchaseTokenAmount)) {
            deposit(address(purchaseToken), purchaseTokenAmount, FINANCE_MESSAGE);
            emit SponsorshipsPurchased(msg.sender, spAmount);
            require(sp.mint(msg.sender, spAmount), MINT_ERROR);

            return true;
        }
        return false;
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
