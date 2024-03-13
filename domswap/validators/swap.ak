use aiken/dict
use aiken/hash.{Blake2b_224, Hash}
use aiken/string
//use aiken/list
// use aiken/transaction.{OutputReference, ScriptContext, Transaction} as tx
use aiken/transaction.{Input, NoDatum, Output, ScriptContext, Transaction} as tx
use aiken/transaction.{Mint, OutputReference, TransactionId}
use aiken/transaction/credential.{
  Address, VerificationKey, VerificationKeyCredential,
}
use aiken/transaction/value
use aiken/cbor


type Redeemer {
  Burn { assetName: ByteArray }
}

//pass policy to validator build
validator(policy_id: ByteArray) {
  fn holder(redeemer: Redeemer, ctx: ScriptContext) {
    let ScriptContext { transaction, .. } = ctx
    let Transaction { mint, .. } = transaction

    let policy_mint_list =
      value.from_minted_value(mint) //convert value to trx outputs
        |> value.tokens(policy_id) //only the outputs w tokens of policy
        |> dict.to_list()

    trace "test"

    expect [(name, amount)] = policy_mint_list

    trace string.from_int(amount)
    // trace cbor.diagnostic(name) == cbor.diagnostic(redeemer.assetName)
    trace cbor.diagnostic(name)
    trace cbor.diagnostic(redeemer.assetName)
    trace cbor.diagnostic(redeemer)
    trace cbor.diagnostic(policy_id)

    when redeemer is {
      Burn { assetName } -> amount == -1 && assetName == name
    }
  }
}

test holder_example() {
  let redeemer =
    Burn {
      assetName: #"000de14073616d706c655f7365743131",
    }
  
  let policy_id = #"de383a04ea577b55882ea3084aab822adcba607b2467d09314f1817d"

  let val = value.from_asset(policy_id: policy_id, asset_name: #"000de14073616d706c655f7365743131", quantity: -1)

  let context =
    ScriptContext {
      purpose: Mint(policy_id),
      transaction: Transaction {
        ..transaction.placeholder(),
        mint: value.to_minted_value(val)
      }
    }

  holder(policy_id, redeemer, context)
}
//asset
//"8192e5ae7627ee746d2d6202764b41b71dc19316655127837a46cf78000de140000de140776f726c6420646f6d696e6174696f6e36"
