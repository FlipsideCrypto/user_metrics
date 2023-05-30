import * as fs from "fs";
import pkg from "convert-bech32-address";
const { lookup } = pkg;

/*
 *
 * Set Filename here!
 *
 */
const fileName = "test.csv";

const targets = [
  "cosmos",
  "axelar",
  "osmo",
  "evmos",
  "inj",
  "stride",
  "juno",
  "secret",
  "stars",
  "umee",
  "agoric",
  "persistence",
];

console.log("Generating IBC address...");

if (!fs.existsSync(fileName)) {
  console.log(`${fileName} does not exist.`);
  process.exit(1);
}

// Read the file and split it into rows
const fileContent = fs.readFileSync(fileName, "utf-8");
let rows = fileContent.trim().split("\n");
// Remove the header row
rows.shift();

// Create an array of Addresses
const addresses = [];
console.log(rows);
rows.map((row) => {
  const cosmos = row;
  const current = {};
  // current["cosmos"] = cosmos;
  targets.forEach((target) => {
    try {
      current[target] = lookup(cosmos, target);
    } catch (e) {
      console.log("invalid: " + cosmos);
    }
  });
  addresses.push(current);
});

// Write the addresses to a file
fs.writeFileSync("addresses.json", JSON.stringify(addresses, null, 2));

console.log(addresses);
