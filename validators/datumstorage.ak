use aiken/dict.{Dict}
use aiken/list.{filter, length}
use aiken/transaction.{ScriptContext}

type Redeemer {
  Withdraw { assetName: ByteArray }
}

pub type MapDatum =
  Dict<ByteArray, ByteArray>

type Datum {
  map: MapDatum,
  policy: ByteArray,
}

const prova = #"123456"

validator {
  fn storage(redeemer: Redeemer, ctx: ScriptContext) {
    //tokenName is the hash of the concatenation of index and txId, we drop the last 3 bytes

    when redeemer is {
      //We can only mint
      Withdraw { assetName } -> True
    }
  }
}
