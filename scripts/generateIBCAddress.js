import * as fs from "fs";

const fileName = "test.csv";
// import { lookup } from "convert-bech32-address";
// var converter = import("./convert-bech32-address.js");
import pkg from "convert-bech32-address";
const { lookup } = pkg;

class Addresses {
  constructor(
    cosmos = "",
    axelar = "",
    osmo = "",
    evmos = "",
    inj = "",
    stride = "",
    juno = "",
    secret = "",
    stars = "",
    umee = "",
    agoric = "",
    persistence = ""
  ) {
    this.cosmos = cosmos;
    this.axelar = axelar;
    this.osmo = osmo;
    this.evmos = evmos;
    this.inj = inj;
    this.stride = stride;
    this.juno = juno;
    this.secret = secret;
    this.stars = stars;
    this.umee = umee;
    this.agoric = agoric;
    this.persistence = persistence;
  }
}

const targets = [
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

// var newAddress = converter.lookup('cosmos1r5qkmvn9hnv0pugejr73639w07d2mughnm7qxa','juno');

// console.log(newAddress);

// return new Addresses(cosmos, axelar, osmo, evmos, inj, stride, juno, secret, stars, umee, agoric, persistence);
// }
