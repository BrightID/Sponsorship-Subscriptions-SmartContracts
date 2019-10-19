pragma solidity ^0.5.0;

import "/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./Sponsorships.sol";
import "./Subscriptions.sol";
import "./Finance.sol";
import "./CanReclaimToken.sol";


/**
 * @title Subscriptions minter contract.
 */
contract SubscriptionsMinter is CanReclaimToken {
    using SafeMath for uint256;

    Subscriptions internal subs;
    ERC20 internal purchaseToken;

    uint256 public cap;

    string private constant INSUFFICIENT_PAYMENT = "Insufficient payment";
    string private constant APPROVE_ERROR = "Approve error";
    string private constant MINT_ERROR = "Mint error";
    string private constant FINANCE_MESSAGE = "Revenue of Subscriptions sale";
    string private constant CAP_EXCEEDED = "Cap exceeded";

    struct Step {
        uint256 border;
        uint256 price;
    }

    mapping(uint8 => Step) private steps;

    event SubscriptionsPurchased(address account, uint256 price);

    constructor(address subsAddr, address purchaseTokenAddr, address financeAddr)
        public
    {
        steps[0].border = 400000;
        steps[0].price = 10**18;
        steps[1].border = 900000;
        steps[1].price = 2 * 10**18;
        subs = Subscriptions(subsAddr);
        finance = Finance(financeAddr);
        purchaseToken = ERC20(purchaseTokenAddr);
        cap = subs.cap();
    }

    /**
     * @notice Purchase Subscriptions.
     */
    function purchase()
        external
        returns (bool success)
    {
        uint8 stepNumber;
        uint256 totalSupply = subs.totalSupply();
        require(totalSupply < cap, CAP_EXCEEDED);

        uint256 allowance = purchaseToken.allowance(msg.sender, address(this));
        if (totalSupply < steps[0].border) {
            stepNumber = 0;
        }
        else {
            stepNumber = 1;
        }
        uint256 price = steps[stepNumber].price;
        require(price <= allowance, INSUFFICIENT_PAYMENT);

        uint256 availableSubs = steps[stepNumber].border - totalSupply;
        uint256 subsAmount = allowance.div(price);
        if (availableSubs < subsAmount) {
            subsAmount = availableSubs;
        }
        uint256 purchaseTokenAmount = subsAmount.mul(price);
        if (purchaseToken.transferFrom(msg.sender, address(this), purchaseTokenAmount)) {
            require(purchaseToken.approve(address(finance), purchaseTokenAmount), APPROVE_ERROR);

            finance.deposit(address(purchaseToken), purchaseTokenAmount, FINANCE_MESSAGE);
            emit SubscriptionsPurchased(msg.sender, subsAmount);
            require(subs.mint(msg.sender, subsAmount), MINT_ERROR);

            return true;
        }
        return false;
    }

    /**
     * @notice Get current Subscriptions price.
     */
    function price()
        external
        view
        returns (uint256)
    {
        uint256 totalSupply = subs.totalSupply();
        if (totalSupply < steps[0].border) {
            return steps[0].price;
        }
        return steps[1].price;
    }

}
