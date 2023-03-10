pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/crowdsale/Crowdsale.sol";
import "@openzeppelin/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "@openzeppelin/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "@openzeppelin/contracts/crowdsale/distribution/PostDeliveryCrowdsale.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Lisprocoin Presale
 * @dev Ownable, Timed, Capped, PostDelivery Crowdsale with a minimum purchase, too ^:)
 */
contract MarebitsPresale is Ownable, Crowdsale, CappedCrowdsale, TimedCrowdsale, PostDeliveryCrowdsale {
	using SafeMath for uint256;

	bool private _isFinalized;
	uint256 private _minPurchase;

	event PresaleFinalized();

	/**
	 * @dev Constructor, takes minimum amount of wei accepted in the presale.
	 * @param rate Amount of tokens purchased per Matic
	 * @param minPurchase Minimum amount of wei to be contributed
	 */
	constructor(uint256 rate, address payable wallet, IERC20 token, uint256 cap, uint256 openingTime, uint256 closingTime, uint256 minPurchase) 
		PostDeliveryCrowdsale() TimedCrowdsale(openingTime, closingTime) CappedCrowdsale(cap) Crowdsale(rate, wallet, token) public {
		_isFinalized = false;
		_minPurchase = minPurchase;
	}

	/**
	 * @return the best pony.
	 */
	function bestPony() public pure returns (string memory) { return "Twilight Sparkle is the cutest, smartest, all around best pony!"; }

	/**
	 * @dev Must be called after presale ends, to do some extra finalization
	 * work. Calls the contract's finalization function.
	 */
	function finalize() public onlyOwner {
		require(!_isFinalized, "MarebitsPresale: already finalized");
		require(hasClosed(), "MarebitsPresale: not closed");
		withdrawContractTokens(address(token()));
		wallet().transfer(address(this).balance);
		_isFinalized = true;
		emit PresaleFinalized();
	}

	/**
	 * @return true if the presale is finalized, false otherwise.
	 */
	function isFinalized() public view returns (bool) { return _isFinalized; }

	/**
	 * @return the minimum purchase of the presale.
	 */
	function minPurchase() public view returns (uint256) { return _minPurchase; }

	/**
	 * @return the address where funds are collected.
	 */
	function wallet() public view returns (address payable) { return address(uint160(owner())); }

	/**
	 * @dev Withdraw all tokens of the given type to this contract owner's wallet.
	 * @param tokenContract The contract address of the token to withdraw
	 */
	function withdrawContractTokens(address tokenContract) public onlyOwner {
		IERC20 token = IERC20(tokenContract);
		token.safeTransfer(wallet(), token.balanceOf(address(this)));
	}

	// temporary override for testing purposes only, remove in production!
	// function _deliverTokens(address beneficiary, uint256 tokenAmount) internal { token().transfer(beneficiary, tokenAmount); }

	/**
	 * @dev Determines how Matic is stored/forwarded on purchases.
	 */
	function _forwardFunds() internal { /* do nothing */ }

	/**
	 * @dev Extend parent behavior requiring purchase to respect the minimum purchase.
	 * @param beneficiary Token purchaser
	 * @param weiAmount Amount of wei contributed
	 */
	function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
		require(!_isFinalized, "MarebitsPresale: already finalized");
		super._preValidatePurchase(beneficiary, weiAmount);
		require(weiAmount >= _minPurchase, "MarebitsPresale: sale amount must be greater than or equal to minimum purchase");
	}
}
