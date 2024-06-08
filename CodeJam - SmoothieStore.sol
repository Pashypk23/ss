// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SmoothieStore {
    address public owner;
    uint public smoothieCount = 0;

    struct Smoothie {
        uint id;
        string name;
        uint price; // price in wei
        uint stock;
    }

    mapping(uint => Smoothie) public smoothies;

    event SmoothieAdded(uint id, string name, uint price, uint stock);
    event SmoothiePurchased(uint id, address buyer, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier validSmoothie(uint _id) {
        require(_id > 0 && _id <= smoothieCount, "Invalid smoothie ID");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addSmoothie(string memory _name, uint _price, uint _stock) public onlyOwner {
        smoothieCount++;
        smoothies[smoothieCount] = Smoothie(smoothieCount, _name, _price, _stock);
        emit SmoothieAdded(smoothieCount, _name, _price, _stock);
    }

    function purchaseSmoothie(uint _id) public payable validSmoothie(_id) {
        Smoothie memory smoothie = smoothies[_id];
        require(msg.value >= smoothie.price, "Insufficient funds sent");
        require(smoothie.stock > 0, "Smoothie out of stock");

        smoothie.stock--;
        smoothies[_id] = smoothie;
        
        payable(owner).transfer(msg.value);

        emit SmoothiePurchased(_id, msg.sender, msg.value);
    }

    function getSmoothie(uint _id) public view validSmoothie(_id) returns (string memory name, uint price, uint stock) {
        Smoothie memory smoothie = smoothies[_id];
        return (smoothie.name, smoothie.price, smoothie.stock);
    }
}
