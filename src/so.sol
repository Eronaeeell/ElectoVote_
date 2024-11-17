// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VotingWithAttestations {
    address public owner;
    
    // Struct to represent a vote
    struct Vote {
        address voter;
        string candidate;
        bytes32 attestationHash;
        uint256 timestamp;
    }
    
    // Voting configuration
    uint256 public constant MAX_CANDIDATES = 10;
    uint256 public constant VOTING_DURATION = 7 days;
    
    // State variables
    Vote[] public votes;
    mapping(address => bool) public hasVoted;
    mapping(string => uint256) public candidateVotes;
    
    // Events
    event VoteSubmitted(address indexed voter, string candidate, bytes32 attestationHash);
    event VotingReset();
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier votingOpen() {
        require(block.timestamp <= startTime + VOTING_DURATION, "Voting period has ended");
        _;
    }
    
    // Voting start time
    uint256 public startTime;
    
    // Constructor
    constructor() {
        owner = msg.sender;
        startTime = block.timestamp;
    }
    
    // Submit a vote
    function submitVote(
        string memory candidate, 
        bytes32 attestationHash
    ) public votingOpen {
        // Validate vote submission
        require(!hasVoted[msg.sender], "You have already voted");
        require(bytes(candidate).length > 0, "Candidate name cannot be empty");
        require(attestationHash != bytes32(0), "Invalid attestation hash");
        
        // Validate candidate
        require(candidateVotes[candidate] < MAX_CANDIDATES, "Candidate limit reached");
        
        // Create and store vote
        Vote memory newVote = Vote({
            voter: msg.sender,
            candidate: candidate,
            attestationHash: attestationHash,
            timestamp: block.timestamp
        });
        
        // Add vote to array and update mappings
        votes.push(newVote);
        hasVoted[msg.sender] = true;
        candidateVotes[candidate]++;
        
        // Emit event
        emit VoteSubmitted(msg.sender, candidate, attestationHash);
    }
    
    // Get total votes
    function getTotalVotes() public view returns (uint256) {
        return votes.length;
    }
    
    // Get votes for a specific candidate
    function getVotesForCandidate(string memory candidate) public view returns (uint256) {
        return candidateVotes[candidate];
    }
    
    // Get all candidates
    function getAllCandidates() public view returns (string[] memory) {
        // Create a dynamic array to store unique candidates
        string[] memory candidates = new string[](votes.length);
        uint256 uniqueCount = 0;
        
        // Iterate through votes to find unique candidates
        for (uint256 i = 0; i < votes.length; i++) {
            bool isUnique = true;
            
            // Check if candidate is already in the list
            for (uint256 j = 0; j < uniqueCount; j++) {
                if (keccak256(bytes(candidates[j])) == keccak256(bytes(votes[i].candidate))) {
                    isUnique = false;
                    break;
                }
            }
            
            // Add unique candidate
            if (isUnique) {
                candidates[uniqueCount] = votes[i].candidate;
                uniqueCount++;
            }
        }
        
        // Trim array to unique candidates
        string[] memory uniqueCandidates = new string[](uniqueCount);
        for (uint256 i = 0; i < uniqueCount; i++) {
            uniqueCandidates[i] = candidates[i];
        }
        
        return uniqueCandidates;
    }
    
    // Reset voting (only owner can do this)
    function resetVoting() external onlyOwner {
        // Clear votes and reset state
        delete votes;
        startTime = block.timestamp;
        
        // Reset hasVoted mapping
        for (uint256 i = 0; i < votes.length; i++) {
            hasVoted[votes[i].voter] = false;
        }
        
        emit VotingReset(); 
    }
    
    // Verify attestation (mock function - would be replaced with actual attestation logic)
    function verifyAttestation(bytes32 attestationHash) public pure returns (bool) {
        // In a real implementation, this would verify the attestation
        // For this example, we'll do a simple check
        return attestationHash != bytes32(0);
    }
    
    // Fallback function
    receive() external payable {
        revert("This contract does not accept direct transfers");
    }
}