// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MerkleMixer.sol";

contract MerkleMixerTest is Test {
    MerkleMixer public mixer;

    // Setup
    function setUp() public {
        mixer = new MerkleMixer();
        // Give the contract some Ether so it has something to output
        vm.deal(address(mixer), 10 ether);
    }

    // Double-spending test
    function test_DoubleSpendingReverts() public {
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = keccak256("nodes");
        bytes32 leaf = keccak256("leaf");
        bytes32 nullifier = keccak256("secret");
        address payable user = payable(makeAddr("user"));

        // 1. First withdrawal attempt—should succeed
        mixer.withdraw(proof, leaf, nullifier, user);
        assertEq(user.balance, 1 ether);

        // 2. Second time with the same nullifier—should result in a revert
        vm.expectRevert(); 
        mixer.withdraw(proof, leaf, nullifier, user);
    }
}

