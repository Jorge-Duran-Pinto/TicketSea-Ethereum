const { expect } = require("chai");

describe("TicketSea Contract", () => {

    const setup = async (
        { maxSupply = 1000 } = {},
        { eventName = "Black Hat"} = {},
        { refCod = "ef20"} = {}
    ) => {

        const [owner] = await ethers.getSigners();
        const TicketSea = await ethers.getContractFactory("TicketSea");
        const deployed = await TicketSea.deploy(maxSupply, eventName, refCod);

        return {
        owner,
        deployed,
        };
    };
    describe("Deployment", () => {
        it("Sets max supply to passed param", async () => {
            const maxSupply = 10000;
            const eventName = "Black Hat";
            const refCod = "ef20";

            const { deployed } = await setup({ maxSupply }, { eventName }, {refCod});
    
            const returnedMaxSupply = await deployed.maxSupply();
            expect(maxSupply).to.equal(returnedMaxSupply);
        });
    });
    describe("Minting", () => {
        it("Mints a new token and assigns to owner", async () => {
            const { owner, deployed } = await setup();
        
            await deployed.mint();
            const ownerOfMinted = await deployed.ownerOf(0);
            expect(ownerOfMinted).to.equal(owner.address);
        });
    
        it("Has a minting limit", async () => {
          const maxSupply = 2;
          const eventName = "Black Hat";
            const refCod = "ef20";
    
          const { deployed } = await setup({
            maxSupply,
            eventName,
            refCod
          });
    
          // Mint all
          await Promise.all(new Array(2).fill().map(() => deployed.mint()));
    
          // Test last minting
          await expect(deployed.mint()).to.be.revertedWith(
            "There are no Tickets left :("
          );
        });
      });
    describe("tokenURI", () => {
      it("returns valid metadata", async () => {
        const { owner, deployed } = await setup();
        await deployed.mint();
        
        const tokenURI = await deployed.tokenURI(0);
        const stringifiedTokenURI = await tokenURI.toString();
        const [, base64JSON] = stringifiedTokenURI.split(
          "data:application/json;base64,"
        );
        const stringifiedMetadata = await Buffer.from(
          base64JSON,
          "base64"
        ).toString("ascii");
  
        const metadata = JSON.parse(stringifiedMetadata);
        
        
        expect(metadata).to.have.all.keys(
                "eventOwner",
                "eventName",
                "refCod",
                "maxSupply"
        );
        
      });
    });
});