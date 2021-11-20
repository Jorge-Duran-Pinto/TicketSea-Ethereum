const deploy = async () => {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    const TicketSea = await ethers.getContractFactory("TicketSea");
    const deployed = await TicketSea.deploy(10000);
  
    console.log("TicketSea address:", deployed.address);
  };
  
  deploy()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  