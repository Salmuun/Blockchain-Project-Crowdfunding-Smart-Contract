// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721URIStorage, Ownable {
    IERC20 private _token;
    uint256 public mintPrice;
    uint256 private _tokenIdCounter;

    struct NFTDetails {
        address seller;
        uint256 price;
    }
    mapping(uint256 => NFTDetails) public nftForSale;
    constructor(address tokenAddress, uint256 price) ERC721("MyNFT", "MNFT") Ownable(msg.sender){
        _token = IERC20(tokenAddress);
        mintPrice = price;
    }

        function mintNFTWithEther(uint256 mintAmount) public payable {
        //require(msg.value >= mintPrice, "Insufficient Ether sent");
        require(msg.value >= (mintPrice * mintAmount), "Insufficient Ether sent");
        _tokenIdCounter++;
        payable(owner()).transfer(msg.value);


        uint256 newTokenId = _tokenIdCounter;
       // _mint(msg.sender, newTokenId);
        for (uint256 i = 1; i <= mintAmount; i++) {
            _safeMint(msg.sender, newTokenId + i);
            }

         }
         
        function mintNFTWithToken(int mintAmount) public payable {
            require(_token.balanceOf(msg.sender) >= mintPrice, "Insufficient token balance");
            require(_token.transferFrom(msg.sender, address(this), mintPrice), "Token transfer failed");

            _tokenIdCounter++;
            uint256 newTokenId = _tokenIdCounter;
            _mint(msg.sender, newTokenId);
         }

        function depositNFT(uint256 tokenId, uint256 price) public {
            require(ownerOf(tokenId) == msg.sender, "You are not the owner of this NFT");
            require(price > 0, "Price must be greater than zero");
            setApprovalForAll(address(this),true);
            transferFrom(msg.sender, address(this), tokenId);
            nftForSale[tokenId] = NFTDetails({seller: msg.sender, price: price});
    }

    function withdrawTokens(address recipient) public onlyOwner {
        uint256 balance = _token.balanceOf(address(this));
        require(_token.transfer(recipient, balance), "Token transfer failed");
    }
  function buyNFT(uint256 tokenId) public {
        NFTDetails memory nftDetail = nftForSale[tokenId];
        require(nftDetail.price > 0, "This NFT is not for sale");
        require(_token.balanceOf(msg.sender) >= nftDetail.price, "Insufficient token balance");
        require(_token.transferFrom(msg.sender, nftDetail.seller, nftDetail.price), "Token transfer failed");
        //approve(msg.sender, tokenId);


        //transferFrom(address(this), msg.sender, tokenId);
        // setApprovalForAll(msg.sender,true);
        this.approve(msg.sender, tokenId);
        transferFrom(address(this), msg.sender, tokenId);
        delete nftForSale[tokenId];
    }

}
