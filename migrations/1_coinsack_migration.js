const Migrations = artifacts.require("Migrations");
const CoinSackToken = artifacts.require("CoinSackToken");
const IPancakeRouter02 = artifacts.require("IPancakeRouter02");

const TestnetPancakeRouter = '0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3';
const MainnetPancakeRouter = '0x10ED43C718714eb63d5aA57B78B54704E256024E';

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(Migrations);

  let coinSackToken, currentTx;
  if(network == 'testnet'){
    coinSackToken = await deployer.deploy(CoinSackToken, TestnetPancakeRouter);

    console.log("\n   Configuring 'CoinSackToken'");
    console.log("   ---------------------------");

    currentTx = await coinSackToken.addManagementFeesReciever('0x019a76Bd55232A1D90EAa466C69F1AaAA520be71');
    console.log(`   > transaction hash: ${currentTx.tx}`);

    currentTx = await coinSackToken.addManagementFeesReciever('0x9a2e85b5112f8367Ac7748e9282eC542D5F0C257');
    console.log(`   > transaction hash: ${currentTx.tx}`);

    currentTx = await coinSackToken.setMinPendingFeesForAutoLiquify(BigInt(750000000));
    console.log(`   > transaction hash: ${currentTx.tx}`);

    currentTx = await coinSackToken.setMinReserveETHForAutoBuyback(BigInt(1000000000000));
    console.log(`   > transaction hash: ${currentTx.tx}`);

    currentTx = await coinSackToken.setMinReserveETHForAutoReinject(BigInt(110000000000000000));
    console.log(`   > transaction hash: ${currentTx.tx}`);

    console.log("\n   Configuring 'PancakeRouter'");
    console.log("   ---------------------------");

    var pancakeRouter = await IPancakeRouter02.at(TestnetPancakeRouter);

    currentTx = await coinSackToken.approve(pancakeRouter.address, BigInt(90000000000000));
    console.log(`   > transaction hash: ${currentTx.tx}`);

    currentTx = await pancakeRouter.addLiquidityETH(coinSackToken.address, 90000000000000, 0, 0, coinSackToken.address, Math.floor(Date.now() / 1000) + 300, {value: 1000000000000000000});
    console.log(`   > transaction hash: ${currentTx.tx}`);

    console.log("\n   Configuring 'CoinSackToken'");
    console.log("   ---------------------------");

    currentTx = await coinSackToken.setLimitsEnabled(true);
    console.log(`   > transaction hash: ${currentTx.tx}`);

    currentTx = await coinSackToken.setFeesEnabled(true);
    console.log(`   > transaction hash: ${currentTx.tx}`);

    currentTx = await coinSackToken.setAutoFeeLiquifyEnabled(true);
    console.log(`   > transaction hash: ${currentTx.tx}`);

    currentTx = await coinSackToken.setAutoBuybackEnabled(true);
    console.log(`   > transaction hash: ${currentTx.tx}`);

    currentTx = await coinSackToken.setAutoReinjectEnabled(true);
    console.log(`   > transaction hash: ${currentTx.tx}`);
  } else {
    coinSackToken = await deployer.deploy(CoinSackToken, MainnetPancakeRouter);
    
    console.log("\n   Configuring 'CoinSackToken'");
    console.log("   ---------------------------");

    currentTx = await coinSackToken.addManagementFeesReciever('0x6C7906aa7a76B0d4Dbce9b7CeEd23A5BF8B1b2fb');
    console.log(`   > transaction hash: ${currentTx.tx}`);

    currentTx = await coinSackToken.addManagementFeesReciever('0x909648D4A2af7a4A52f1607d3Ce187249ac0137F');
    console.log(`   > transaction hash: ${currentTx.tx}`);
  }
  currentTx = await coinSackToken.sendTransaction({from: accounts[0], value: 100000000000000000});
  console.log(`   > transaction hash: ${currentTx.tx}`);

};
