// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

error AlreadySpent();
error InvalidProof();
error TransferFailed();

contract MerkleMixerOptimized {
    // Correct BitMap declaration
    mapping(uint256 => uint256) private _nullifierBitMap;

    function withdrawOptimized(
        bytes32[] calldata /* proof */, // Commented out to avoid the “Unused Parameter” warning
        bytes32 /* leaf */,            // until verification logic is added
        bytes32 nullifierHash
    ) external {
        // Calculate the position in the bitmap
        uint256 nHash = uint256(nullifierHash);
        uint256 wordPos = nHash >> 8;     // Slot number (word)
        uint256 bitPos = nHash & 0xff;    // Bit position within the slot (0-255)
        
        // Optimized mask with explicit type
        uint256 mask = uint256(1) << bitPos;

        // Check: Check if the bit has already been set
        if ((_nullifierBitMap[wordPos] & mask) != 0) revert AlreadySpent();

        // Effects: Set the bit (nullifier spent)
        _nullifierBitMap[wordPos] |= mask;

        // Interaction: Send funds
        (bool success, ) = msg.sender.call{value: 1 ether}("");
        if (!success) revert TransferFailed();
    }

    // Add a receive function so the contract can accept ETH for the mixer
    receive() external payable {}
}
