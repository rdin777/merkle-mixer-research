// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MerkleMixer.sol";

contract MerkleMixerTest is Test {
    MerkleMixer public mixer;

    // Подготовка
    function setUp() public {
        mixer = new MerkleMixer();
        // Даем контракту эфир, чтобы было что выводить
        vm.deal(address(mixer), 10 ether);
    }

    // Тест на двойную трату
    function test_DoubleSpendingReverts() public {
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = keccak256("nodes");
        bytes32 leaf = keccak256("leaf");
        bytes32 nullifier = keccak256("secret");
        address payable user = payable(makeAddr("user"));

        // 1. Первый раз выводим - должно пройти
        mixer.withdraw(proof, leaf, nullifier, user);
        assertEq(user.balance, 1 ether);

        // 2. Второй раз с тем же нуллифайером - должен быть реверт
        vm.expectRevert(); 
        mixer.withdraw(proof, leaf, nullifier, user);
    }
}
