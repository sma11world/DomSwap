
type Redeemer {
  Withdraw { assetName: ByteArray }
}

// pub type MapDatum =
//   Dict<ByteArray, ByteArray>

// type Datum {
//   map: MapDatum,
//   policy: ByteArray,
// }

validator {
  fn storage(redeemer: Redeemer, _datum) {
    //tokenName is the hash of the concatenation of index and txId, we drop the last 3 bytes

    when redeemer is {
      //We can only mint
      Withdraw { assetName } -> True
    }
  }
}
