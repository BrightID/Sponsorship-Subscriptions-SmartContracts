pragma solidity ^0.5.0;

import "/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "/openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./BSSToken.sol";
import "./BSToken.sol";
import "./Finance.sol";
import "./CanReclaimToken.sol";


/**
 * @title BSS token minter contract.
 */
contract BSSMinter is Ownable, CanReclaimToken {
    using SafeMath for uint256;

    BSToken internal bsToken;
    BSSToken internal bssToken;
    ERC20 internal purchaseToken;

    uint256 public constant STEP = 25000;

    string private constant INSUFFICIENT_PAYMENT = "Insufficient payment";
    string private constant APPROVE_ERROR = "Approve error";
    string private constant MINT_ERROR = "Mint error";
    string private constant FINANCE_MESSAGE = "Revenue of BSS Token Sale";
    string private constant ALL_TOKENS_CLAIMED = "All tokens claimed";

    mapping(uint256 => uint256) private prices;

    struct Account {
        uint256 received;
        uint256[] timestamps;
        mapping (uint256 => uint256) batches;
    }

    mapping(address => Account) private accounts;

    event TokensPurchased(address buyer, uint256 price);
    event TokensClaimed(address owner, uint256 amount);

    constructor(address bsTokenAddr, address bssTokenAddr, address purchaseTokenAddr, address financeAddr)
        public
    {
        prices[0] = 16 * 10**18;
        prices[1] = 25 * 10**18;
        prices[2] = 50 * 10**18;
        prices[3] = 100 * 10**18;
        bssToken = BSSToken(bssTokenAddr);
        bsToken = BSToken(bsTokenAddr);
        finance = Finance(financeAddr);
        purchaseToken = ERC20(purchaseTokenAddr);
    }

    /**
     * @notice Purchase BSS token.
     */
    function purchase()
        external
        returns (bool success)
    {
        uint256 totalSupply = bssToken.totalSupply();
        uint256 stepNumber = totalSupply.div(STEP);
        uint256 price = prices[stepNumber];
        uint256 availableTokens = (stepNumber + 1) * STEP - totalSupply;
        uint256 allowance = purchaseToken.allowance(msg.sender, address(this));
        require(price <= allowance, INSUFFICIENT_PAYMENT);

        uint256 bssAmount = allowance.div(price);
        if (availableTokens < bssAmount) {
            bssAmount = availableTokens;
        }
        uint256 purchaseAmount = bssAmount.mul(price);

        if (purchaseToken.transferFrom(msg.sender, address(this), purchaseAmount)) {
            require(purchaseToken.approve(address(finance), purchaseAmount), APPROVE_ERROR);
            finance.deposit(address(purchaseToken), purchaseAmount, FINANCE_MESSAGE);
            uint256 timestamp = now;
            accounts[msg.sender].timestamps.push(timestamp);
            accounts[msg.sender].batches[timestamp] = bssAmount;
            emit TokensPurchased(msg.sender, bssAmount);
            require(bssToken.mint(msg.sender, bssAmount), MINT_ERROR);
            return true;
        }
        return false;
    }

    /**
     * @notice Claim BS token.
     */
    function claim()
        external
    {
        uint256 allRevenue;
        require(accounts[msg.sender].received < 660, ALL_TOKENS_CLAIMED);

        for (uint i = 0; i < accounts[msg.sender].timestamps.length; i++) {
            uint256 timestamp = accounts[msg.sender].timestamps[i];
            uint256 batch = accounts[msg.sender].batches[timestamp];
            uint256 m = (now - timestamp) / (30*24*3600);
            uint256 y = m / 12;
            uint256 revenue = 6 * y * (y + 1) + (m % 12) * (y + 1);
            allRevenue += (revenue * batch);
        }
        uint256 remained = allRevenue - accounts[msg.sender].received;
        require(0 < remained, ALL_TOKENS_CLAIMED);

        accounts[msg.sender].received += remained;
        emit TokensClaimed(msg.sender, remained);
        require(bsToken.mint(msg.sender, remained), MINT_ERROR);
    }

    /**
     * @notice Get current BSS token price.
     */
    function price()
        external
        view
        returns(uint256)
    {
        uint256 totalSupply = bssToken.totalSupply();
        uint256 stepNumber = totalSupply.div(STEP);
        return prices[stepNumber];
    }
}
