pragma solidity ^0.5.0;

import "/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "/openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./BSToken.sol";
import "./Finance.sol";
import "./CanReclaimToken.sol";


/**
 * @title BST minter contract.
 */
contract BSTMinter is Ownable, CanReclaimToken {

    using SafeMath for uint256;

    BSToken internal bsToken;
    ERC20 internal purchaseToken;

    uint256 public price;

    string private constant INSUFFICIENT_PAYMENT = "Insufficient payment";
    string private constant APPROVE_ERROR = "Approve error";
    string private constant MINT_ERROR = "Mint error";
    string private constant FINANCE_MESSAGE = "Revenue of BST Sale";
    string private constant INVALID_PRICE = "Price must be greater than zero";
    string private constant IS_NOT_CONTRACT = "It is not a contract's address";

    event TokensPurchased(address buyer, uint256 price);
    event PurchaseTokenSet(address purchaseTokenAddr);
    event PriceSet(uint256 price);

    constructor(address bsTokenAddress, address purchaseTokenAddr, address financeAddress)
        public
    {
        bsToken = BSToken(bsTokenAddress);
        finance = Finance(financeAddress);
        purchaseToken = ERC20(purchaseTokenAddr);
        price = 10**18;
    }

    /**
     * @notice Set purchaseToken address.
     * @param purchaseTokenAddr Satable token's smart contract address.
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
     * @notice Set BST price.
     * @param _price a BST is worth how many purchase token.
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
     * @notice purchase BST.
     */
    function purchase()
        external
        returns (bool success)
    {
        uint256 allowance = purchaseToken.allowance(msg.sender, address(this));
        require(price <= allowance, INSUFFICIENT_PAYMENT);

        uint256 bstAmount = allowance.div(price);
        uint256 purchaseTokenAmount = bstAmount.mul(price);

        if (purchaseToken.transferFrom(msg.sender, address(this), purchaseTokenAmount)) {
            require(purchaseToken.approve(address(finance), purchaseTokenAmount), APPROVE_ERROR);

            finance.deposit(address(purchaseToken), purchaseTokenAmount, FINANCE_MESSAGE);
            emit TokensPurchased(msg.sender, bstAmount);
            require(bsToken.mint(msg.sender, bstAmount), MINT_ERROR);

            return true;
        }
        return false;
    }

}
