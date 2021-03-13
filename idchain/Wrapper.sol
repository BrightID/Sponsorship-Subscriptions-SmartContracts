// SPDX-License-Identifier: BSD 2-Clause "Simplified" License

pragma solidity >=0.6.0 <0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/math/SafeMath.sol";
import "./IdSponsorships.sol";
import "./IdSubscriptions.sol";


/**
 * @dev This is a wrapper for sponsorship and subscription tokens
 * The approch here is, It gets sp or subs token and mints wraped ERC20 token.
 * It burns ERC20s and gives back the sp or subs.
 */
contract Wrapper is Ownable {
    using SafeMath for uint256;

    ERC20 internal sp;
    ERC20 internal subs;

    IdSponsorships internal idSp;
    IdSubscriptions internal idSubs;

    uint256 public constant SCALE = 1e18;

    string private constant TRANSFER_FROM_ERROR = "Input token transferFrom failed";
    string private constant INSUFFICIENT_ALLOWANCE = "Insufficient allowance";
    string private constant MINT_ERROR = "Mint failed";
    string private constant TRANSFER_ERROR = "Token transfer failed";

    event SponsorshipsWrapped(address account, uint256 amount);
    event SubscriptionsWrapped(address account, uint256 amount);
    event SponsorshipsUnWrapped(address account, uint256 amount);
    event SubscriptionsUnWrapped(address account, uint256 amount);

    /**
     * @dev sets values for
     * @param _sp address of sponsorship token
     * @param _subs address of subscription token
     * @param _idSp address of IdSponsorship token
     * @param _idSubs address of IdSubscription token
     */
    constructor(ERC20 _sp, ERC20 _subs, IdSponsorships _idSp, IdSubscriptions _idSubs) {
        sp = _sp;
        subs = _subs;
        idSp = _idSp;
        idSubs = _idSubs;
    }

    /**
     *@notice wrap sp to idSp.
     *@dev A function that gets sp and mints IdSp.
     */
    function wrapSp()
        external
        returns (bool success)
    {
        uint256 allowance = sp.allowance(_msgSender(), address(this));
        require(sp.transferFrom(_msgSender(), address(this), allowance), TRANSFER_FROM_ERROR);

        uint256 idSpAmount = allowance.mul(SCALE);
        require(idSp.mint(_msgSender(), idSpAmount), MINT_ERROR);

        emit SponsorshipsWrapped(_msgSender(), allowance);
        return true;
    }

    /**
     *@notice wrap subs to idSubs.
     *@dev A function that burns idSp and gives back sp
     */
    function unWrapSp()
        external
        returns (bool success)
    {
        uint256 allowance = idSp.allowance(_msgSender(), address(this));
        uint256 spAmount = allowance.div(SCALE);
        require(spAmount > 0, INSUFFICIENT_ALLOWANCE);

        uint256 balance = sp.balanceOf(address(this));
        if (balance < spAmount) {
            spAmount = balance;
        }

        idSp.burnFrom(_msgSender(), spAmount.mul(SCALE));
        require(sp.transfer(_msgSender(), spAmount), TRANSFER_ERROR);

        emit SponsorshipsUnWrapped(_msgSender(), spAmount);
        return true;
    }

    /**
     *@notice wrap idSp to sp.
     *@dev A function that gets subs and mints IdSubs.
     */
    function wrapSubs()
        external
        returns (bool success)
    {
        uint256 allowance = subs.allowance(_msgSender(), address(this));
        require(subs.transferFrom(_msgSender(), address(this), allowance), TRANSFER_FROM_ERROR);

        uint256 idSubsAmount = allowance.mul(SCALE);
        require(idSubs.mint(_msgSender(), idSubsAmount), MINT_ERROR);

        emit SubscriptionsWrapped(_msgSender(), allowance);
        return true;
    }

    /**
     *@notice wrap idSubs to subs.
     *@dev A function that burns idSubs and gives back subs
     */
    function unWrapSubs()
        external
        returns (bool success)
    {
        uint256 allowance = idSubs.allowance(_msgSender(), address(this));
        uint256 subsAmount = allowance.div(SCALE);
        require(subsAmount > 0, INSUFFICIENT_ALLOWANCE);

        uint256 balance = subs.balanceOf(address(this));
        if (balance < subsAmount) {
            subsAmount = balance;
        }

        idSubs.burnFrom(_msgSender(), subsAmount.mul(SCALE));
        require(subs.transfer(_msgSender(), subsAmount), TRANSFER_ERROR);

        emit SubscriptionsUnWrapped(_msgSender(), subsAmount);
        return true;
    }

    /**
     *@dev withdrawal all funds to another account if needed
    * @param account Destination account address.
     */
    function withdrawAll(address account)
        public
        onlyOwner
    {
        uint256 spBalance = sp.balanceOf(address(this));
        sp.transfer(account, spBalance);

        uint256 subsBalance = subs.balanceOf(address(this));
        subs.transfer(account, subsBalance);
    }
}
