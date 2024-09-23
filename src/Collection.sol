// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.19;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";



contract Collection is ERC721Enumerable, Ownable {
    
    using Strings for uint256;
    string public baseURI;
    string public baseExtension = ".json";
    uint256 public maxSupply = 100000;
    uint256 public maxMintAmount = 5;
    bool public paused = false;

    constructor() ERC721("Net2Dev NFT Collection", "N2D")Ownable(msg.sender) {}

    /**
     * @notice Internal function to return the base URI for the tokens.
     * @dev This will return the IPFS hash for metadata stored on IPFS.
     * @return string representing the base URI for the metadata
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return "ipfs://QmYB5uWZqfunBq7yWnamTqoXWBAHiQoirNLmuxMzDThHhi/";
    }

    /**
     * @notice Function to mint new tokens to a specified address.
     * @dev Limits on mint amount and total supply are enforced. Minting is only allowed if the contract is not paused.
     * @param _to The address to receive the minted tokens.
     * @param _mintAmount The number of tokens to mint.
     */
    function mint(address _to, uint256 _mintAmount) public payable {
        uint256 supply = totalSupply();
        require(!paused, "Minting is paused");
        require(_mintAmount > 0, "Must mint at least 1 token");
        require(_mintAmount <= maxMintAmount, "Cannot mint more than maxMintAmount at once");
        require(supply + _mintAmount <= maxSupply, "Cannot exceed max supply");
        
        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(_to, supply + i);
        }
    }

    /**
     * @notice Function to get all token IDs owned by an address.
     * @param _owner The address whose tokens are queried.
     * @return uint256[] Array of token IDs owned by the specified address.
     */
    function walletOfOwner(address _owner) public view returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i = 0; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    /**
     * @notice Override the tokenURI function to return the correct metadata URI for a given token.
     * @dev Replaces `_exists` check with `ownerOf` for token existence verification.
     * @param tokenId The ID of the token whose metadata URI is queried.
     * @return string The complete URI pointing to the token's metadata.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        // Use ownerOf to verify that the token exists. This will revert if the token doesn't exist.
        require(ownerOf(tokenId) != address(0), "ERC721Metadata: URI query for nonexistent token");

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0 
            ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
            : "";
    }

    // Only Owner Functions

    /**
     * @notice Function to update the maximum number of tokens that can be minted in a single transaction.
     * @param _newmaxMintAmount The new limit for the maximum mint amount.
     */
    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }

    /**
     * @notice Function to update the base URI for the metadata.
     * @param _newBaseURI The new base URI to set.
     */
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    /**
     * @notice Function to update the file extension for the metadata URI.
     * @param _newBaseExtension The new file extension for the metadata.
     */
    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    /**
     * @notice Function to pause or unpause the minting process.
     * @param _state Boolean to set the paused state. True to pause, false to unpause.
     */
    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    /**
     * @notice Function to withdraw contract balance to the owner's address.
     */
    function withdraw() public payable onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }
}
