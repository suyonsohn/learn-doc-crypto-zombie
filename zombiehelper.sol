pragma solidity ^0.4.23;

import "./zombiefeeding.sol";

contract ZombieHelper is ZombieFeeding {

    // private - only callable from other functions inside the contract
    // internal - like private but can also be called by contracts that inherit from
    // external - only be called outside the contract
    // public - called anywhere

    // view - by running the function, no data will be saved/changed
    // pure - it also doesn't read any data from the blockchain
    // Both of these don't cost any gas to call if they're called externally from outside the contract (but they do cost gas if called internally by another function).

    // Define levelUpFee
    uint levelUpFee = 0.001 ether;

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

    // After you send Ether to a contract, it gets stored in the contract's Ethereum account, and it will be trapped there — unless you add a function to withdraw the Ether from the contract.
    // You can transfer Ether to an address using the transfer function, and this.balance will return the total balance stored on the contract.
    // You can use transfer to send funds to any Ethereum address. For example, you could have a function that transfers Ether back to the msg.sender if they overpaid for an item:

    // uint itemFee = 0.001 ether;
    // msg.sender.transfer(msg.value - itemFee);
    
    // Or in a contract with a buyer and a seller, you could save the seller's address in storage, then when someone purchases his item, transfer him the fee paid by the buyer: seller.transfer(msg.value).    
    function withdraw() external onlyOwner {
        owner.transfer(this.balance);
    }   

    function setLevelUpFee(uint _fee) external onlyOwner {
        levelUpFee = _fee;
    }     

    // payable functions are part of what makes Solidity and Ethereum so cool — they are a special type of function that can receive Ether.
    // Let that sink in for a minute. When you call an API function on a normal web server, you can't send US dollars along with your function call — nor can you send Bitcoin.
    // But in Ethereum, because both the money (Ether), the data (transaction payload), and the contract code itself all live on Ethereum, it's possible for you to call a function and pay money to the contract at the same time.
    // This allows for some really interesting logic, like requiring a certain payment to the contract in order to execute a function.

    // What happens here is that someone would call the function from web3.js (from the DApp's JavaScript front-end) as follows:
    // ZombieHelper.levelUp({from: web3.eth.defaultAccount, value: web3.utils.toWei(0.001)})
    // Notice the value field, where the javascript function call specifies how much ether to send (0.001). If you think of the transaction like an envelope, and the parameters you send to the function call are the contents of the letter you put inside, then adding a value is like putting cash inside the envelope — the letter and the money get delivered together to the recipient.    
    function levelUp(uint _zombieId) external payable {
        // Check to make sure 0.001 ether was sent to the function call
        require(msg.value == levelUpFee);
        zombies[_zombieId].level++;
    }    

    function changeName(uint _zombieId, string _newName) external aboveLevel(2, _zombieId) onlyOwnerOf(_zombieId) {
        zombies[_zombieId].name = _newName;
    }    

    function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) onlyOwnerOf(_zombieId) {
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

        // Note: memory arrays must be created with a length argument (in this example, 3). They currently cannot be resized like storage arrays can with array.push(), although this may be changed in a future version of Solidity.
        uint[] memory result = new uint[](ownerZombieCount[_owner]);

        // In the previous chapter, we mentioned that sometimes you'll want to use a for loop to build the contents of an array in a function rather than simply saving that array to storage.
        // 
        // Let's look at why.
        // 
        // For our getZombiesByOwner function, a naive implementation would be to store a mapping of owners to zombie armies in the ZombieFactory contract:
        // 
        // mapping (address => uint[]) public ownerToZombies
        // Then every time we create a new zombie, we would simply use ownerToZombies[owner].push(zombieId) to add it to that owner's zombies array. And getZombiesByOwner would be a very straightforward function:
        // 
        // function getZombiesByOwner(address _owner) external view returns (uint[]) {
          // return ownerToZombies[_owner];
        // }
        // The problem with this approach
        // This approach is tempting for its simplicity. But let's look at what happens if we later add a function to transfer a zombie from one owner to another (which we'll definitely want to add in a later lesson!).
        // 
        // That transfer function would need to:
        // 
        // Push the zombie to the new owner's ownerToZombies array,
        // Remove the zombie from the old owner's ownerToZombies array,
        // Shift every zombie in the older owner's array up one place to fill the hole, and then
        // Reduce the array length by 1.
        // // Step 3 would be extremely expensive gas-wise, since we'd have to do a write for every zombie whose position we shifted. If an owner has 20 zombies and trades away the first one, we would have to do 19 writes to maintain the order of the        array.
        // 
        // // Since writing to storage is one of the most expensive operations in Solidity, every call to this transfer function would be extremely expensive gas-wise. And worse, it would cost a different amount of gas each time it's called,         depending on how many zombies the user has in their army and the index of the zombie being traded. So the user wouldn't know how much gas to send.
        // 
        // Note: Of course, we could just move the last zombie in the array to fill the missing slot and reduce the array length by one. But then we would change the ordering of our zombie army every time we made a trade.
        // 
        // // Since view functions don't cost gas when called externally, we can simply use a for-loop in getZombiesByOwner to iterate the entire zombies array and build an array of the zombies that belong to this specific owner. Then our transfer         function will be much cheaper, since we don't need to reorder any arrays in storage, and somewhat counter-intuitively this approach is cheaper overall.

        // Using for loops

        // Let's look at an example where we want to make an array of even numbers:

        // function getEvens() pure external returns(uint[]) {
        //   uint[] memory evens = new uint[](5);
          // Keep track of the index in the new array:
        //   uint counter = 0;
          // Iterate 1 through 10 with a for loop:
        //   for (uint i = 1; i <= 10; i++) {
            // If `i` is even...
            // if (i % 2 == 0) {
              // Add it to our array
            //   evens[counter] = i;
              // Increment counter to the next empty index in `evens`:
            //   counter++;
            // }
        //   }
        //   return evens;
        // }            
        uint counter = 0;
        for (uint i = 0; i < zombies.length; i++) {
            if (zombieToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            } 
        }        
        return result;  
    }
}