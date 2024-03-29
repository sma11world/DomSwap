//use aiken/dict.{Dict}
use aiken/list.{filter, length}
use aiken/transaction.{
  Input, Mint, NoDatum, Output, OutputReference, ScriptContext, ScriptPurpose,
  Transaction, TransactionId,
}
use aiken/transaction/credential.{Address, ScriptCredential}
use aiken/bytearray
use aiken/string
use aiken/cbor
use aiken/transaction/value.{
  Value, flatten, from_asset, from_minted_value, quantity_of,
}

//Request contract must be included inside the Borrower NFT contract, this is the hash of the request contract
const databaseContract =
  #"de383a04ea577b55882ea3084aab822adcba607b2467d09314f1817d" //( idk )

  //contract where merkele tree is stored, random until finalized ()

//policyId
const policyBase = #"de383a04ea577b55882ea3084aab822adcba607b2467d09314f1817d"

//we pass in the redeemer the transaction to look for
type Redeemer {
  Create { assetName: ByteArray }
  Burn
}

// pub type MapDatum =
//   Dict<ByteArray, ByteArray>

// type Datum {
//   map: MapDatum,
//   policy: ByteArray,
// }

validator {
  fn minter(redeemer: Redeemer, ctx: ScriptContext) {
    trace "yooo!!!"
    //the policy is evaluated from the tx purpose
    let policy: ByteArray = get_policy(ctx.purpose)

    // trace cbor.diagnostic(redeemer)
    // trace cbor.diagnostic(policy)
    // trace cbor.diagnostic(ctx)
    // trace bytearray.is_empty(policy)
    // trace bytearray.to_string(policy)
    // trace string.from_bytearray(policy)

    when redeemer is {
      //We can only mint
      Create { assetName } -> and {
          trace cbor.diagnostic(assetName)
          trace cbor.diagnostic(policy)
          trace cbor.diagnostic(ctx.transaction.mint)
          //trace string.from_bytearray(assetName)
          only_one_token_minted(
            from_minted_value(ctx.transaction.mint),
            policy,
            assetName,
          ),
          //only one token with the right name minted
          token_goes_to_hyperspace(
            policyBase,
            assetName,
            ctx.transaction.outputs,
            databaseContract,
          ),
          //token goes to contract
          //input_is_included(utxo, index, ctx.transaction.inputs),
          //there is one input coming from the contract containing the right value

          //validate_datum_output(
          // ctx.transaction,
          // policy,
          // tokenName,
          // databaseContract,
          //),
          one_datum_one_contract_outputs(
            ctx.transaction.outputs,
            databaseContract,
          ),
        }
      Burn -> token_is_burnt(from_minted_value(ctx.transaction.mint))//anything can burn (?)
    }
  }
}

//get policyID of the
fn get_policy(purpose: ScriptPurpose) {
  expect Mint(a) = purpose
  a
}

//only 1 nft is minted
fn only_one_token_minted(minted: Value, policy: ByteArray, tokenName: ByteArray) {
  //we get only the list of tokens that are minted
  let positiveMint = filter(flatten(minted), fn(x) { x.3rd > 0 })
  //this list must be equal to the list containing only the right token
  positiveMint == flatten(from_asset(policy, tokenName, 1))
}

//we want that minted tokens are 0, burnt is allowed
fn token_is_burnt(minted: Value) {
  //we get only the list of tokens that are minted
  let positiveMint = filter(flatten(minted), fn(x) { x.3rd > 0 })
  //this list must have 0 size
  length(positiveMint) == 0
}

//function that checks if a token goes to specific contract
fn token_goes_to_hyperspace(
  policy: ByteArray,
  tokenName: ByteArray,
  txOutputs: List<Output>,
  contract: ByteArray,
) {
  let outputList =
    list.filter(
      txOutputs,
      fn(output) {
        when output.datum is {
          NoDatum -> False
          _ -> True
        }
      },
    )
  expect Some(maybeOutput) = list.head(outputList)
  when maybeOutput.address.payment_credential is {
    ScriptCredential(a) ->
      if a == contract {
        quantity_of(maybeOutput.value, policy, tokenName) == 1
      } else {
        fail
      }
    _ -> fail
  }
}

fn input_is_included(tx: ByteArray, index: Int, txInputs: List<Input>) {
  let id = TransactionId { hash: tx }
  let waited = OutputReference { transaction_id: id, output_index: index }
  let inputList =
    list.filter(txInputs, fn(input) { input.output_reference == waited })
  length(inputList) == 1
}

//the output to the contract is the same output with datum, and there cannot be more than one output with datum and more than one to the contract
fn one_datum_one_contract_outputs(txOutputs: List<Output>, contract: ByteArray) {
  let maybeOutput =
    list.filter(
      txOutputs,
      fn(output) {
        when output.address.payment_credential is {
          ScriptCredential(a) -> a == contract
          _ -> False
        }
      },
    )
  let outputList =
    list.filter(
      txOutputs,
      fn(output) {
        when output.datum is {
          NoDatum -> False
          _ -> True
        }
      },
    )
  and {
    length(outputList) == 1,
    outputList == maybeOutput,
  }
}