// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * Demo-only contract to illustrate a DAO treasury with ENCRYPTED (ciphertext)
 * numbers on an FHE-enabled EVM. Ciphertexts are represented by `bytes`.
 * Voting is simplified for demonstration purposes.
 */
contract Treasury {
    struct EncryptedLineItem {
        bytes recipient;   // ciphertext of recipient (or off-chain pointer)
        bytes amount;      // ciphertext of amount
        bytes memo;        // ciphertext note/description
    }

    struct Proposal {
        address author;
        bytes title;                 // ciphertext title/summary
        EncryptedLineItem[] items;   // encrypted line items
        uint256 createdAt;
        uint256 yes;
        uint256 no;
        bool executed;
        bool active;
    }

    mapping(uint256 => Proposal) public proposals;
    uint256 public nextId;

    // simple vote tracking
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    // public aggregates (plaintext counters)
    uint256 public totalExecuted;        // count of executed proposals
    uint256 public epochTotalSpentHint;  // example aggregate (demo only)

    event ProposalCreated(uint256 indexed id, address indexed author);
    event Voted(uint256 indexed id, address indexed voter, bool support);
    event Executed(uint256 indexed id);
    event EncryptedPayout(bytes encryptedRecipient, bytes encryptedAmount);

    modifier onlyActive(uint256 id) {
        require(proposals[id].active, "Inactive");
        _;
    }

    function createProposal(
        bytes calldata _title,
        bytes[] calldata _recipients,
        bytes[] calldata _amounts,
        bytes[] calldata _memos
    ) external returns (uint256 id) {
        require(
            _recipients.length == _amounts.length && _amounts.length == _memos.length,
            "Length mismatch"
        );

        id = nextId++;
        Proposal storage p = proposals[id];
        p.author = msg.sender;
        p.title = _title;
        p.createdAt = block.timestamp;
        p.active = true;

        for (uint256 i = 0; i < _recipients.length; i++) {
            p.items.push(EncryptedLineItem({
                recipient: _recipients[i],
                amount: _amounts[i],
                memo: _memos[i]
            }));
        }

        emit ProposalCreated(id, msg.sender);
    }

    function vote(uint256 id, bool support) external onlyActive(id) {
        require(!hasVoted[id][msg.sender], "Already voted");
        hasVoted[id][msg.sender] = true;

        Proposal storage p = proposals[id];
        if (support) p.yes += 1;
        else p.no += 1;

        emit Voted(id, msg.sender, support);
    }

    /// @notice Demo execute: mark executed and emit encrypted payouts.
    /// Real FHEVM flow would include encrypted settlement primitives.
    function execute(uint256 id) external onlyActive(id) {
        Proposal storage p = proposals[id];
        require(!p.executed, "Executed");
        // simple pass condition for demo
        require(p.yes > p.no, "Not passed");

        p.executed = true;
        p.active = false;
        totalExecuted += 1;

        for (uint256 i = 0; i < p.items.length; i++) {
            emit EncryptedPayout(p.items[i].recipient, p.items[i].amount);
        }

        // Example: update an aggregate hint (plaintext placeholder)
        epochTotalSpentHint += p.items.length;

        emit Executed(id);
    }

    function getCounts(uint256 id) external view returns (uint256 yes, uint256 no) {
        Proposal storage p = proposals[id];
        return (p.yes, p.no);
    }

    function isActive(uint256 id) external view returns (bool) {
        return proposals[id].active;
    }
}
