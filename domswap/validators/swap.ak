use aiken/dict
//use aiken/list
// use aiken/transaction.{OutputReference, ScriptContext, Transaction} as tx
use aiken/transaction.{ScriptContext, Transaction} as tx
use aiken/transaction/value

type Redeemer {
    Withdraw { assetName: ByteArray }
}

//pass policy to validator build
validator(policy_id: ByteArray) {
  fn holder(redeemer: Redeemer, ctx: ScriptContext) {
    let ScriptContext { transaction, .. } = ctx
    let Transaction { mint, .. } = transaction

      let policy_mint_list =
        value.from_minted_value(mint)//convert value to trx outputs
        |> value.tokens(policy_id)//only the outputs w tokens of policy
        |> dict.to_list()

      expect [(name, amount)] = policy_mint_list

    when redeemer is {
      Withdraw {assetName} ->
        amount == -1 && assetName == name
    }
  }
}
