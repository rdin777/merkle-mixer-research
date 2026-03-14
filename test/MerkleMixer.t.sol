// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MerkleMixer.sol";

contract MerkleMixerTest is Test {
    MerkleMixer mixer;
    
    address user = address(0xABC);
    address receiver = address(0xDEF);

    function setUp() public {
        mixer = new MerkleMixer();
        // Даем пользователю немного денег для тестов
        vm.deal(user, 10 ether);
    }

    function test_SuccessfulDepositAndWithdrawal() public {
        // 1. Создаем 8 коммитментов, чтобы полностью заполнить дерево
        bytes32[] memory allCommitments = new bytes32[](8);
        for(uint256 i = 0; i < 8; i++) {
            allCommitments[i] = keccak256(abi.encodePacked("secret_", i));
        }

        // 2. Депозитим их все
        for(uint256 i = 0; i < 8; i++) {
            vm.prank(user);
            mixer.deposit{value: 1 ether}(allCommitments[i]);
        }

        // 3. Подготовим данные для вывода 3-го элемента (индекс 2)
        bytes32 myLeaf = allCommitments[2];
        
        // В нашем упрощенном контракте дерево строится из 8 листьев.
        // Чтобы доказать владение индексом 2, нам нужны соседи по уровням.
        // В реальном приложении это делает библиотека (например, merkletreejs)
        bytes32[] memory proof = new bytes32[](3);
        
        // Уровень 0: Сосед для индекса 2 — это индекс 3
        proof[0] = allCommitments[3]; 
        // Уровень 1: Сосед для пары (2,3) — это хеш пары (0,1)
        proof[1] = keccak256(abi.encodePacked(allCommitments[0], allCommitments[1]));
        // Уровень 2: Сосед для четверки (0,1,2,3) — это хеш четверки (4,5,6,7)
        bytes32 hash45 = keccak256(abi.encodePacked(allCommitments[4], allCommitments[5]));
        bytes32 hash67 = keccak256(abi.encodePacked(allCommitments[6], allCommitments[7]));
        proof[2] = keccak256(abi.encodePacked(hash45, hash67));

        // 4. Выполняем вывод
        uint256 balanceBefore = receiver.balance;
        
        mixer.withdraw(myLeaf, proof, payable(receiver));

        // 5. Проверки
        assertEq(receiver.balance, balanceBefore + 1 ether, "Receiver should get 1 ETH");
        assertTrue(mixer.nullifierHashes(myLeaf), "Nullifier should be marked as spent");
    }

    function test_RevertOnInvalidProof() public {
        vm.prank(user);
        mixer.deposit{value: 1 ether}(bytes32("real_commitment"));

        bytes32[] memory fakeProof = new bytes32[](3);
        fakeProof[0] = bytes32("fake_neighbor");

        vm.expectRevert("Invalid Merkle proof");
        mixer.withdraw(bytes32("real_commitment"), fakeProof, payable(receiver));
    }

    function test_RevertOnDoubleSpend() public {
        bytes32 leaf = keccak256(abi.encodePacked("only_one_deposit"));
        
        // Заполним дерево до 8, чтобы корень зафиксировался
        for(uint256 i = 0; i < 7; i++) {
            mixer.deposit{value: 1 ether}(keccak256(abi.encodePacked(i)));
        }
        mixer.deposit{value: 1 ether}(leaf);

        // Первый вывод (нужно рассчитать корректный proof для 8-го элемента)
        // Для краткости примера просто покажем логику блокировки:
        bytes32[] memory proof = _getProofForLastLeaf(); 
        
        mixer.withdraw(leaf, proof, payable(receiver));

        vm.expectRevert("Proof has already been spent");
        mixer.withdraw(leaf, proof, payable(receiver));
    }

    // Вспомогательная функция для генерации пруфа последнего (8-го) листа
    function _getProofForLastLeaf() internal view returns (bytes32[] memory) {
        bytes32[] memory p = new bytes32[](3);
        p[0] = mixer.leaves(6);
        p[1] = keccak256(abi.encodePacked(mixer.leaves(4), mixer.leaves(5)));
        bytes32 h01 = keccak256(abi.encodePacked(mixer.leaves(0), mixer.leaves(1)));
        bytes32 h23 = keccak256(abi.encodePacked(mixer.leaves(2), mixer.leaves(3)));
        p[2] = keccak256(abi.encodePacked(h01, h23));
        return p;
    }
}
