// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 private immutable i_minUSD;
    address private immutable i_owner;
    address[] public s_funders;
    mapping(address => uint256) private s_addressAmountMap;
    AggregatorV3Interface private immutable i_priceFeed;

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
            "You need to spend more ETH"
        );
        s_funders.push(msg.sender);
        s_addressAmountMap[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        // for (uint256 i = 0; i < s_funders.length; i++) {
        //     s_addressAmountMap[s_funders[i]] = 0;
        // }
        // s_funders = new address[](0);
        // (bool callSend, ) = payable(msg.sender).call{
        //     value: address(this).balance
        // }("");
        // require(callSend, "Withdrawal failed.");

        address[] memory funders = s_funders;
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressAmountMap[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSend, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSend, "Withdrawal failed.");
    }

    function getMinimumUSD() public view returns (uint256) {
        return i_minUSD;
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(address funder)
        public
        view
        returns (uint256)
    {
        return s_addressAmountMap[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return i_priceFeed;
    }
}
