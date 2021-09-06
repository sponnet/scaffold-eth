const { ethers } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");

use(solidity);

describe("My Dapp", function () {
  let baseLoogies, loogieWithTraits,stache;

  describe("YourContract", function () {
    it("Should deploy YourContract", async function () {
      const _baseLoogies = await ethers.getContractFactory("YourCollectible");
      baseLoogies = await _baseLoogies.deploy();
      expect(await baseLoogies.address).to.exist;

      const _loogieWithTraits = await ethers.getContractFactory("LoogieWithTraits");
      loogieWithTraits = await _loogieWithTraits.deploy(baseLoogies.address);

      const _stache = await ethers.getContractFactory("Stache");
      stache = await _stache.deploy();

      const _arms = await ethers.getContractFactory("Arms");
      arms = await _arms.deploy();


    });

    describe("mint - trait - and unwrap", function () {
      it("Should be able to mint", async function () {

        // mint a loogie
        await baseLoogies.mintItem();
        await baseLoogies.approve(loogieWithTraits.address,1);

        // mint loogiewithtraits and suck in loogie
        await loogieWithTraits.mintItem(1);

        // add some traits to it
        await loogieWithTraits.registerTrait(1,stache.address);
        await loogieWithTraits.registerTrait(1,arms.address);

        // now get the combined tokenURI
        const svg = await loogieWithTraits.tokenURI(1);
        console.log(`TokenURI is ${svg}`);

        // spit out original Loogie and burn loogiewithtraits
        await loogieWithTraits.unWrap(1);

        
      });
    });
  });
});
