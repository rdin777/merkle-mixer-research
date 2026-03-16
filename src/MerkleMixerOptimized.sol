// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

error AlreadySpent();
error InvalidProof();

contract MerkleMixerOptimized {
    // Use uint256 as a bitmask (pseudocode for illustrative purposes)
    mapping(uint256 => uint256) private _nullifierBitMap;

    function withdrawOptimized(
        bytes32[] calldata proof, // calldata saves gas when copying
        bytes32 leaf,
        bytes32 nullifierHash
    ) external {
        // Optimization 1: Custom Errors instead of require
        // Optimization 2: Bitwise operations to check the nullifier
        
        uint256 nHash = uint256(nullifierHash);
        uint256 wordPos = nHash >> 8;
        uint256 bitPos = nHash & 0xff;
        uint256 mask = 1 << bitPos;

        if ((_nullifierBitMap[wordPos] & mask) != 0) revert AlreadySpent();
        
        // Effects
        _nullifierBitMap[wordPos] |= mask;

        // Interaction
        (bool success, ) = msg.sender.call{value: 1 ether}("");
        if (!success) revert();
    }
}
