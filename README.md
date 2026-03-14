# 🌪️ Merkle-Based Privacy Mixer Research

This repository contains a research-oriented implementation of a non-custodial privacy mixer using **Merkle Trees**, built with **Solidity** and tested via **Foundry**.

## 📌 Overview
The project explores the fundamental building blocks of blockchain privacy protocols (like Tornado Cash), focusing on the separation of deposit and withdrawal identity through cryptographic commitments.

### Key Features
* **Fixed Denomination:** Standardized 1 ETH deposits to ensure anonymity sets.
* **Merkle Tree Verification:** Uses a 3-level Merkle Tree (8 leaves) for efficient state management.
* **Double-Spending Protection:** Implementation of `nullifierHashes` to prevent draining the pool.
* **Foundry Native:** Comprehensive test suite including Merkle proof generation and gas analysis.

## 🛠️ Technical Deep Dive
The mixer utilizes a **Commitment Scheme**. Users deposit funds by submitting a hash of a secret. To withdraw, they must provide a valid **Merkle Proof** demonstrating that their commitment is part of the registered Merkle Root, without revealing which specific leaf belongs to them.

### Gas Analysis
* **Deposit:** High gas cost due to Merkle Tree state updates (SSTORE).
* **Withdrawal:** Optimized through proof verification rather than full tree traversal.

## 🚀 Getting Started

### Prerequisites
* [Foundry](https://book.getfoundry.sh/getting-started/installation)

### Installation
```bash
git clone [https://github.com/rdin777/merkle-mixer-research](https://github.com/rdin777/merkle-mixer-research)
cd merkle-mixer-research
forge build
