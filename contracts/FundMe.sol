// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    using SafeMathChainlink for uint256;
    
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address owner;
    AggregatorV3Interface public priceFeed;
    
    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }
        
    function fund() public payable {
        uint256 minimumUSD = 50 * 10 ** 18;
        require(getConversionRate(msg.value) >= minimumUSD, "Funding needs to be more than $50 worth of ETH.");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }
    
    function getPrice() public view returns(uint256) {
        (,int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer * 10_000_000_000);
    }
    
    function getConversionRate(uint256 weiAmount) public view returns(uint256) {
        uint256 weiPrice = getPrice();
        uint256 ethAmountUsd = (weiPrice * weiAmount) / 1_000_000_000_000_000_000;
        return ethAmountUsd;
    }

    function getEntranceFee() public view returns (uint256) {
        //minimumUSD
        uint256 minimumUSD = 50 * 1_000_000_000_000_000_000;
        uint256 price = getPrice();
        uint256 precision = 1_000_000_000_000_000_000;
        return (minimumUSD * precision) / price;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner, "Not the owner.");
        _;
    }
    
    function withdraw() payable onlyOwner public {
        msg.sender.transfer(address(this).balance);
        for (uint256 fundIndex = 0; fundIndex < funders.length; fundIndex++) {
            addressToAmountFunded[funders[fundIndex]] = 0;
        }
        funders = new address[](0);
    }
    
}