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
}