# FHE Private DAO Treasury

A governance dApp on **Zama's FHEVM** for managing a DAO treasury with **encrypted** budgets and allocations.

## Why
Public treasuries leak strategy (vendor pricing, grants, OTC deals). With **FHE**, proposals can be evaluated and executed while keeping numbers private, and still publish verifiable aggregates.

## Features
- 🔒 **Encrypted budgets & payouts** (ciphertext on-chain)
- ✅ **On-chain voting** with private line-items
- 📊 **Auditable aggregates** (total spent / epoch, proposal status)
- 🔁 **Composable**: events & interfaces for tooling

## How it works (high level)
1. Author submits a spending proposal with encrypted line-items (ciphertexts).
2. Members vote; proposal passes per configured quorum/threshold.
3. When executed, payouts are processed while amounts remain encrypted; only aggregates are revealed.

## Contracts
- `contracts/Treasury.sol` — demo contract storing encrypted proposals, voting, and execution events.

## Roadmap
- Frontend (create proposals, vote, read ciphertext from wallet)
- Encrypted multi-recipient payouts; timelock & roles
- Analytics page for public aggregates

## Disclaimer
Demo for **FHEVM** patterns — not production-ready.
