const LisprocoinPresale = artifacts.require("LisprocoinPresale");
const Migrations = artifacts.require("Migrations");

const self = this;
const URL = require("url").URL;
const addresses = {
	development: { maticWallet: "0xD0355200111C2B21AAbC1a31552eCCDc5d4E905d, tokenAddress: "0x70E546c7a2cA4495cFcbE263a3b6D5ce68B2204C" }, 
	main: { maticWallet: "0x6e6B7af155865C5e641CC22ba9F2a5316A3e5777", tokenAddress: "0x65Abd48bC38DEA1938AE94428590d4da54f74Fbe" }, 
	ropsten: { ethWallet: "", tokenAddress: "" }
};
const saleCap = "2"; // max amount of ETH to be raised
const saleRate = "60753271517"; // tokens per ETH
const minPurchase = "1".padEnd(20 - saleRate.length, "0"); // minimum purchase amount, in wei
const startTimeOffsetMinutes = 5; // minutes from beginning of deployment
const endTimeOffsetMinutes = 30; // minutes from beginning of deployment
const etherScanGasOracleURL = new URL("https://api.etherscan.io/api?module=gastracker&action=gasoracle");
const gasLimit = 100000;

const { ETHERSCAN_API_KEY } = require("../secrets.json");
// const MareBitsABI = require("../MareBits ABI.json");
const fetch = require("node-fetch");
const now = new self.Date();
const web3 = Migrations.interfaceAdapter.web3;
etherScanGasOracleURL.searchParams.append("apikey", ETHERSCAN_API_KEY);

async function getGas() {
	const responseObject = await fetch(etherScanGasOracleURL);
	const response = await responseObject.json();
	return { gasPrice: { value: response.result.SafeGasPrice, writable: true }, gas: { value: gasLimit * self.Number.parseInt(response.result.SafeGasPrice), writable: true } };
}

module.exports = async function(deployer, network) {
	const { ethWallet, tokenAddress } = addresses[network];
	const startTime = self.Math.round((now.getTime() + startTimeOffsetMinutes * 60 * 1000) / 1000);
	const endTime = startTime + endTimeOffsetMinutes * 60;
	const options = { from: ethWallet };
	// const MareBits = new web3.eth.Contract(MareBitsABI, tokenAddress);

	self.Object.defineProperties(options, await getGas());
	await deployer.deploy(MarebitsPresale, saleRate, ethWallet, tokenAddress, web3.utils.toWei(saleCap), startTime, endTime, minPurchase, options);
	// await MareBits.methods.transfer(tokenAddress, saleCap).call(options);
};
