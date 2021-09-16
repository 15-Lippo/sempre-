pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/crowdsale/Crowdsale.sol";
import "@openzeppelin/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "@openzeppelin/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "@openzeppelin/contracts/crowdsale/distribution/PostDeliveryCrowdsale.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

/**
 * @title MarebitsPresale
 * @dev Timed, Capped, PostDelivery Crowdsale with a minimum purchase, too ^:)
 */
contract MarebitsPresale is Crowdsale, CappedCrowdsale, TimedCrowdsale, PostDeliveryCrowdsale {
	using SafeMath for uint256;

	uint256 private _minPurchase;

	/**
	 * @dev Constructor, takes minimum amount of wei accepted in the crowdsale.
	 * @param rate Amount of tokens purchased per ETH
	 * @param minPurchase Minimum amount of wei to be contributed
	 */
	constructor(uint256 rate, address payable wallet, IERC20 token, uint256 cap, uint256 openingTime, uint256 closingTime, uint256 minPurchase) 
		PostDeliveryCrowdsale() TimedCrowdsale(openingTime, closingTime) CappedCrowdsale(cap) Crowdsale(rate, wallet, token) public {
		_minPurchase = minPurchase;
	}

	/**
	 * @return the best pony.
	 */
	function bestPony() public view returns (string memory) {
		return "Twilight Sparkle is the best pony ever, she's really smart and likes books.";
	}

	/**
	 * @return the minimum purchase of the crowdsale.
	 */
	function minPurchase() public view returns (uint256) {
		return _minPurchase;
	}

	// temporary override for testing purposes only, remove in production!
	function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {
		token().transfer(beneficiary, tokenAmount);
	}

	/**
	 * @dev Override to extend the way in which ether is converted to tokens.
	 * @param weiAmount Value in wei to be converted into tokens
	 * @return Number of tokens that can be purchased with the specified _weiAmount
	 */
	function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
		return weiAmount.mul(rate()).div(1e18);
	}

	/**
	 * @dev Extend parent behavior requiring purchase to respect the minimum purchase.
	 * @param beneficiary Token purchaser
	 * @param weiAmount Amount of wei contributed
	 */
	function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
		super._preValidatePurchase(beneficiary, weiAmount);
		require(weiAmount >= _minPurchase, "MarebitsPresale: sale amount must be greater than or equal to minimum purchase");
	}
}