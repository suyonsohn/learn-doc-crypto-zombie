pragma solidity ^0.4.23;

import "./zombiefeeding.sol";

contract ZombieHelper is ZombieFeeding {

    // A mapping to store a user's age:
    // mapping (uint => uint) public age;

    // Modifier that requires this user to be older than a certain age:
    // modifier olderThan(uint _age, uint _userId) {
    //   require(age[_userId] >= _age);
    //   _;
    // }

    // Must be older than 16 to drive a car (in the US, at least).
    // We can call the `olderThan` modifier with arguments like so:
    // function driveCar(uint _userId) public olderThan(16, _userId) {
      // Some function logic
    // }
    // You can see here that the olderThan modifier takes arguments just like a function does. And that the driveCar function passes its arguments to the modifier.
    modifier aboveLevel(uint _level, uint _zombieId) {
        require(zombies[_zombieId].level >= _level);
        _;
    }    

    function changeName(uint _zombieId, string _newName) external aboveLevel(2, _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]);
        zombies[_zombieId].name = _newName;
    }    

    function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]);
        zombies[_zombieId].dna = _newDna;
    }

    // view functions don't cost any gas when they're called externally by a user.

    // This is because view functions don't actually change anything on the blockchain – they only read the data. So marking a function with view tells web3.js that it only needs to query your local Ethereum node to run the function, and it   doesn't actually have to create a transaction on the blockchain (which would need to be run on every single node, and cost gas).

    // We'll cover setting up web3.js with your own node later. But for now the big takeaway is that you can optimize your DApp's gas usage for your users by using read-only external view functions wherever possible.

    // Note: If a view function is called internally from another function in the same contract that is not a view function, it will still cost gas. This is because the other function creates a transaction on Ethereum, and will still need to  be verified from every node. So view functions are only free when they're called externally.    
    function getZombiesByOwner(address _owner) external view returns(uint[]) {
        // Storage is Expensive
        // One of the more expensive operations in Solidity is using storage — particularly writes.

        // This is because every time you write or change a piece of data, it’s written permanently to the blockchain. Forever! Thousands of nodes across the world need to store that data on their hard drives,      and this amount of data keeps growing over time as the blockchain grows. So there's a cost to doing that.

        // In order to keep costs down, you want to avoid writing data to storage except when absolutely necessary. Sometimes this involves seemingly inefficient programming logic — like rebuilding an array in      memory every time a function is called instead of simply saving that array in a variable for quick lookups.

        // In most programming languages, looping over large data sets is expensive. But in Solidity, this is way cheaper than using storage if it's in an external view function, since view functions don't      cost your users any gas. (And gas costs your users real money!).

        // We'll go over for loops in the next chapter, but first, let's go over how to declare arrays in memory.

        // Declaring arrays in memory
        // You can use the memory keyword with arrays to create a new array inside a function without needing to write anything to storage. The array will only exist until the end of the function call, and      this is a lot cheaper gas-wise than updating an array in storage — free if it's a view function called externally.

        // Here's how to declare an array in memory:

        // function getArray() external pure returns(uint[]) {
          // Instantiate a new array in memory with a length of 3
        //   uint[] memory values = new uint[](3);
          // Add some values to it
        //   values.push(1);
        //   values.push(2);
        //   values.push(3);
          // Return the array
        //   return values;
        // }
        // This is a trivial example just to show you the syntax, but in the next chapter we'll look at combining this with for loops for real use-cases.

        // Note: memory arrays must be created with a length argument (in this example, 3). They currently cannot be resized like storage arrays can with array.push(), although this may be changed in a future       version of Solidity.
        uint[] memory result = new uint[](ownerZombieCount[_owner]);
        return result;  
    }
}