// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract P2PTradingSystem {
    address public owner;

    enum TradeStatus { Open, Completed, Cancelled }

    struct Trade {
        uint tradeId;
        address payable seller;
        address payable buyer;
        uint amount;
        string item;
        TradeStatus status;
    }

    uint public tradeCounter = 0;
    mapping(uint => Trade) public trades;

    event TradeCreated(uint tradeId, address indexed seller, uint amount, string item);
    event TradeAccepted(uint tradeId, address indexed buyer);
    event TradeCompleted(uint tradeId);
    event TradeCancelled(uint tradeId);

    modifier onlySeller(uint _tradeId) {
        require(msg.sender == trades[_tradeId].seller, "Only seller can perform this action.");
        _;
    }

    modifier onlyBuyer(uint _tradeId) {
        require(msg.sender == trades[_tradeId].buyer, "Only buyer can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createTrade(uint _amount, string memory _item) public {
        tradeCounter++;
        trades[tradeCounter] = Trade({
            tradeId: tradeCounter,
            seller: payable(msg.sender),
            buyer: payable(address(0)),
            amount: _amount,
            item: _item,
            status: TradeStatus.Open
        });
        emit TradeCreated(tradeCounter, msg.sender, _amount, _item);
    }

    function acceptTrade(uint _tradeId) public payable {
        Trade storage trade = trades[_tradeId];
        require(trade.status == TradeStatus.Open, "Trade is not available.");
        require(msg.value == trade.amount, "Incorrect payment.");

        trade.buyer = payable(msg.sender);
        trade.status = TradeStatus.Completed;
        trade.seller.transfer(msg.value);

        emit TradeAccepted(_tradeId, msg.sender);
        emit TradeCompleted(_tradeId);
    }

    function cancelTrade(uint _tradeId) public onlySeller(_tradeId) {
        Trade storage trade = trades[_tradeId];
        require(trade.status == TradeStatus.Open, "Cannot cancel completed or already cancelled trade.");
        trade.status = TradeStatus.Cancelled;

        emit TradeCancelled(_tradeId);
    }

    function getTrade(uint _tradeId) public view returns (
        uint, address, address, uint, string memory, TradeStatus
    ) {
        Trade memory trade = trades[_tradeId];
        return (trade.tradeId, trade.seller, trade.buyer, trade.amount, trade.item, trade.status);
    }
}

