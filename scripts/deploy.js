async function main() {
    const NFTMarketplaceContract = await ethers.deployContract("NFTMarketplace");
    console.log("Contract deployed to address:", NFTMarketplaceContract.target);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });