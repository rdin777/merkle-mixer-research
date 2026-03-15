// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MerkleMixer {
    uint256 public constant DENOMINATION = 1 ether;
    bytes32[] public leaves;
    bytes32 public root;
    mapping(bytes32 => bool) public nullifierHashes;

    function deposit(bytes32 _commitment) external payable {
        require(msg.value == DENOMINATION, "Send 1 ETH");
        require(leaves.length < 8, "Full");
        leaves.push(_commitment);
        root = _updateRoot();
    }

    function withdraw(bytes32 _nullifier, bytes32[] calldata _proof, address payable _to) external {
        require(!nullifierHashes[_nullifier], "Spent");
        
        bytes32 computedHash = _nullifier;
        uint256 index = _findLeafIndex(_nullifier);

        for (uint256 i = 0; i < _proof.length; i++) {
            bytes32 proofElement = _proof[i];
            if (index % 2 == 0) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
            index /= 2;
        }

        require(computedHash == root, "Invalid Merkle proof");
        nullifierHashes[_nullifier] = true;
        _to.transfer(DENOMINATION);
    }

    function _updateRoot() internal view returns (bytes32) {
        bytes32[] memory tree = new bytes32[](8);
        for (uint i = 0; i < 8; i++) {
            tree[i] = i < leaves.length ? leaves[i] : bytes32(0);
        }
        uint n = 8;
        while (n > 1) {
            for (uint i = 0; i < n; i += 2) {
                tree[i/2] = keccak256(abi.encodePacked(tree[i], tree[i+1]));
            }
            n /= 2;
        }
        return tree[0];
    }

    function _findLeafIndex(bytes32 leaf) internal view returns (uint256) {
        for (uint i = 0; i < leaves.length; i++) {
            if (leaves[i] == leaf) return i;
        }
        revert("Leaf not found");
    }

    function getLeavesLength() external view returns (uint256) {
        return leaves.length;
    }
}
