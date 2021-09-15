const MarebitsPresale = artifacts.require("MarebitsPresale");
const ethWallet = "0x00Ad9AEb02CC7892c94DBd9E9BE93Ec5cf644632";
const tokenAddress = "0x35c94a5a563d7dc00b7edaa455e0a931691deb27";

const now = new self.Date();
const startTime = now.getTime() + (now.getTimezoneOffset() * 60 * 1000) + 60 * 1000;
const endTime = startTime + 300 * 1000;

module.exports = async function (deployer) {
        await deployer.deploy(MarebitsPresale, "1000000000000000000000", ethWallet, "30000000000000000", startTime, endTime);
};
