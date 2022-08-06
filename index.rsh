'reach 0.1';
const [isOutcome, WIN, NOWIN] = makeEnum(2)
const checkwinner = (n1, n2) => {
  const result =
    n1 == n2 ? WIN : NOWIN
  return result
}
assert(checkwinner(1, 1) == WIN)
assert(checkwinner(1, 5) == NOWIN)
export const main = Reach.App(() => {
  const Deployer = Participant('Deployer', {
    ...hasRandom,
    tok: Token,
    View_digest: Fun([Digest], Null),
    number_of_winningticket: Fun([], UInt),
    amountforentry: Fun([], UInt),
    maxamtofenteries: Fun([], UInt)
  });
  const Attachers = API('Attachers', {
    Attachersticketnum: Fun([UInt, UInt], Null)
  });
  init();

  Deployer.only(() => {
    const tokenid = declassify(interact.tok)
    const entryamount = declassify(interact.amountforentry())
    const maxamtofentry = declassify(interact.maxamtofenteries())
  })
  Deployer.publish(tokenid, entryamount, maxamtofentry)

  const storagemap = new Map(Address, UInt)
  const [i, address_array, tickets_array, paytrack] =
    parallelReduce([0, Array.replicate(4, Deployer), Array.replicate(4, 0), 0])
      .invariant(balance(tokenid) == 0 && balance() == paytrack)
      .while(i < 4)
      .api(
        Attachers.Attachersticketnum,
        (d, p) => {
          check(d > 0, 'ticket number must be above zero')
          check(p > 50, 'must pay above 50 algo to enter raffle')
        },
        (_, p) => p,
        (d, p, r) => {
          r(null)
          const who = this
          storagemap[who] = d
          return [i + 1, address_array.set(i, who), tickets_array.set(i, d), paytrack + p]
        }
      )

  commit()
  Deployer.only(() => {
    const _numofwinticket = interact.number_of_winningticket()
    const [_commitnumofwinticket, _saltnumofwinticket] = makeCommitment(interact, _numofwinticket)
    const commitnumofwinticket = declassify(_commitnumofwinticket)
  })
  Deployer.publish(commitnumofwinticket)
  commit()

  Deployer.only(() => {
    const view_num = declassify(interact.View_digest(commitnumofwinticket))
  })
  Deployer.publish(view_num)
  commit()
  Deployer.only(() => {
    const saltnumofwinticket = declassify(_saltnumofwinticket)
    const numofwinticket = declassify(_numofwinticket)
  })
  Deployer.publish(saltnumofwinticket, numofwinticket)
  checkCommitment(commitnumofwinticket, saltnumofwinticket, numofwinticket)
  var [c, a_track, t_track, p_track] = [0, address_array, tickets_array, paytrack]
  invariant(balance(tokenid) == 0 && balance() == p_track)
  while (c < 4) {
    commit()
    Deployer.publish()
    const getoutcome = checkwinner(numofwinticket, t_track[c])
    if (getoutcome == WIN) {
      commit()
      Deployer.pay([[1, tokenid]])
      transfer([[1, tokenid]]).to(a_track[c])
      c = c + 1
      continue
    } else {
      c = c + 1
      continue
    }

  }
  transfer(balance()).to(Deployer)
  commit()
});
