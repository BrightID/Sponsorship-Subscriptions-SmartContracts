pragma solidity 0.5.0;

import "./Sponsorships.sol";
import "./Subscriptions.sol";
import "./FinanceManager.sol";


/**
* @title Subscriptions minter contract
*/
contract SubscriptionsMinter is FinanceManager {
    Subscriptions internal subs;
    Sponsorships internal sp;

    uint256 public totalSold;

    ERC20 public purchaseToken;

    // This needs to match the total number of Subscriptions in all steps.
    uint256 public constant CAP = 900000;

    string private constant INSUFFICIENT_PAYMENT = "Insufficient payment";
    string private constant MINT_ERROR = "Mint error";
    string private constant TRANSFER_FROM_ERROR = "Purchase token transferFrom failed.";
    string private constant FINANCE_MESSAGE = "Revenue of Subscriptions sale";
    string private constant CAP_EXCEEDED = "Cap exceeded";

    // The price of Subscriptions is a step function of the number of Subscriptions
    // already sold.

    struct Step {
        uint256 border;
        uint256 price;
    }

    // Each step of the price function is numbered, starting from zero.
    mapping(uint8 => Step) private steps;

    event SubscriptionsPurchased(address account, uint256 amount, uint256 price);
    event SponsorshipsClaimed(address account, uint256 amount);

    constructor(Sponsorships _sp, Subscriptions _subs, ERC20 _purchaseToken)
        public
    {
        // Define the steps for the price of Subscriptions.
        steps[0].border = 400000;
        steps[0].price = 10**18;
        steps[1].border = 900000;
        steps[1].price = 2 * 10**18;

        sp = _sp;
        subs = _subs;
        purchaseToken = _purchaseToken;
    }

    /**
    * @notice Purchase Subscriptions.
    * @dev Purchase Subscriptions.
    */
    function purchase()
        external
        returns (bool success)
    {
        uint8 stepNumber;
        require(totalSold < CAP, CAP_EXCEEDED);

        uint256 allowance = purchaseToken.allowance(msg.sender, address(this));
        if (totalSold < steps[0].border) {
            stepNumber = 0;
        }
        else {
            stepNumber = 1;
        }
        uint256 price = steps[stepNumber].price;
        require(price <= allowance, INSUFFICIENT_PAYMENT);

        uint256 availableSubs = steps[stepNumber].border.sub(totalSold);
        uint256 subsAmount = allowance.div(price);
        // Only sell the Subscriptions left in the current step. If the user wants to buy
        // more Subscriptions from the next step, they will have to make another purchase.
        if (availableSubs < subsAmount) {
            subsAmount = availableSubs;
        }
        totalSold = totalSold.add(subsAmount);
        uint256 purchaseTokenAmount = subsAmount.mul(price);
        require(purchaseToken.transferFrom(msg.sender, address(this), purchaseTokenAmount), TRANSFER_FROM_ERROR);

        deposit(purchaseToken, purchaseTokenAmount, FINANCE_MESSAGE);
        require(subs.mint(msg.sender, subsAmount), MINT_ERROR);

        emit SubscriptionsPurchased(msg.sender, subsAmount, price);
        return true;
    }

    /**
    * @notice Show the current price of one Subscription.
    * @dev Show the current price of one Subscription.
    */
    function price()
        external
        view
        returns (uint256)
    {
        if (totalSold < steps[0].border) {
            return steps[0].price;
        }
        return steps[1].price;
    }

    /**
    * @notice claim Sponsorships.
    * @dev claim Sponsorships.
    */
    function claim()
        external
        returns (bool success)
    {
        // First, get the number of Sponsorships to mint from the Subscriptions contract.
        // This will increment a "received" counter for the account. After this is done,
        // the Subscriptions contract will consider these Sponsorships to actually have
        // been received.
        uint256 claimableAmount = subs.claim(msg.sender);
        // Next tell the Sponsorships contract to actually mint the correct number of
        // Sponsorships into the claimer's account address.
        require(sp.mint(msg.sender, claimableAmount), MINT_ERROR);

        emit SponsorshipsClaimed(msg.sender, claimableAmount);
        return true;
    }

    /**
    * @notice Disable purchases
    * @dev Renounce minter
    */
    function disablePurchases()
        external
        onlyOwner
    {
        subs.renounceMinter();
    }

    /**
    * @notice Disable claims
    * @dev Renounce minter
    */
    function disableClaims()
        external
        onlyOwner
    {
        sp.renounceMinter();
    }

}
