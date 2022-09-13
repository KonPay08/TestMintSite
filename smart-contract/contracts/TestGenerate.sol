// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9 <0.9.0;

import 'erc721a/contracts/extensions/ERC721AQueryable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

contract TestGenerate is ERC721AQueryable, Ownable, ReentrancyGuard {

  using Strings for uint256;

  address public constant withdrawAddress = 0xB9Cde3a4fBdF3bF03f15769Bb0FCdFBdE61c788b;
  bytes32 public merkleRoot;
  mapping(address => uint256) public preMinted;

  string public uriPrefix = 'ipfs://QmdQ1pFpmaMR8KxotiZ612Cd2oJAeGpzQc89fuQGo9BZ2U/';
  string public uriSuffix = '.json';
  string public hiddenMetadataUri; //notRevealedUri
  
  uint256 public cost;
  uint256 public maxSupply;
  uint256 public maxMintAmountPerTx;
  
  bool public paused = true;
  bool public whitelistMintEnabled = false;
  bool public revealed = true;

  constructor(
    string memory _tokenName,
    string memory _tokenSymbol,
    uint256 _cost,
    uint256 _maxSupply,
    uint256 _maxMintAmountPerTx,
    string memory _hiddenMetadataUri//notRevealedUri

  ) ERC721A(_tokenName, _tokenSymbol) {
    setCost(_cost);
    maxSupply = _maxSupply;
    setMaxMintAmountPerTx(_maxMintAmountPerTx);
    setnotRevealedUri(_hiddenMetadataUri);//notRevealedUri
  }

  function whitelistMint(uint256 _mintAmount, bytes32[] calldata _merkleProof) public payable {
    require(whitelistMintEnabled, 'The whitelist sale is not enabled!');
    require(tx.origin == msg.sender, 'the caller is another controler');
    require(totalSupply() + _mintAmount <= maxSupply, 'Max supply exceeded!');
    require(preMinted[msg.sender] < maxMintAmountPerTx, 'Address already claimed!');
    require(_mintAmount > 0 && preMinted[msg.sender] + _mintAmount <= maxMintAmountPerTx, 'claim is over max amount');
    require(msg.value >= cost * _mintAmount, "not enough eth");
   
    bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
    require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), 'Invalid proof!');

    preMinted[msg.sender] += _mintAmount;
    _safeMint(_msgSender(), _mintAmount);
  }

  function publicMint(uint256 _mintAmount) public payable {
    require(!paused, 'The contract is paused!');
    require(tx.origin == msg.sender, 'the caller is another controler');
    require(totalSupply() + _mintAmount <= maxSupply, 'Max supply exceeded!');
    require(msg.value >= cost * _mintAmount, "not enough eth");
     _safeMint(_msgSender(), _mintAmount);
  }
  
  function mintForAddress(uint256 _mintAmount, address _receiver) public onlyOwner {
    _safeMint(_receiver, _mintAmount);
  }

  function _startTokenId() internal view virtual override returns (uint256) {
    return 1;
  }

  function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
    require(_exists(_tokenId), 'ERC721Metadata: URI query for nonexistent token');

    if (revealed == false) {
      return hiddenMetadataUri;//notRevealedUri
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), uriSuffix))
        : '';
  }

  function setRevealed(bool _state) public onlyOwner {
    revealed = _state;
  }

  function setCost(uint256 _cost) public onlyOwner {
    cost = _cost;
  }

  function setMaxMintAmountPerTx(uint256 _maxMintAmountPerTx) public onlyOwner {
    maxMintAmountPerTx = _maxMintAmountPerTx;
  }

  function setnotRevealedUri(string memory _notRevealedUri) public onlyOwner {
    hiddenMetadataUri = _notRevealedUri;//notRevealedUri
  }

  function setUriPrefix(string memory _uriPrefix) public onlyOwner {
    uriPrefix = _uriPrefix;
  }

  function setUriSuffix(string memory _uriSuffix) public onlyOwner {
    uriSuffix = _uriSuffix;
  }

  function setPaused(bool _state) public onlyOwner {
    paused = _state;
  }

  function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
    merkleRoot = _merkleRoot;
  }

  function setWhitelistMintEnabled(bool _state) public onlyOwner {
    whitelistMintEnabled = _state;
  }

  function withdraw() external onlyOwner {
        (bool os, ) = payable(withdrawAddress).call{value: address(this).balance}("");
        require(os);
    }

  function _baseURI() internal view virtual override returns (string memory) {
    return uriPrefix;
  }

  // function setRoyaltyFee(uint96 _feeNumerator) external onlyOwner {
  //     royaltyFee = _feeNumerator;
  //     _setDefaultRoyalty(royaltyAddress, royaltyFee);
  // }

  // function setRoyaltyAddress(address _royaltyAddress) external onlyOwner {
  //     royaltyAddress = _royaltyAddress;
  //     _setDefaultRoyalty(royaltyAddress, royaltyFee);
  // }

}
