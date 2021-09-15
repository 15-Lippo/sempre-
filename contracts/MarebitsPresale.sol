pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/crowdsale/Crowdsale.sol";
import "@openzeppelin/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "@openzeppelin/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "@openzeppelin/contracts/crowdsale/distribution/PostDeliveryCrowdsale.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MarebitsPresale is Crowdsale, CappedCrowdsale, TimedCrowdsale, PostDeliveryCrowdsale {
	constructor(uint256 rate, address payable wallet, IERC20 token, uint256 cap, uint256 openingTime, uint256 closingTime) 
		PostDeliveryCrowdsale() TimedCrowdsale(openingTime, closingTime) CappedCrowdsale(cap) Crowdsale(rate, wallet, token) public
	{

	}
}