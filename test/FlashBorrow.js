const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
  const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
  const { expect } = require("chai");
const { ethers } = require("hardhat");

  
  describe("FLASH LOAN", function(){
    async function deploy(){
        const [owner, borrower] = await ethers.getSigners();

        const TestTokenFactory = await ethers.getContractFactory("TestToken");
        const TestToken = await TestTokenFactory.deploy();

        const FlashBorrowerFactory = await ethers.getContractFactory("FlashBorrower");
        const FlashBorrower = await FlashBorrowerFactory.deploy(TestToken.target);

        await TestToken.mint(FlashBorrower.target, ethers.parseEther("10.0"));

        return {owner, borrower, TestToken, FlashBorrower}

    }
    it("Should borrow", async function(){
        const {owner, borrower, TestToken, FlashBorrower} = await loadFixture(deploy);

        expect(await TestToken.balanceOf(owner.address)).to.eq("0");

        const AMOUNT = "20000.0";
        const FEE = await TestToken.flashFee(TestToken.target, ethers.parseEther(AMOUNT));

        const abi = ethers.AbiCoder.defaultAbiCoder();

        expect(await FlashBorrower.connect(borrower)
        .flashBorrow(TestToken.target, ethers.parseEther(AMOUNT), abi.encode(["uint"], [1]))
        ).not.to.be.reverted;

        expect(await TestToken.balanceOf(owner.address)).to.eq(FEE);
    })
  })