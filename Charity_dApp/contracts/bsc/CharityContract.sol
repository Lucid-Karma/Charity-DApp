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

  //totalPayments
  uint256 private totalDonations;
  uint8 immutable minDonation = 1;
  uint256 private distributionAmount; // Dağıtılacak miktar

  // Candidates olarak değiştirebilirsin, candidates içine de burs alınan ay sayısını simgeleyen bir uint.
  Candidate[] public recipients; // Bağış alacak adreslerin listesi
  Candidate[] private validRecipients;

  //Array for holding the ones who voted.
  address[] private voted_addresses;

  Donation[] public donations; // Bağışların listesi




  struct Donor
  {
    address walletAddress;
    string name;
    string lastName;
  }
  struct AnonimDonor
  {
    address walletAddress;
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

  struct Donation {
    address donor;
    uint256 amount;
  }

  struct Election {
    uint16 currentVoteCount;
    uint16 totalVoteToEnd;
    bool isActive;
  }
    
  //events
  // Bağış yapıldığında tetiklenecek olay
  event DonationReceived(address indexed donor, uint256 amount);
  // Dağıtım yapıldığında tetiklenecek olay
  event DonationDistributed(address indexed recipient, uint256 amount);

  //user mapping
  mapping(address => Donor) private donors;
  mapping(address => AnonimDonor) private anonimDonors;

  //candidate mapping
  mapping(uint256 => Candidate) private candidates;

  //Mapping for holding the election history.
  mapping(uint256 => Election) electionHistory;

  //constructor
  constructor() {
    owner = msg.sender;
    totalDonations = 0;
    voted_addresses.push(msg.sender);

    distributionAmount = 50;
  }
  


  //MODIFIERS
  //onlyOwner
  modifier onlyOwner() {
    require(msg.sender == owner, "Only the owner can call this function");
    _;
  }

  modifier active()
  {
    require(electionHistory[_counter.current()].isActive == true, "Proposal is currently not active.");
    _;
  }

  modifier newVoter(address _address)
  {
    require(!isVoted(_address), "Address already voted.");
    _;
  }

  //FUNCTIONS
  //Execute Functions

  //setOwner #onlyOwer
  function setOwner(address _newOwner) external onlyOwner {
    owner = _newOwner;
  }

  function setDonationInformation(uint256 _distributionAmount) external onlyOwner {
    distributionAmount = _distributionAmount;
  }

  //addUser #nonExisting
  function addDonor(string calldata name, string calldata lastName) external {
    require(!isUser(msg.sender), "User already exists.");
    donors[msg.sender] = Donor(msg.sender, name, lastName);

    //emit UserAdded(msg.sender, users[msg.sender].name, users[msg.sender].lastName);
  }
  function addAnonimDonor() external {
    require(!isUser(msg.sender), "User already exists.");
    anonimDonors[msg.sender] = AnonimDonor(msg.sender);

    //emit UserAdded(msg.sender, users[msg.sender].name, users[msg.sender].lastName);
  }

  //addCandidate
  function addCandidate(address walletAddress, string calldata description, string calldata purpose, string calldata socialContribution, uint8 age, uint8 grade) external onlyOwner {
    _counter.increment();
    uint _id = _counter.current();
    candidates[_id] = Candidate(walletAddress, description, purpose, socialContribution, age, grade, _id, 0, false, 0);
  }

  function createElection(uint16 _total_vote_to_end) external onlyOwner {
    require(totalDonations >= distributionAmount * 12, "Not enough donations to choose a recipient for the scholarship");

    _electionCounter.increment();
    electionHistory[_electionCounter.current()] = Election(0, _total_vote_to_end, true);
  }

  // Bağış yapmak için bu işlevi kullanabilirsiniz
  function donate() external payable {  // !!!
    require(msg.sender.balance >= msg.value, "Not enough BNB");
    require(msg.value >= minDonation, "Bagis miktari minDonation'dan buyuk olmali.");
    
    totalDonations += msg.value;

    donations.push(Donation(msg.sender, msg.value));
    
    // Bağış yapıldı olayını tetikle
    emit DonationReceived(msg.sender, msg.value);
  }

  // Dağıtım işlemini başlatan işlev
  function distributeDonations() external onlyOwner() {
    require(totalDonations >= distributionAmount * recipients.length, "Dagitilacak bakiye yetersiz.");

    delete validRecipients;
    
    for (uint16 i = 0; i < recipients.length; i++) {
      require(recipients[i].monthsOfScholarship < 12, "The scholarship period has ended for the recipient.");

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

  function vote(uint16 choice) external active newVoter(msg.sender) {

    Election storage election = electionHistory[_electionCounter.current()];
    election.currentVoteCount ++;

    candidates[choice].voteCount ++;

    voted_addresses.push(msg.sender);

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

  function isVoted(address _address) private view returns (bool) {
    require(isUser(_address), "Only donors can vote.");

    address[] memory _voted_addresses = voted_addresses;
    for (uint16 i = 0; i < _voted_addresses.length; i++) 
    {
        if(_voted_addresses[i] == _address)       // _voted_addresses or voted_addresses   ???
        {
            return true;
        }
    }
    return false;
  }

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



  //Query Functions

  //isUser
  function isUser(address walletAddress) private view returns(bool) {
    return (donors[walletAddress].walletAddress != address(0) || anonimDonors[walletAddress].walletAddress != address(0));
  }

  function getOwner() external view returns (address) {
    return owner;
  }

  function getDonor(address walletAddress) external view returns(Donor memory) {
    require(isUser(walletAddress), "User does not exist!");
    return donors[walletAddress];
  }
  function getAnonimDonor(address walletAddress) external view returns(AnonimDonor memory) {
    require(isUser(walletAddress), "User does not exist!");
    return anonimDonors[walletAddress];
  }

  function getCandidate(uint256 candidateId) external view returns(Candidate memory) {
    return candidates[candidateId];
  }

  function getDonationInfo() external view returns(uint256) {
    return distributionAmount;
  }

  function getTotalDonations() external view returns (uint256) {
    return totalDonations;
  }

  function getElection(uint256 index) external view returns (Election memory) {
      return electionHistory[index];
  }
}
