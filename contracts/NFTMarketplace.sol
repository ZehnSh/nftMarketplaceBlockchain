// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

// Layout contract elements in the following order:

// Pragma statements
// Import statements
// Interfaces
// Libraries
// Contracts

// Inside each contract, library or interface, use the following order:

// Type declarations
// State variables
// Events
// Errors
// Modifiers
// Functions

contract NFTMarketplace is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.UintSet;

    struct NFTListing {
        address owner;
        uint256 tokenId;
        uint256 price;
        bool isForSale;
    }

    //just used to send listed NFT List
    struct ListedNFTStruct {
        address owner;
        uint256 tokenId;
        string uri;
        uint256 price;
    }

    // Just used to return the users NFT List
    struct UserNFT {
        uint256 tokenId;
        string tokenURI;
    }

    Counters.Counter tokenIds;
    EnumerableSet.UintSet listedNFTIds;

    mapping(uint256 tokenId => NFTListing listing) public nftListing;
    mapping(address => EnumerableSet.UintSet) ownedNFT;

    event NFT_Minted(address owner, uint256 tokenId, string uri);
    event NFT_Listed(uint256 tokenId, address owner, uint256 price);
    event NFT_Tranferred(address owner, address buyer, uint256 tokenId);

    error NotNFTOwnerAddress();
    error NFT_URI_NotValid();
    error NFT_PriceGreaterThanOne();
    error NotForSale();
    error PriceShouldBeEqual();
    error Transfer_Failed();
    error Not_EnoughBalance();
    error NFT_AlreadyOnSale();

    modifier onlyNFTOwner(uint256 tokeId) {
        if (msg.sender == ownerOf(tokeId)) {
            _;
        } else {
            revert NotNFTOwnerAddress();
        }
    }

    constructor() ERC721("TOKEN", "MTK") {}

    function mintNFT(string memory _uri) external returns (uint256 _tokenId) {
        if (bytes(_uri).length == 0) {
            revert NFT_URI_NotValid();
        }
        tokenIds.increment();
        _tokenId = tokenIds.current();
        _safeMint(_msgSender(), _tokenId);
        _setTokenURI(_tokenId, _uri);
        ownedNFT[_msgSender()].add(_tokenId);
        emit NFT_Minted(_msgSender(), _tokenId, _uri);
    }

    function listNFT(uint256 tokenId, uint256 price) external onlyNFTOwner(tokenId) {
        if (price < 1 ether) {
            revert NFT_PriceGreaterThanOne();
        }
        if (nftListing[tokenId].isForSale) {
            revert NFT_AlreadyOnSale();
        }
        nftListing[tokenId] = NFTListing(_msgSender(), tokenId, price, true);
        transferFrom(_msgSender(), address(this), tokenId);
        listedNFTIds.add(tokenId);
        emit NFT_Listed(tokenId, _msgSender(), price);
    }

    function buyNFT(uint256 tokenId) external payable {
        NFTListing memory nftToBuy = nftListing[tokenId];
        if (nftToBuy.isForSale == false) {
            revert NotForSale();
        }
        if (msg.value != nftToBuy.price) {
            revert PriceShouldBeEqual();
        }
        delete nftListing[tokenId];
        uint256 _value = calculatePlatformPerc(msg.value);
        address owner = nftToBuy.owner;
        (bool sent,) = payable(owner).call{value: _value}("");
        if (!sent) {
            revert Transfer_Failed();
        }
        _transfer(address(this), _msgSender(), tokenId);
        ownedNFT[nftToBuy.owner].remove(tokenId);
        ownedNFT[_msgSender()].add(tokenId);
        listedNFTIds.remove(tokenId);
        emit NFT_Tranferred(owner, _msgSender(), tokenId);
    }

    function getAllListedNFT() external view returns (ListedNFTStruct[] memory) {
        uint256[] memory nftIds = new uint[](listedNFTIds.length());
        ListedNFTStruct[] memory nftList = new ListedNFTStruct[](listedNFTIds.length());
        nftIds = listedNFTIds.values();

        for (uint256 i; i < nftList.length; i++) {
            NFTListing memory nft = nftListing[nftIds[i]];
            nftList[i] = ListedNFTStruct(nft.owner, nft.tokenId, tokenURI(nft.tokenId), nft.price);
        }

        return nftList;
    }

    function userOwnedNFT(address _owner) external view returns (UserNFT[] memory) {
        require(balanceOf(_owner) > 0, "There are no NFT owned by User");
        uint256[] memory nftIds = new uint[](ownedNFT[_owner].length());
        UserNFT[] memory userNFTs = new UserNFT[](ownedNFT[_owner].length());
        nftIds = ownedNFT[_owner].values();

        for (uint256 i; i < nftIds.length; i++) {
            uint256 nftId = nftIds[i];
            userNFTs[i] = UserNFT(nftId, tokenURI(nftId));
        }
        return userNFTs;
    }

    function withdraw() external onlyOwner {
        address _owner = owner();
        uint256 _balance = address(this).balance;
        if (_balance == 0) {
            revert Not_EnoughBalance();
        }
        (bool sent,) = payable(_owner).call{value: _balance}("");
        if (!sent) {
            revert Transfer_Failed();
        }
    }

    function calculatePlatformPerc(uint256 _value) internal pure returns (uint256) {
        return (_value * 99) / 100;
    }
}
