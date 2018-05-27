pragma solidity ^0.4.23;

import "./zombiefactory.sol";

// contract LuckyNumber {
//   mapping(address => uint) numbers;

//   function setNum(uint _num) public {
    // numbers[msg.sender] = _num;
//   }

//   function getNum(address _myAddress) public view returns (uint) {
    // return numbers[_myAddress];
//   }
// }

// This would be a simple contract where anyone could store their lucky number, and it will be associated with their Ethereum address. Then anyone else could look up that person's lucky number using their address.

// Now let's say we had an external contract that wanted to read the data in this contract using the getNum function.

// First we'd have to define an interface of the LuckyNumber contract:

// contract NumberInterface {
//   function getNum(address _myAddress) public view returns (uint);
// }

// in Solidity you can return more than one value from a function.

contract KittyInterface {
    function getKitty(uint256 _id) external view returns (
        bool isGestating,
        bool isReady,
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 siringWithId,
        uint256 birthTime,
        uint256 matronId,
        uint256 sireId,
        uint256 generation,
        uint256 genes
    );
}

contract ZombieFeeding is ZombieFactory {
    // In Solidity, there are two places you can store variables — in storage and in memory.

    // Storage refers to variables stored permanently on the blockchain. Memory variables are temporary, and are erased between external function calls to your contract. Think of it like your computer's hard disk vs RAM.

    // Most of the time you don't need to use these keywords because Solidity handles them by default. State variables (variables declared outside of functions) are by default storage and written permanently to the blockchain, while variables declared inside functions are memory and will disappear when the function call ends.

    // However, there are times when you do need to use these keywords, namely when dealing with structs and arrays within functions:

    // contract SandwichFactory {
        // struct Sandwich {
        // string name;
        // string status;
    // }

    // Sandwich[] sandwiches;

    // function eatSandwich(uint _index) public {
        // Sandwich mySandwich = sandwiches[_index];

        // ^ Seems pretty straightforward, but solidity will give you a warning
        // telling you that you should explicitly declare `storage` or `memory` here.

        // So instead, you should declare with the `storage` keyword, like:
        // Sandwich storage mySandwich = sandwiches[_index];
        // ...in which case `mySandwich` is a pointer to `sandwiches[_index]`
        // in storage, and...
        // mySandwich.status = "Eaten!";
        // ...this will permanently change `sandwiches[_index]` on the blockchain.

        // If you just want a copy, you can use `memory`:
        // Sandwich memory anotherSandwich = sandwiches[_index + 1];
        // ...in which case `anotherSandwich` will simply be a copy of the 
        // data in memory, and...
        // anotherSandwich.status = "Eaten!";
        // ...will just modify the temporary variable and have no effect 
        // on `sandwiches[_index + 1]`. But you can do this:
        // sandwiches[_index + 1] = anotherSandwich;
        // ...if you want to copy the changes back into blockchain storage.
    // }
    // }
    function feedAndMultiply(uint _zombieId, uint _targetDna) public {
        require(msg.sender == zombieToOwner[_zombieId]);
        Zombie storage myZombie = zombies[_zombieId];
        _targetDna = _targetDna % dnaModulus;
        uint newDna = (myZombie.dna + _targetDna) / 2;
        _createZombie("NoName", newDna);        
    }    
}