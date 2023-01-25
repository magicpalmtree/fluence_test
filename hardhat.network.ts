import dotenv from "dotenv";
dotenv.config();

declare let process : {
  env: {
    RINKEBY_RPC_URL: string,
    RINKEBY_PRIVATE_KEY: string,
  }
}

export const networks = {
  rinkeby: {
    url: process.env.RINKEBY_RPC_URL,
    accounts: [`${process.env.RINKEBY_PRIVATE_KEY}`]
  },
};