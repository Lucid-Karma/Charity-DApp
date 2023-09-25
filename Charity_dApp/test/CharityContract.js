const CharityContract = artifacts.require("CharityContract"); //./charityContract.sol

contract("CharityContract", accounts => {
  let charityContract;
  const owner = accounts[0];
  const user1 = accounts[1];
  const user2 = accounts[2];

  beforeEach(async () => {
    charityContract = await CharityContract.new();
  });

  describe("Add donor and candidate", () => {
    it("adds a donor", async () => {
      await charityContract.addDonor("Lily", "Leslie", {from: user1} );
      const donor = await charityContract.getDonor(user1);
      assert.equal(donor.name, "Lily", "Problem with donor name");
      assert.equal(donor.lastName, "Leslie", "Problem with donor lastname");
    });

    it("adds a candidate", async () => {
      await charityContract.addCandidate(user2, "I'm a hardworking person.", "gonna be a doctor", "no", 15, 83, {from: owner} );
      const candidate = await charityContract.getCandidate(1);
      assert.equal(candidate.walletAddress, user2, "Problem with wallet address");
      assert.equal(candidate.description, "I'm a hardworking person.", "Problem with candidate description");
      assert.equal(candidate.purpose, "gonna be a doctor", "Problem with candidate purpose");
      assert.equal(candidate.socialContribution, "no", "Problem with candidate socialContribution");
      assert.equal(candidate.age, 15, "Problem with age");
      assert.equal(candidate.grade, 83, "Problem with grade");
    });
  });

  describe("Manage voting process", () => {
    it("creates an election", async () => {
      await charityContract.addCandidate(user2, "I'm a hardworking person.", "gonna be a doctor", "no", 15, 83, { from: owner });
      await charityContract.addDonor("Lily", "Leslie", {from:user1});
      await charityContract.donate({ from: user1, value: 650 });

      await charityContract.createElection(2, {from: owner} );
      //await charityContract.createElection(2, {from: owner} );
      const election = await charityContract.getElection(1);
      assert.equal(election.currentVoteCount, 0, "Problem with current election's vote count");
      assert.equal(election.totalVoteToEnd, 2, "Problem with current election's totalVoteToEnd variable.");
      assert.equal(election.isActive, true, "Problem with current election's active state")
    });

    it("votes", async () => {   //!!!
      await charityContract.addCandidate(user2, "I'm a hardworking person.", "gonna be a doctor", "no", 15, 83, { from: owner });
      await charityContract.addDonor("Lily", "Leslie", {from:user1});
      await charityContract.donate({ from: user1, value: 650 });

      await charityContract.createElection(2, {from: owner} );
      
      await charityContract.vote(1, {from: user1});
  
      const election = await charityContract.getElection(1);    // !!??
      assert.equal(election.currentVoteCount, 1, "Problem with current election's vote count after vote");
      assert.equal(election.totalVoteToEnd, 2, "Problem with current election's totalVoteToEnd variable after vote");
      assert.equal(election.isActive, true, "Problem with current election's active state after vote")
    });

    it("terminates election", async () => {
      await charityContract.addCandidate(user2, "I'm a hardworking person.", "gonna be a doctor", "no", 15, 83, { from: owner });
      await charityContract.addDonor("Lily", "Leslie", {from:user1});
      await charityContract.donate({ from: user1, value: 650 });

      await charityContract.createElection(2, {from: owner} );
      
      await charityContract.vote(1, {from: user1});

      await charityContract.terminateElection({from:owner});

      const election = await charityContract.getElection(1);
      assert.equal(election.currentVoteCount, 1, "Problem with current election's vote count after the election is terminated");
      assert.equal(election.totalVoteToEnd, 2, "Problem with current election's totalVoteToEnd variable after the election is terminated");
      assert.equal(election.isActive, false, "Problem with current election's active state after the election is terminated")
    });
  });

  describe("Manage donation process", () => {
    it("changes donation informations", async () => {
      await charityContract.setDonationInformation(30, {from: owner});
      const donationInfo = await charityContract.getDonationInfo();
      assert.equal(donationInfo, 30, "Problem with distribution amount");
    });

    it("donates", async () => {
      await charityContract.donate({from: user1, value: 100});
      const donation = await charityContract.getTotalDonations();
      assert.equal(donation, 100, "Problem with donation value.");
    });

    it("distributes donations", async () => {
      await charityContract.addDonor("Lily", "Leslie", {from:user1});
      await charityContract.addCandidate(user2, "I'm a hardworking person.", "gonna be a doctor", "no", 15, 83, { from: owner });
      await charityContract.setDonationInformation(30, { from: owner });
      await charityContract.donate({ from: user1, value: 650 });
      await charityContract.createElection(1, {from: owner});
      await charityContract.vote(1, {from: user1});

      await charityContract.distributeDonations({ from: owner });
    
      const donation = await charityContract.getTotalDonations();
    
      const expectedDonation = web3.utils.toBN(620); // Beklenen değeri BigNumber'a çevir
      assert.equal(donation.toString(), expectedDonation.toString(), "Problem with donation distribution");
    });
  });

});

