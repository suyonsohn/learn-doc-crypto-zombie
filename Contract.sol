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
    function createZombie(string _name, uint _dna) {
        zombies.push(Zombie(_name, _dna));
    }

}