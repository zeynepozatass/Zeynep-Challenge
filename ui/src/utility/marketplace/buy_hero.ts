import { Transaction } from "@mysten/sui/transactions";

export const buyHero = (packageId: string, listHeroId: string, priceInSui: string) => {
  const tx = new Transaction();
  

  const priceInMist = Number(priceInSui) * 1_000_000_000;


  const [coin] = tx.splitCoins(tx.gas, [tx.pure.u64(priceInMist)]);

  
  tx.moveCall({
    target: `${packageId}::marketplace::buy_hero`,
    arguments: [
      tx.object(listHeroId), 
      coin,                  
    ],
  });
    
  return tx;
};