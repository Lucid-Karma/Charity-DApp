# CharityContract

Welcome to the CharityContract project repository! This project leverages blockchain technology to implement a charity donation and distribution system on the Ethereum blockchain. This smart contract manages donations, voting, and the distribution of funds in a secure and transparent manner.

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Usage](#usage)
- [Smart Contracts](#smart-contracts)
- [Testing](#testing)

## Overview
CharityContract is an Ethereum-based smart contract designed to manage charitable donations. The contract ensures transparent handling of donations, voting for scholarship candidates, and the distribution of funds to recipients.

## Features
- **Donation Management:** Allows users to donate funds securely.
- **Voting System:** Donors can vote for candidates to receive scholarships.
- **Fund Distribution:** Secure and transparent distribution of funds to scholarship recipients.
- **Ownership Control:** Only the contract owner can perform specific administrative actions.

## Getting Started
Follow these steps to set up the project locally.

### Prerequisites
- Node.js 10.x or later
- NPM version 5.2 or later
- Truffle
- Ganache
- MetaMask (optional but helpful)

### Installation
1. Install the necessary packages:
   ```bash
   npm install -g truffle ganache-cli
2. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/CharityContract.git
3. Navigate to the project directory:
   ```bash
   cd CharityContract
4. Install required npm packages:
   ```bash
   npm install
### Usage
1. Start Ganache:
   ```bash
   ganache-cli
2. Compile the smart contracts:
   ```bash
   truffle compile
3. Migrate the smart contracts to the local blockchain:
   ```bash
   truffle migrate
4. Open your Ethereum wallet (e.g., MetaMask) and connect to the local blockchain.
5. Interact with the contract using a frontend interface or via Truffle console.

## Smart Contracts
The smart contract CharityContract.sol facilitates the donation, voting, and fund distribution processes. It includes mechanisms for managing donors, candidates, elections, and fund distribution.

## Testing
Smart contract tests are located in the test folder. These tests ensure the correct functioning of the smart contract. To run the tests, follow these steps:

1. Open a terminal in the project directory.
2. Run the blockchain simulation with Ganache
   ```bash
   ganache-cli
3. Execute the tests:
   ```bash
   truffle test
