// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title MerkleMixer
 * @dev Упрощенная реализация миксера на основе дерева Меркла для образовательных целей.
 */
contract MerkleMixer {
    uint256 public constant DENOMINATION = 1 ether;
    uint256 public constant TREE_LEVELS = 3;
    uint256 public constant MAX_LEAVES = 2**TREE_LEVELS; // 8 листьев

    bytes32[] public leaves;
    bytes32 public root;

    // nullifierHash => spent
    mapping(bytes32 => bool) public nullifierHashes;
    // commitment => exists (чтобы не дублировать депозиты)
    mapping(bytes32 => bool) public commitments;

    event Deposit(bytes32 indexed commitment, uint256 leafIndex, uint256 timestamp);
    event Withdrawal(address to, bytes32 nullifierHash);

    /**
     * @dev Депозит 1 ETH в миксер.
     * @param _commitment хеш от (secret + nullifier).
     */
    function deposit(bytes32 _commitment) external payable {
        require(msg.value == DENOMINATION, "Please send exactly 1 ETH");
        require(leaves.length < MAX_LEAVES, "Merkle tree is full");
        require(!commitments[_commitment], "Commitment has been submitted");

        commitments[_commitment] = true;
        leaves.push(_commitment);
        
        root = _updateRoot();

        emit Deposit(_commitment, leaves.length - 1, block.timestamp);
    }

    /**
     * @dev Вывод средств с доказательством владения листом в дереве.
     */
    function withdraw(
        bytes32 _nullifierHash,
        bytes32[] calldata _proof,
        address payable _to
    ) external {
        require(!nullifierHashes[_nullifierHash], "Proof has already been spent");

        // В этой версии мы используем nullifierHash как доказательство.
        // В ZK-версии мы бы проверяли, что nullifierHash соответствует листу в корне.
        // Здесь мы упрощаем: проверяем, что восстановленный корень совпадает с текущим.
        bytes32 leaf = _nullifierHash; // В упрощенной схеме берем хеш напрямую
        require(_verifyProof(leaf, _proof), "Invalid Merkle proof");

        nullifierHashes[_nullifierHash] = true;
        
        (bool success, ) = _to.call{value: DENOMINATION}("");
        require(success, "Payment failed");

        emit Withdrawal(_to, _nullifierHash);
    }

    /**
     * @dev Проверка Merkle Proof.
     */
    function _verifyProof(bytes32 leaf, bytes32[] memory proof) internal view returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == root;
    }

    /**
     * @dev Внутреннее обновление корня (упрощенное).
     */
    function _updateRoot() internal view returns (bytes32) {
        uint256 n = leaves.length;
        bytes32[] memory tree = new bytes32[](MAX_LEAVES);

        // Копируем листья, заполняем пустые места нулевыми хешами
        for (uint256 i = 0; i < MAX_LEAVES; i++) {
            if (i < n) {
                tree[i] = leaves[i];
            } else {
                tree[i] = bytes32(0);
            }
        }

        // Хешируем уровни дерева
        uint256 width = MAX_LEAVES;
        while (width > 1) {
            for (uint256 i = 0; i < width; i += 2) {
                tree[i / 2] = keccak256(abi.encodePacked(tree[i], tree[i + 1]));
            }
            width /= 2;
        }

        return tree[0];
    }
}
