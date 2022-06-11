// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 immutable i_minUSD;
    address immutable i_owner;
    address[] funders;
    mapping(address => uint256) addressAmountMap;
    AggregatorV3Interface public immutable i_priceFeed;

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "You are not the owner");
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    constructor(uint256 _minUSD, address _priceFeedAddress) {
        i_owner = msg.sender;
        i_minUSD = _minUSD * 1e18;
        i_priceFeed = AggregatorV3Interface(_priceFeedAddress);
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function fund() public payable {
        require(
            msg.value.getConversion(i_priceFeed) >= i_minUSD,
            "Funding amount should be greater than or equal to 10 dollars"
        );
        funders.push(msg.sender);
        addressAmountMap[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint256 i = 0; i < funders.length; i++) {
            addressAmountMap[funders[i]] = 0;
        }
        funders = new address[](0);
        (bool callSend, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSend, "Withdrawal failed.");
    }
}
