const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFTMarketplace", function () {
    let owner, user1, user2;
    let NFTMarketplaceContract;

    beforeEach("SetUp", async function () {
        [owner, user1, user2] = await ethers.getSigners();
        NFTMarketplaceContract = await ethers.deployContract("NFTMarketplace");
    });

    it("Check owner address", async function () {
        const tx = await NFTMarketplaceContract.owner();

        expect(tx).to.equal(owner.address);
    });

    it("should be able to mint NFT", async function () {
        await NFTMarketplaceContract.connect(user1).mintNFT("http://");
        expect(await NFTMarketplaceContract.balanceOf(user1.address)).to.equal(1);
        expect(await NFTMarketplaceContract.ownerOf(1)).to.equal(user1.address);
    });

    it("should be able to mint NFT", async function () {
        await NFTMarketplaceContract.connect(user1).mintNFT("http://");
        await NFTMarketplaceContract.connect(user1).approve(NFTMarketplaceContract.target, 1);
        expect(NFTMarketplaceContract.connect(user2).listNFT(1, ethers.parseEther("1"))).to.be.reverted;
        await NFTMarketplaceContract.connect(user1).listNFT(1, ethers.parseEther("1"));
    });

    it.only("get all owned NFT", async function () {
        await NFTMarketplaceContract.connect(user1).mintNFT("http://");
        await NFTMarketplaceContract.connect(user2).mintNFT("http://");
        await NFTMarketplaceContract.connect(user1).mintNFT("http://");
        await NFTMarketplaceContract.connect(user1).mintNFT("http://");

        await NFTMarketplaceContract.connect(user1).mintNFT("http://");

        console.log(await NFTMarketplaceContract.connect(user1).userOwnedNFT(user1.address));
        // await NFTMarketplaceContract.connect(user1).approve(NFTMarketplaceContract.target, 1);
        expect(NFTMarketplaceContract.connect(user2).listNFT(1, ethers.parseEther("1"))).to.be.reverted;
        await NFTMarketplaceContract.connect(user1).listNFT(1, ethers.parseEther("1"));
        await NFTMarketplaceContract.connect(user1).listNFT(3, ethers.parseEther("1"));

        await NFTMarketplaceContract.connect(user1).listNFT(4, ethers.parseEther("1"));

        await NFTMarketplaceContract.connect(user1).listNFT(5, ethers.parseEther("1"));
        // console.log(await NFTMarketplaceContract.allowance);
        await NFTMarketplaceContract.connect(user2).listNFT(2, ethers.parseEther("1"));

        console.log(await NFTMarketplaceContract.connect(user1).getAllListedNFT());

    })

    it("should be able to buy NFT", async function () {
        const before = await ethers.provider.getBalance(user2.address)
        console.log(await ethers.provider.getBalance(user1.address));
        console.log(await ethers.provider.getBalance(NFTMarketplaceContract.target));
        await NFTMarketplaceContract.connect(user1).mintNFT("http://");
        await NFTMarketplaceContract.connect(user1).approve(NFTMarketplaceContract.target, 1);
        await NFTMarketplaceContract.connect(user1).listNFT(1, ethers.parseEther("1"));
        expect(await NFTMarketplaceContract.ownerOf(1)).to.equal(NFTMarketplaceContract.target);

        await NFTMarketplaceContract.connect(user2).buyNFT(1, { value: ethers.parseEther("1") });
        console.log(await NFTMarketplaceContract.userOwnedNFT(user2.address));

        expect(await NFTMarketplaceContract.ownerOf(1)).to.equal(user2.address);

        //check balance of buyer, seller and contract
        const after = await ethers.provider.getBalance(user2.address)
        console.log(await ethers.provider.getBalance(user1.address));
        console.log(await ethers.provider.getBalance(NFTMarketplaceContract.target));
        // console.log(await NFTMarketplaceContract.getBalance());
        console.log(before - after);
    }


    );
})