# 🌪️ Merkle-Based Privacy Mixer Research

*If this research helped you, please consider giving it a ⭐ Star.*


## 🚀 Stay Updated
Found this research useful?
* **Star ⭐** this repo to keep track of it.
* **Follow me** on GitHub for more DeFi security research.
* **Fork** it if you want to run your own experiments.

### ☕ Support the Research
If you appreciate the work and want to support further security research:

<img src="456.PNG" alt="Donate QR" width="200"/>

**Wallet Address (ETH/EVM):** 0xBDDD7973D0DE27B715A4A5cbdb87d0DF78757b3A 


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
