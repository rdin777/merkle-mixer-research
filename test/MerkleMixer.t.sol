// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MerkleMixer.sol";

contract MerkleMixerTest is Test {
    MerkleMixer mixer;
    address receiver = address(0xDEF);

    function setUp() public {
        mixer = new MerkleMixer();
        vm.deal(address(this), 10 ether);
    }

    function getProof(uint256 index) public view returns (bytes32[] memory) {
        bytes32[] memory proof = new bytes32[](3);
        bytes32[] memory nodes = new bytes32[](8);
        for (uint i = 0; i < 8; i++) {
            nodes[i] = i < mixer.getLeavesLength() ? mixer.leaves(i) : bytes32(0);
        }

        uint256 idx = index;
        uint256 n = 8;
        uint256 proofIdx = 0;
        
        while (n > 1) {
            uint256 neighbor = (idx % 2 == 0) ? idx + 1 : idx - 1;
            proof[proofIdx++] = nodes[neighbor];
            
            for (uint i = 0; i < n; i += 2) {
                nodes[i/2] = keccak256(abi.encodePacked(nodes[i], nodes[i+1]));
            }
            n /= 2;
            idx /= 2;
        }
        return proof;
    }

    function test_SuccessfulDepositAndWithdrawal() public {
        bytes32 leaf = keccak256("secret");
        mixer.deposit{value: 1 ether}(leaf);
        
        bytes32[] memory proof = getProof(0);
        mixer.withdraw(leaf, proof, payable(receiver));
        
        assertEq(receiver.balance, 1 ether);
    }

    function test_RevertOnDoubleSpend() public {
        bytes32 leaf = keccak256("double");
        mixer.deposit{value: 1 ether}(leaf);
        bytes32[] memory proof = getProof(0);
        
        mixer.withdraw(leaf, proof, payable(receiver));
        vm.expectRevert("Spent");
        mixer.withdraw(leaf, proof, payable(receiver));
    }

    receive() external payable {}
}
