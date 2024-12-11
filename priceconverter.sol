// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
library priceconvertor{
      
      function getrate() internal view returns (uint256){
        AggregatorV3Interface PriceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (,int256 Price,,,)=PriceFeed.latestRoundData();
        return uint256(Price);
      }

      function GetConversionRate(uint256 Amount) internal view returns(uint256){
        uint256 EthAmountInUSD  = getrate();
        uint256 AmountInUSD = (EthAmountInUSD * Amount)/1e18;
        return AmountInUSD;
      }
}