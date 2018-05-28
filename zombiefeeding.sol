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
    // contract NumberInterface {
        // function getNum(address _myAddress) public view returns (uint);
    // }
    
    // We can use it in a contract as follows:

    // contract MyContract {
        // address NumberInterfaceAddress = 0xab38... 
        // ^ The address of the FavoriteNumber contract on Ethereum
        // NumberInterface numberContract = NumberInterface(NumberInterfaceAddress);
        // Now `numberContract` is pointing to the other contract

        // function someFunction() public {
            // Now we can call `getNum` from that contract:
            // uint num = numberContract.getNum(msg.sender);
            // ...and do something with `num` here
        // }
    // }
    
    // In this way, your contract can interact with any other contract on the Ethereum blockchain, as long they expose those functions as public or external.
    
    // Initialize kittyContract here using `ckAddress` from above
    KittyInterface kittyContract;    

    /**
    * @dev Throws if called by any account other than the owner.
    */
    // modifier onlyOwner() {
        // require(msg.sender == owner);
        // _;
    // }
    
    // We would use this modifier as follows:

    // contract MyContract is Ownable {
        // event LaughManiacally(string laughter);

        // Note the usage of `onlyOwner` below:
        // function likeABoss() external onlyOwner {
            // LaughManiacally("Muahahahaha");
        // }
    // }
    // Notice the onlyOwner modifier on the likeABoss function. When you call likeABoss, the code inside onlyOwner executes first. Then when it hits the _; statement in onlyOwner, it goes back and executes the code inside likeABoss.

    // So while there are other ways you can use modifiers, one of the most common use-cases is to add quick require check before a function executes.

    // In the case of onlyOwner, adding this modifier to a function makes it so only the owner of the contract (you, if you deployed it) can call that function.

    function setKittyContractAddress(address _address) external onlyOwner {
        kittyContract = KittyInterface(_address);
    }    

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


    // Passing structs as arguments
    // You can pass a storage pointer to a struct as an argument to a private or internal function. This is useful, for example, for passing around our Zombie structs between functions.

    // The syntax looks like this:

    // function _doStuff(Zombie storage _zombie) internal {
      // do stuff with _zombie
    // }
    // This way we can pass a reference to our zombie into a function instead of passing in a zombie ID and looking it up.
    function _triggerCooldown(Zombie storage _zombie) internal {
        _zombie.readyTime = uint32(now + cooldownTime);
    }

    function _isReady(Zombie storage _zombie) internal view returns (bool) {
        return (_zombie.readyTime <= now);
    }
    
    function feedAndMultiply(uint _zombieId, uint _targetDna, string _species) internal {
        require(msg.sender == zombieToOwner[_zombieId]);
        Zombie storage myZombie = zombies[_zombieId];
        require(_isReady(myZombie));
        _targetDna = _targetDna % dnaModulus;
        uint newDna = (myZombie.dna + _targetDna) / 2;
        if (keccak256(_species) == keccak256("kitty")) {
            newDna = newDna - newDna % 100 + 99;
        }        
        _createZombie("NoName", newDna);        
        _triggerCooldown(myZombie);
    }    

    // Handling Multiple Return Values
    // function multipleReturns() internal returns(uint a, uint b, uint c) {
        // return (1, 2, 3);
    // }

    // function processMultipleReturns() external {
        // uint a;
        // uint b;
        // uint c;
        // This is how you do multiple assignment:
        // (a, b, c) = multipleReturns();
    // }

    // Or if we only cared about one of the values:
    // function getLastReturnValue() external {
        // uint c;
        // We can just leave the other fields blank:
        // (,,c) = multipleReturns();
    // }    
    function feedOnKitty(uint _zombieId, uint _kittyId) public {
        uint kittyDna;
        (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }
}

// Javascript implementation
// Once we're ready to deploy this contract to Ethereum we'll just compile and deploy ZombieFeeding — since this contract is our final contract that inherits from ZombieFactory, and has access to all the public methods in both contracts.

// Let's look at an example of interacting with our deployed contract using Javascript and web3.js:

// var abi = /* abi generated by the compiler */
// var ZombieFeedingContract = web3.eth.contract(abi)
// var contractAddress = /* our contract address on Ethereum after deploying */
// var ZombieFeeding = ZombieFeedingContract.at(contractAddress)

// Assuming we have our zombie's ID and the kitty ID we want to attack
// let zombieId = 1;
// let kittyId = 1;

// To get the CryptoKitty's image, we need to query their web API. This
// information isn't stored on the blockchain, just their webserver.
// If everything was stored on a blockchain, we wouldn't have to worry
// about the server going down, them changing their API, or the company 
// blocking us from loading their assets if they don't like our zombie game ;)
// let apiUrl = "https://api.cryptokitties.co/kitties/" + kittyId
// $.get(apiUrl, function(data) {
//   let imgUrl = data.image_url
  // do something to display the image
// })

// When the user clicks on a kitty:
// $(".kittyImage").click(function(e) {
  // Call our contract's `feedOnKitty` method
//   ZombieFeeding.feedOnKitty(zombieId, kittyId)
// })

// Listen for a NewZombie event from our contract so we can display it:
// ZombieFactory.NewZombie(function(error, result) {
//   if (error) return
  // This function will display the zombie, like in lesson 1:
//   generateZombie(result.zombieId, result.name, result.dna)
// })

// after you deploy a contract to Ethereum, it’s immutable, which means that it can never be modified or updated again.