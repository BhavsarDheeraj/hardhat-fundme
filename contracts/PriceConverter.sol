// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    // get 1 eth price in usd
    function getPriceInUSD(AggregatorV3Interface priceFeed)
        internal
        view
        returns (uint256)
    {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // will get price with 8 extra zeros
        return uint256(price * 1e10);
    }

    // get x amount of eth in usd
    function getConversion(uint256 ethAmount, AggregatorV3Interface priceFeed)
        internal
        view
        returns (uint256)
    {
        uint256 priceInUSD = getPriceInUSD(priceFeed);
        uint256 amount = (priceInUSD * ethAmount) / 1e18;
        return amount;
    }
}
