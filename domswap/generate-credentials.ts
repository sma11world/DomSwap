// import { Lucid } from "https://deno.land/x/lucid@0.8.3/mod.ts";

// const lucid = await Lucid.new(undefined, "Preview");

// const privateKey = lucid.utils.generatePrivateKey();
// await Deno.writeTextFile("me.sk", privateKey);

// const address = await lucid
//   .selectWalletFromPrivateKey(privateKey)
//   .wallet.address();
// await Deno.writeTextFile("me.addr", address);

import { Lucid } from "https://deno.land/x/lucid@0.8.3/mod.ts";

const lucid = await Lucid.new(undefined, "Preview");

const ownerPrivateKey = lucid.utils.generatePrivateKey();
await Deno.writeTextFile("owner.sk", ownerPrivateKey);

const ownerAddress = await lucid
  .selectWalletFromPrivateKey(ownerPrivateKey)
  .wallet.address();
await Deno.writeTextFile("owner.addr", ownerAddress);

const beneficiaryPrivateKey = lucid.utils.generatePrivateKey();
await Deno.writeTextFile("beneficiary.sk", beneficiaryPrivateKey);

const beneficiaryAddress = await lucid
  .selectWalletFromPrivateKey(beneficiaryPrivateKey)
  .wallet.address();
await Deno.writeTextFile("beneficiary.addr", beneficiaryAddress);
