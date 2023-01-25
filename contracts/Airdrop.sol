//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/draft-ERC721Votes.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract Airdrop is ERC721, ERC721Enumerable, EIP712, ERC721Votes, Ownable {
  using Counters for Counters.Counter;
  
  Counters.Counter private _tokenIds;

  mapping(address => bool) public processedAirdrops;
  
  uint public currentAirdropAmount;
  uint public maxAirdropAmount = 10000;

  event AirdropProcessed(
    address recipient,
    uint amount,
    uint date
  );

  constructor() ERC721("MockNFT", "MyNFT") EIP712("MyNFT", "1") {
    console.log("Dao NFT has been deployed!");
  }
  
  function claimAirdrop(
    address recipient,
    uint amount,
    bytes calldata signature
  ) external {

    bytes32 message = prefixed(keccak256(abi.encodePacked(
      recipient, 
      amount
    )));

    require(recoverSigner(message, signature) == owner() , 'wrong signature');
    require(processedAirdrops[recipient] == false, 'airdrop already processed');
    require(currentAirdropAmount + amount <= maxAirdropAmount, 'airdropped 100% of the tokens');
    processedAirdrops[recipient] = true;
    currentAirdropAmount += amount;
    
    for (uint i = 0; i < amount; i ++) {
      _mintSingleNFT(recipient);
    }

    emit AirdropProcessed(
      recipient,
      amount,
      block.timestamp
    );
  }

  function _mintSingleNFT(address recipient) private {
    uint newTokenID = _tokenIds.current();
    _safeMint(recipient, newTokenID);
    _tokenIds.increment();
  }

  function prefixed(bytes32 hash) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(
      '\x19Ethereum Signed Message:\n32', 
      hash
    ));
  }

  function recoverSigner(bytes32 message, bytes memory sig)
    internal
    pure
    returns (address)
  {
    uint8 v;
    bytes32 r;
    bytes32 s;
  
    (v, r, s) = splitSignature(sig);
  
    return ecrecover(message, v, r, s);
  }

  function splitSignature(bytes memory sig)
    internal
    pure
    returns (uint8, bytes32, bytes32)
  {
    require(sig.length == 65);
  
    bytes32 r;
    bytes32 s;
    uint8 v;
  
    assembly {
        // first 32 bytes, after the length prefix
        r := mload(add(sig, 32))
        // second 32 bytes
        s := mload(add(sig, 64))
        // final byte (first byte of the next 32 bytes)
        v := byte(0, mload(add(sig, 96)))
    }
  
    return (v, r, s);
  }

  // The following functions are overrides required by Solidity.
  function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
    internal
    override(ERC721, ERC721Enumerable)
  {
    super._beforeTokenTransfer(from, to, tokenId, batchSize);
  }

  function _afterTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
    internal
    override(ERC721, ERC721Votes)
  {
    super._afterTokenTransfer(from, to, tokenId, batchSize);
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721, ERC721Enumerable)
    returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }
}