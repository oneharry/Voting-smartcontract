const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("getAllCandidates", function () {
  it("Should return names and ids of candidates", async function () {
    const Voting = await ethers.getContractFactory("Voting");
    const voting = await Voting.deploy();
    await voting.deployed();

  //check that a candidate has been added
    const tx = await voting.addCandidate("Harr")

    //get the candidates
    const candidate = await voting.getAllCandidates();


    expect(await candidate[0][0]).to.equal("Harr");
  });
});

describe("compile Result", function () {
  it("Should return names and votecounts", async function () {
    //deploy contract
    const Voting = await ethers.getContractFactory("Voting");
    const voting = await Voting.deploy();
    await voting.deployed();

    //create a candidate
    //cast vote for the candidate
    await voting.addCandidate("Harr")
    await voting.vote(0);
    const result = await voting.compileResult();

    //test for the values
    expect(await result[0][0]).to.equal("Harr");
    expect(await result[1][0]).to.equal("1");
  });
});