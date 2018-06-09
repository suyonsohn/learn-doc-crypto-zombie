pragma solidity ^0.4.23;

import "./zombieattack.sol";
import "./erc721.sol";
// A token on Ethereum is basically just a smart contract that follows some common rules — namely it implements a standard set of functions that all other token contracts share, such as transfer(address _to, uint256 _value) and balanceOf(address _owner).
// Internally the smart contract usually has a mapping, mapping(address => uint256) balances, that keeps track of how much balance each address has.
// So basically a token is just a contract that keeps track of who owns how much of that token, and some functions so those users can transfer their tokens to other addresses.

// Why does it matter?
// Since all ERC20 tokens share the same set of functions with the same names, they can all be interacted with in the same ways.
// This means if you build an application that is capable of interacting with one ERC20 token, it's also capable of interacting with any ERC20 token. That way more tokens can easily be added to your app in the future without needing to be custom coded. You could simply plug in the new token contract address, and boom, your app has another token it can use.
// One example of this would be an exchange. When an exchange adds a new ERC20 token, really it just needs to add another smart contract it talks to. Users can tell that contract to send tokens to the exchange's wallet address, and the exchange can tell the contract to send the tokens back out to users when they request a withdraw.
// The exchange only needs to implement this transfer logic once, then when it wants to add a new ERC20 token, it's simply a matter of adding the new contract address to its database.

// Other token standards
// ERC20 tokens are really cool for tokens that act like currencies. But they're not particularly useful for representing zombies in our zombie game.
// For one, zombies aren't divisible like currencies — I can send you 0.237 ETH, but transfering you 0.237 of a zombie doesn't really make sense.
// Secondly, all zombies are not created equal. Your Level 2 zombie "Steve" is totally not equal to my Level 732 zombie.
// There's another token standard that's a much better fit for crypto-collectibles like CryptoZombies — and they're called ERC721 tokens.
// ERC721 tokens are not interchangeable since each one is assumed to be unique, and are not divisible. You can only trade them in whole units, and each one has a unique ID. So these are a perfect fit for making our zombies tradeable.
// Note that using a standard like ERC721 has the benefit that we don't have to implement the auction or escrow logic within our contract that determines how players can trade / sell our zombies. If we conform to the spec, someone else could build an exchange platform for crypto-tradable ERC721 assets, and our ERC721 zombies would be usable on that platform. So there are clear benefits to using a token standard instead of rolling your own trading logic.
contract ZombieOwnership is ZombieAttack, ERC721 {
    // To quickly look up who is approved to take that token.
    mapping (uint => address) zombieApprovals;

    function balanceOf(address _owner) public view returns (uint256 _balance) {
        // Return the number of zombies `_owner` has.
        return ownerZombieCount[_owner];    
    }

    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        // Return the owner of `_tokenId`
        return zombieToOwner[_tokenId];
    }

    function _transfer(address _from, address _to, uint256 _tokenId) private {
        ownerZombieCount[_to]++;
        ownerZombieCount[_from]--;
        zombieToOwner[_tokenId] = _to;
        Transfer(_from, _to, _tokenId);
    }   
    
    function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        _transfer(msg.sender, _to, _tokenId);
    }

    // Remember, with approve / takeOwnership, the transfer happens in 2 steps:
    // You, the owner, call approve and give it the address of the new owner, and the _tokenId you want him to take
    // The new owner calls takeOwnership with the _tokenId, the contract checks to make sure he's already been approved, and then transfers him the token.
    function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        zombieApprovals[_tokenId] = _to;
        Approval(msg.sender, _to, _tokenId);
    }    

    function takeOwnership(uint256 _tokenId) public {
        require(zombieApprovals[_tokenId] == msg.sender);
        address owner = ownerOf(_tokenId);
        // you can use msg.sender since the person calling this function is the one the token should be sent to
        _transfer(owner, msg.sender, _tokenId);
    }
}