// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "../../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract CharityContract is ReentrancyGuard {
  
  //DATA
  
  //Counter
  using Counters for Counters.Counter;
  Counters.Counter private _counter;
  Counters.Counter private _electionCounter;

  //Owner
  address private owner;

  
  // Holds total donations amount.
  uint256 private totalDonations; 
  // Specifies the minimum donation amount.      
  uint8 immutable minDonation = 1;   
  // Amount to be distributed   
  uint256 private distributionAmount;   

  // List of addresses to receive donations.
  Candidate[] public recipients;        
  // Helper array to keep the recipients array up to date.
  Candidate[] private validRecipients; 

  // Array for holding the ones who voted.
  address[] private voted_addresses;




  struct Donor
  {
    address walletAddress;
    string name;
    string lastName;
    bool canVote;
  }

  struct Candidate
  {
    address walletAddress;
    string description;
    string purpose;
    string socialContribution;
    uint8 age;
    uint8 grade;
    uint256 id;
    uint16 voteCount;
    bool onScholarship;

    uint8 monthsOfScholarship;
  }

  struct Election {
    uint16 currentVoteCount;
    uint16 totalVoteToEnd;
    bool isActive;
  }
    

  //events

  // The event that will be triggered when a donor is added.
  event DonorAdded(address indexed walletAddress, string name, string lastName);
  // The event that will be triggered when a donation is made
  event DonationReceived(address indexed donor, uint256 amount);
  // The event that will be triggered when the distribution is made
  event DonationDistributed(address indexed recipient, uint256 amount);


  //mappings

  // Donor(user) mapping
  mapping(address => Donor) private donors;
  // Candidate mapping
  mapping(uint256 => Candidate) private candidates;
  // Mapping for holding the election history.
  mapping(uint256 => Election) electionHistory;



  //constructor
  constructor() {
    owner = msg.sender;
    totalDonations = 0;
    voted_addresses.push(msg.sender);

    distributionAmount = 1;
  }
  


  //MODIFIERS

  // Checks whether address that calls the function is "owner".
  modifier onlyOwner() {
    require(msg.sender == owner, "Only the owner can call this function");
    _;
  }

  // Checks whether election is active.
  modifier active()
  {
    require(electionHistory[_counter.current()].isActive == true, "Proposal is currently not active.");
    _;
  }

  // Checks whether the donor has voted before.
  modifier newVoter(address _address)
  {
    require(!isVoted(_address), "Address already voted.");
    _;
  }


  //FUNCTIONS

  // Sets a new owner.
  function setOwner(address _newOwner) external onlyOwner {
    owner = _newOwner;
  }

  // Allows owner to change the distribution amount as needed.
  function setDonationInformation(uint256 _distributionAmount) external onlyOwner {
    distributionAmount = _distributionAmount;
  }

  // Creates a donor.
  function addDonor(string calldata name, string calldata lastName) external {
    require(!isUser(msg.sender), "User already exists.");
    donors[msg.sender] = Donor(msg.sender, name, lastName, false);

    emit DonorAdded(msg.sender, donors[msg.sender].name, donors[msg.sender].lastName);
  }

  // Allows owner to add a candidate.
  function addCandidate(address walletAddress, string calldata description, string calldata purpose, string calldata socialContribution, uint8 age, uint8 grade) external onlyOwner {
    _counter.increment();
    uint _id = _counter.current();
    candidates[_id] = Candidate(walletAddress, description, purpose, socialContribution, age, grade, _id, 0, false, 0);
  }

  // Allows owner to create a new election if the total donation amount is greater than a scholar's 12-month scholarship amount.
  // Elections are held to determine the new scholarship holder.
  function createElection(uint16 _total_vote_to_end) external onlyOwner {
    require(totalDonations > distributionAmount * 12, "Not enough donations to choose a recipient for the scholarship");

    _electionCounter.increment();
    electionHistory[_electionCounter.current()] = Election(0, _total_vote_to_end, true);
  }

  // Allows donation if conditions are met.
  // User can vote after this step thanks to canVote boolean update.
  function donate() external payable {  // !!!
    require(msg.sender.balance >= msg.value, "Not enough BNB");
    require(msg.value >= minDonation, "Donation amount must be greater than minimum donation amount.");
    
    totalDonations += msg.value;

    donors[msg.sender].canVote = true;
    
    emit DonationReceived(msg.sender, msg.value);
  }

  // Allows owner to distribute donations to the scholars.
  // Distribution is only possible if the total amount of donations are greater than or equal to
  // total scholarship amount to be distributed to all scholarship holders that month.
  // "recipients" list is updated every function call since students can receive scholarships for only 12 months.
  function distributeDonations() external onlyOwner() {
    require(totalDonations >= distributionAmount * recipients.length, "There is insufficient funds to distribute.");

    delete validRecipients;
    
    for (uint16 i = 0; i < recipients.length; i++) {
      require(recipients[i].monthsOfScholarship <= 12, "The scholarship period has ended for the recipient.");

      (bool success, ) = recipients[i].walletAddress.call{value: distributionAmount}("");
      require(success, "Transfer failed");

      recipients[i].monthsOfScholarship ++;
      totalDonations -= distributionAmount;

      emit DonationDistributed(recipients[i].walletAddress, distributionAmount);

      validRecipients.push(recipients[i]);
    }

    delete recipients;
    for (uint16 j = 1; j < validRecipients.length; j++) {
      recipients.push(validRecipients[j]);
    }
  }

  // Allows users who have donated before to vote.
  // All candidates have their own numbers, and they are voted using these numbers by donors.
  // After reaching the number of totalVoteToEnd, winner is calculated, and election ends.
  function vote(uint16 choice) external active newVoter(msg.sender) {

    Election storage election = electionHistory[_electionCounter.current()];
    election.currentVoteCount ++;

    candidates[choice].voteCount ++;

    voted_addresses.push(msg.sender);
    donors[msg.sender].canVote = false;

    if(election.totalVoteToEnd == election.currentVoteCount)
    {
      uint winner = calculateWinner();
      recipients.push(candidates[winner]);
      delete candidates[winner];
      for (uint i = winner; i <= _counter.current(); i++) {
        candidates[i].id = i;
      }
      _counter.decrement();

      election.isActive = false;
      voted_addresses = [owner];
    }
  }

  // This function ensures an election ends in finite time, in the case that not reaching enough number of votes to end.
  function terminateElection() external onlyOwner active {
    uint winner = calculateWinner();
    recipients.push(candidates[winner]);
    delete candidates[winner];
    for (uint i = winner; i <= _counter.current(); i++) {
      candidates[i].id = i;
    }
    _counter.decrement();

    electionHistory[_electionCounter.current()].isActive = false;
    voted_addresses = [owner];
  }

  // Returns a boolean based on first-time voting status, after ensure user has donated before.
  function isVoted(address _address) private view returns (bool) {
    require(isDonor(_address), "Only donors can vote.");

    address[] memory _voted_addresses = voted_addresses;
    for (uint16 i = 0; i < _voted_addresses.length; i++) 
    {
      if(_voted_addresses[i] == _address)       
      {
          return true;
      }
    }
    return false;
  }

  // Returns id number of candidate with the most votes.
  function calculateWinner() private view returns(uint256){
    uint maxVoteCount = 0;
    uint winningCandidateId;

    for (uint i = 0; i < _counter.current(); i++) {
      if (candidates[i].voteCount > maxVoteCount) {
        maxVoteCount = candidates[i].voteCount;
        winningCandidateId = i;
      }
    }

    return winningCandidateId;
  }



 

  // Returns a bool based on the address' user status.
  function isUser(address walletAddress) private view returns(bool) {
    return donors[walletAddress].walletAddress != address(0);
  }

  // Returns a bool based on the user's vote status depends on whether she has voted before.
  function isDonor(address walletAddress) private view returns(bool) {
    require(isUser(walletAddress), "User does not exist to check if she can vote.");
    return donors[walletAddress].canVote ? true : false;
  }

  // Returns owner's address
  function getOwner() external view returns (address) {
    return owner;
  }

  // Returns Donor struct of the given address.
  function getUser(address walletAddress) external view returns(Donor memory) {
    require(isUser(walletAddress), "User does not exist!");
    return donors[walletAddress];
  }

  // Returns Candidate struct of the given number.
  function getCandidate(uint256 candidateId) external view returns(Candidate memory) {
    return candidates[candidateId];
  }

  // Returns the current distribution amount.
  function getDonationInfo() external view returns(uint256) {
    return distributionAmount;
  }

  // Returns the amount of total donations.
  function getTotalDonations() external view returns (uint256) {
    return totalDonations;
  }

  // Returns Election struct of the given number.
  function getElection(uint256 index) external view returns (Election memory) {
    return electionHistory[index];
  }
}
