// version of Solidity
pragma solidity ^0.4.23;

contract ZombieFactory {
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

    // It's convention (but not required) to start function parameter variable names with an underscore (_) in order to differentiate them from global variables.
    function _createZombie(string _name, uint _dna) private {
        zombies.push(Zombie(_name, _dna));
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