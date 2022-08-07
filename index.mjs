import { loadStdlib } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';

const stdlib = loadStdlib(process.env);

const startingBalance = stdlib.parseCurrency(100);
const accDeployer = await stdlib.newTestAccount(startingBalance)
const [Att1, Att2, Att3, Att4, Att5] = await stdlib.newTestAccounts(5, startingBalance);
const theNFT = await stdlib.launchToken(accDeployer, "theNFT", "theNFT1", { supply: 1 });

const ctcDeployer = accDeployer.contract(backend);

const showBalance = async (acc, name) => {
  const amt = await stdlib.balanceOf(acc);
  const amtNFT = await stdlib.balanceOf(acc, theNFT.id);
  console.log(`${name} has ${stdlib.formatCurrency(amt)} ${stdlib.standardUnit} and ${amtNFT} of the NFT`);
};
const ctcAtt = (Att) =>
  Att.contract(backend, ctcDeployer.getInfo());

const Attachers_func = async (att, num, payamt) => {
  try {
    const ctc = ctcAtt(att);
    att.tokenAccept(theNFT.id)
    const t = parseInt(num)
    const p = stdlib.parseCurrency(payamt)
    await ctc.apis.Attachers.Attachersticketnum(t, p);

  } catch (error) {
    console.log(error);
  }

}


console.log('Starting backends...');
await showBalance(accDeployer, 'Alice')
await showBalance(Att1, 'Att1')
await showBalance(Att2, 'Att2')
await showBalance(Att3, 'Att3')
await showBalance(Att4, 'Att4')
await showBalance(Att5, 'Att5')

await Promise.all([
  ctcDeployer.p.Deployer({
    ...stdlib.hasRandom,
    tok: theNFT.id,
    number_of_winningticket: async () => {
      return parseInt(16)
    },
    View_digest: async (digest) => {
      console.log(`The digest value: ${digest}`)
    },
    maxamtofenteries: async () => {
      const maxamt = 50
      console.log(` Maximum amount of ticketnumber enteries is ${maxamt}`)
      return parseInt(maxamt)
    },
    amountforentry: async () => {
      const amt = 50
      console.log(`minimum amount for raffle entry is ${amt} Algo`)
      return stdlib.parseCurrency(amt)

    }

  }),
  await Attachers_func(Att1, 3, 50),
  await Attachers_func(Att2, 24, 50),
  await Attachers_func(Att3, 16, 50),
  await Attachers_func(Att4, 18, 50),
  //await Attachers_func(Att5, 25, 50)
]);
await showBalance(accDeployer, 'Alice')
await showBalance(Att1, 'Att1')
await showBalance(Att2, 'Att2')
await showBalance(Att3, 'Att3')
await showBalance(Att4, 'Att4')
await showBalance(Att5, 'Att5')


process.exit()
