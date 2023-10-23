import Web3 from "web3";
import SafeABI from "./ABI/CharityContract.json";

let selectedAccount;
let charityContract;
let isInitialized = false;
let charityContractAddress = "0xF37E018Bd68A71fE60668AD9D79444869B050d45";

export const init = async () => {
    // Configure contract
    let provider = window.ethereum;
  
    if (typeof provider !== "undefined") {
      provider
        .request({ method: "eth_requestAccounts" })
        .then((accounts) => {
          selectedAccount = accounts[0];
        })
        .catch((err) => {
          console.log(err);
          return;
        });
    }
  
    window.ethereum.on("accountChanged", function (accounts) {
      selectedAccount = accounts[0];
    });
  
    const web3 = new Web3(provider);
  
    const networkId = await web3.eth.net.getId();
  
    charityContract = new web3.eth.Contract(SafeABI.abi, charityContractAddress);
  
    isInitialized = true;
  };

  export const getUserAddress = async () => {
    if (!isInitialized) {
      await init();
    }
    return selectedAccount;
  };


// Execute Functions

export const setOwner = async (newOwner) => {
  if (!isInitialized) {
    await init();
  }
  try {
    let res = await charityContract.methods
    .setOwner(newOwner.toLowerCase())
    .send({ from: selectedAccount });
    return res;
  } catch(e) {
    console.error(e);
  }
};

export const register = async (name, surname) => {
  if (!isInitialized) {
    await init();
  }
  try {
    let res = await charityContract.methods
    .addDonor(name, surname)
    .send({ from: selectedAccount });
    return res;
  } catch(e) {
    console.error(e);
  }
};

export const donate = async (value) => {
  if (!isInitialized) {
    await init();
  }
  let send_value = Web3.utils.toWei(value, "ether");
  try {
    let res = await charityContract.methods
    .donate()
    .send({ from: selectedAccount, value: send_value });
    return res;
  } catch(e) {
    console.error(e);
  }
};

export const vote = async (id) => {
  if (!isInitialized) {
    await init();
  }
  try {
    let res = await charityContract.methods
    .vote(id)
    .send({ from: selectedAccount});
    return res;
  } catch(e) {
    console.error(e);
  }
};