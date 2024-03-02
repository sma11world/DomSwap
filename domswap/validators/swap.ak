use aiken/dict
use aiken/list
use aiken/transaction.{OutputReference, ScriptContext, Transaction} as tx
use aiken/transaction/value
use aiken/cbor
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

    //how can i find the specific token im looking for?
    //create a list of the ones under that policy
    //and when they match up to what is sent and -1 (amount)
    
    //filter only the ones of the policy id (dont swap back wrong assets)

    //expect burn of new policy_id + asset name = token
      expect [(name, amount)] = policy_mint_list

    when redeemer is {
      Withdraw {assetName} ->
        amount == -1 && assetName == name
    }
  }
}
