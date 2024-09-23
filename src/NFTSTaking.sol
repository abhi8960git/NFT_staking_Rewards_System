// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.19;

import "./Collection.sol";
import "./Rewards.sol";

contract NFTStaking is Ownable, IERC721Receiver {
    uint256 public totalStaked;

    struct Stake {
        uint24 tokenId;
        uint48 timestamp;
        address owner;
    }

    event NFTStaked(address owner, uint256 tokenId, uint256 value);
    event NFTUnstaked(address owner, uint256 tokenId, uint256 value);
    event Claimed(address owner, uint256 amount);

    
}
