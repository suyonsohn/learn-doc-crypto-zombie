// version of Solidity
pragma solidity ^0.4.23;

contract ZombieFactory {
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
    function _createZombie(string _name, uint _dna) private {
        // array.push() returns a uint of the new length of the array - and since the first item in an array has index 0, array.push() - 1 will be the index of the zombie we just added. 
        uint id = zombies.push(Zombie(_name, _dna)) - 1;
        // fire event
        NewZombie(id, _name, _dna);
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
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }
}