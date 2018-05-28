// version of Solidity
pragma solidity ^0.4.23;

import "./ownable.sol";

contract ZombieFactory is Ownable {
    // Events are a way for your contract to communicate that something happened on the blockchain to your app front-end, which can be 'listening' for certain events and take action when they happen.
    event NewZombie(uint zombieId, string name, uint dna);
    // Unsigned Integer
    uint dnaDigits = 16;
    // To make sure our Zombie's DNA is only 16 characters, let's make another uint equal to 10^16. That way we can later use the modulus operator % to shorten an integer to 16 digits.
    uint dnaModulus = 10 ** dnaDigits;

    // Structs allow you to create more complicated data types that have multiple properties.
    struct Zombie {
        string name;
        uint dna;

        // Struct packing to save gas
        // In Lesson 1, we mentioned that there are other types of uints: uint8, uint16, uint32, etc.
        // Normally there's no benefit to using these sub-types because Solidity reserves 256 bits of storage regardless of the uint size. For example, using uint8 instead of uint (uint256) won't save you any gas.
        // But there's an exception to this: inside structs.
        // If you have multiple uints inside a struct, using a smaller-sized uint when possible will allow Solidity to pack these variables together to take up less storage. For example:

        // struct NormalStruct {
            // uint a;
            // uint b;
            // uint c;
        // }

        // struct MiniMe {
            // uint32 a;
            // uint32 b;
            // uint c;
        // }

        // `mini` will cost less gas than `normal` because of struct packing
        // NormalStruct normal = NormalStruct(10, 20, 30);
        // MiniMe mini = MiniMe(10, 20, 30);
        // For this reason, inside a struct you'll want to use the smallest integer sub-types you can get away with.
        // You'll also want to cluster identical data types together (i.e. put them next to each other in the struct) so that Solidity can minimize the required storage space. For example, a struct with fields uint c; uint32 a; uint32 b; will cost less gas than a struct with fields uint32 a; uint c; uint32 b; because the uint32 fields are clustered together.
        
        uint32 level;
        uint32 readyTime;
    }

    // Array with a fixed length of 2 elements:
    // uint[2] fixedArray;

    // fixed Array, can contain 5 strings:
    // string[5] stringArray;

    // a dynamic Array - has no fixed size, can keep growing:
    // uint[] dynamicArray;

    //  an array of structs, public.
    // Other contracts would then be able to read (but not write) to this array. So this is a useful pattern for storing public data in your contract.
    Zombie[] public zombies;

    // Addresses
    // The Ethereum blockchain is made up of accounts, which you can think of like bank accounts. An account has a balance of Ether (the currency used on the Ethereum blockchain), and you can send and receive Ether payments to other accounts, just like your bank account can wire transfer money to other bank accounts.

    // Each account has an address, which you can think of like a bank account number. It's a unique identifier that points to that account, and it looks like this:
    // 0x0cE446255506E92DF41614C46F1d6df9Cc969183

    // An address is owned by a specific user (or a smart contract). So we can use it as a unique ID for ownership of our zombies. When a user creates new zombies by interacting with our app, we'll set ownership of those zombies to the Ethereum address that called the function.

    // Mappings
    // In Lesson 1 we looked at structs and arrays. Mappings are another way of storing organized data in Solidity.

    // For a financial app, storing a uint that holds the user's account balance:
    // mapping (address => uint) public accountBalance;
    // Or could be used to store / lookup usernames based on userId
    // mapping (uint => string) userIdToName;

    // A mapping is essentially a key-value store for storing and looking up data. In the first example, the key is an address and the value is a uint, and in the second example the key is a uint and the value a string. 

    // we'll store and look up the zombie based on its id
    mapping (uint => address) public zombieToOwner;
    mapping (address => uint) ownerZombieCount;
    
    // It's convention (but not required) to start function parameter variable names with an underscore (_) in order to differentiate them from global variables.
    function _createZombie(string _name, uint _dna) internal {
        // array.push() returns a uint of the new length of the array - and since the first item in an array has index 0, array.push() - 1 will be the index of the zombie we just added. 
        uint id = zombies.push(Zombie(_name, _dna)) - 1;

        // In Solidity, there are certain global variables that are available to all functions. One of these is msg.sender, which refers to the address of the person (or smart contract) who called the current function.

        // Note: In Solidity, function execution always needs to start with an external caller. A contract will just sit on the blockchain doing nothing until someone calls one of its functions. So there will always be a msg.sender.

        // Here's an example of using msg.sender and updating a mapping:

        // mapping (address => uint) favoriteNumber;

        // function setMyNumber(uint _myNumber) public {
            // Update our `favoriteNumber` mapping to store `_myNumber` under `msg.sender`
        //   favoriteNumber[msg.sender] = _myNumber;
            // ^ The syntax for storing data in a mapping is just like with arrays
        // }

        // function whatIsMyNumber() public view returns (uint) {
            // Retrieve the value stored in the sender's address
            // Will be `0` if the sender hasn't called `setMyNumber` yet
        //   return favoriteNumber[msg.sender];
        // }
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender]++;
        // fire event
        NewZombie(id, _name, _dna);

        // In addition to public and private, Solidity has two more types of visibility for functions: internal and external.

        // internal is the same as private, except that it's also accessible to contracts that inherit from this contract. (Hey, that sounds like what we want here!).

        // external is similar to public, except that these functions can ONLY be called outside the contract — they can't be called by other functions inside that contract. We'll talk about why you might want to use external vs public later.

        // contract Sandwich {
            // uint private sandwichesEaten = 0;

            // function eat() internal {
                // sandwichesEaten++;
            // }
        // }

        // contract BLT is Sandwich {
            // uint private baconSandwichesEaten = 0;

            // function eatWithBacon() public returns (string) {
                // baconSandwichesEaten++;
                // We can call this here because it's internal
                // eat();
            // }
        // }        
    }

    // string greeting = "What's up dog";

    // the function declaration contains the type of the return value (in this case string).
    // function sayHello() public returns (string) {
        // return greeting;
    // }

    // This function doesn't even read from the state of the app — its return value depends only on its function parameters. So in this case we would declare the function as pure.
    // function _multiply(uint a, uint b) private pure returns (uint) {
        // return a * b;
    // }

    // Ethereum has the hash function keccak256 built in, which is a version of SHA3. A hash function basically maps an input string into a random 256-bit hexidecimal number. A slight change in the string will cause a large change in the hash.
    function _generateRandomDna(string _str) private view returns(uint) {
        uint rand = uint(keccak256(_str));
        return rand % dnaModulus;
    }

    function createRandomZombie(string _name) public {
        // require makes it so that the function will throw an error and stop executing if some condition is not true:
 
        // function sayHiToVitalik(string _name) public returns (string) {
            // Compares if _name equals "Vitalik". Throws an error and exits if not true.
            // (Side note: Solidity doesn't have native string comparison, so we
            // compare their keccak256 hashes to see if the strings are equal)
           
            // require(keccak256(_name) == keccak256("Vitalik"));
           
            // If it's true, proceed with the function:
            
            // return "Hi!";
        // }

        // If you call this function with sayHiToVitalik("Vitalik"), it will return "Hi!". If you call it with any other input, it will throw an error and not execute.
        
        // Thus require is quite useful for verifying certain conditions that must be true before running a function.

        require(ownerZombieCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }
}