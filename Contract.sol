// version of Solidity
pragma solidity ^0.4.23;

contract ZombieFactory {
    // Unsigned Integer
    uint dnaDigits = 16;
    // To make sure our Zombie's DNA is only 16 characters, let's make another uint equal to 10^16. That way we can later use the modulus operator % to shorten an integer to 16 digits.
    uint dnaModulus = 10 ** dnaDigits;
}