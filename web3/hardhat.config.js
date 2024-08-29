require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
// const PRIVATE_KEY =
//   "a8d5c77d495329df24b9005cd7bcf0330677d42b4c46c31fa626fde3211da095"; // institiute key
const PRIVATE_KEY =
  "cdff9d82ae22635d0f04601ee5bc0454944e9fb95d53c5817a8da3be9715358b"; //primary address
const RPC_URL = "https://rpc.sepolia.org";
module.exports = {
  defaultNetwork: "sepolia",
  networks: {
    hardhat: {
      chainId: 11155111,
    },
    sepolia: {
      url: RPC_URL,
      accounts: [PRIVATE_KEY],
    },
  },
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};
