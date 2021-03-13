// SPDX-License-Identifier: BSD 2-Clause "Simplified" License

pragma solidity >=0.6.0 <0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/math/SafeMath.sol";
import "./IdSponsorships.sol";
import "./IdSubscriptions.sol";
import "./FinanceManager.sol";


/**
* @title IdSponsorships minter contract
*/
contract IdSponsorshipsMinter is FinanceManager {
    using SafeMath for uint256;

    uint256 TO_WEI = 10**18;

    IdSponsorships internal idSp;
    IdSubscriptions internal idSubs;
    ERC20 public purchaseToken;

    uint256 public totalSold;
    uint256 public price;

    string private constant INSUFFICIENT_PAYMENT = "Insufficient payment.";
    string private constant MINT_ERROR = "Mint error.";
    string private constant TRANSFER_FROM_ERROR = "Purchase token transferFrom failed.";
    string private constant FINANCE_MESSAGE = "Revenue of IdSponsorships sale.";
    string private constant INVALID_PRICE = "Price must be greater than zero.";

    event IdSponsorshipsClaimed(address account, uint256 amount);
    event IdSponsorshipsPurchased(address account, uint256 amount, uint256 price);
    event PurchaseTokenSet(address purchaseTokenAddr);
    event PriceSet(uint256 price);

    constructor(IdSponsorships _idSp, IdSubscriptions _idSubs, ERC20 _purchaseToken) {
        idSp = _idSp;
        idSubs = _idSubs;
        purchaseToken = _purchaseToken;
        // The initial price is one.
        price = 10**18;
    }

    /**
    * @notice Set the ERC20 token used as payment for IdSponsorships.
    * @dev Set the ERC20 token used as payment for IdSponsorships.
    * @param _purchaseToken The token used for payments.
    */
    function setPurchaseToken(ERC20 _purchaseToken)
        external
        onlyOwner
    {
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
    * @notice Purchase IdSponsorships.
    * @dev Purchase IdSponsorships.
    */
    function purchase()
        external
        returns (bool)
    {
        uint256 allowance = purchaseToken.allowance(_msgSender(), address(this));
        require(price <= allowance, INSUFFICIENT_PAYMENT);

        uint256 spAmount = allowance.div(price);
        uint256 purchaseTokenAmount = spAmount.mul(price);
        totalSold = totalSold.add(spAmount);
        require(purchaseToken.transferFrom(_msgSender(), address(this), purchaseTokenAmount), TRANSFER_FROM_ERROR);

        deposit(purchaseToken, purchaseTokenAmount, FINANCE_MESSAGE);
        require(idSp.mint(_msgSender(), spAmount.mul(TO_WEI)), MINT_ERROR);

        emit IdSponsorshipsPurchased(_msgSender(), spAmount, price);
        return true;
    }

    /**
    * @notice claim IdSponsorships.
    * @dev claim IdSponsorships.
    */
    function claim()
        external
        returns (bool)
    {
        // First, get the number of IdSponsorships to mint from the IdSubscriptions contract.
        // This will increment a "received" counter for the account. After this is done,
        // the IdSubscriptions contract will consider these IdSponsorships to actually have
        // been received.
        uint256 claimableAmount = idSubs.claim(_msgSender());
        // Next tell the IdSponsorships contract to actually mint the correct number of
        // IdSponsorships into the claimer's account address.
        require(idSp.mint(_msgSender(), claimableAmount), MINT_ERROR);

        emit IdSponsorshipsClaimed(_msgSender(), claimableAmount);
        return true;
    }

}
