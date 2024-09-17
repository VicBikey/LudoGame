// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract SimpleLudoGame {
    
    uint constant boardSize = 52; // Number of steps on the board
    uint constant diceSides = 6;

    // Each player has 1 token for simplicity in this example
    struct Player {
        uint position;
        bool hasStarted;
    }

    mapping(address => Player) public players;
    
    //notify when a player rolls the dice
    event DiceRolled(address player, uint diceResult);

    modifier playerJoined() {
        require(players[msg.sender].position <= boardSize, "Player hasn't joined yet!");
        _;
    }

    // Join game
    function joinGame() public {
        require(players[msg.sender].position == 0, "Player already joined!");
        players[msg.sender] = Player(0, false);
    }

    // Generate a pseudorandom number
    function rollDice() public playerJoined returns (uint) {
        // Pseudo-random generator using block difficulty and timestamp
        uint diceRoll = (uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, msg.sender))) % diceSides) + 1;
        
        // Emit event with the dice result
        emit DiceRolled(msg.sender, diceRoll);
        
        // Move player on board based on dice roll
        _movePlayer(diceRoll);

        return diceRoll;
    }

    function _movePlayer(uint diceResult) private {
        Player storage player = players[msg.sender];

        if (!player.hasStarted) {
            if (diceResult == 6) {
                player.hasStarted = true;
                player.position = 1; 
            }
            return;
        }

        uint newPosition = player.position + diceResult;

        if (newPosition < boardSize) {
            player.position = newPosition;
        } else if (newPosition == boardSize) {
            player.position = boardSize; 
        } else {
            player.position = boardSize; 
        }
    }

    // Check if a player has won
    function hasPlayerWon() public view returns (bool) {
        return players[msg.sender].position == boardSize;
    }
}
