const fs = require("fs");
const CharityContract = artifacts.require("CharityContract");

module.exports = async function (deployer) {
  await deployer.deploy(CharityContract);
  const instance = await CharityContract.deployed();
  let charityContractAddress = await instance.address;

  let config = "export const charityContractAddress = " + charityContractAddress;

  console.log("charityContractAddress = " + charityContractAddress);

  let data = JSON.stringify(config);

  fs.writeFileSync("config.js", JSON.parse(data));
};
