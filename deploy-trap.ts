import { execSync } from "child_process";
import dotenv from "dotenv";

// Load environment variables from .env
dotenv.config();

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const OPERATOR = process.env.OPERATOR;

if (!PRIVATE_KEY || !OPERATOR) {
  console.error("PRIVATE_KEY dan OPERATOR wajib diisi di file .env");
  process.exit(1);
}

try {
  console.log("Menjalankan perintah forge script...");

  // Jalankan perintah deploy menggunakan Foundry (forge)
  execSync(
    `forge script script/DeployTrap.s.sol:DeployTrap --rpc-url https://rpc.ankr.com/eth_sepolia --broadcast --private-key ${PRIVATE_KEY} --with-gas-price 1000000000 --legacy --slow`,
    { stdio: "inherit" }
  );

  console.log("Deploy selesai.");
} catch (error) {
  console.error("Gagal menjalankan deploy:", error);
  process.exit(1);
}
