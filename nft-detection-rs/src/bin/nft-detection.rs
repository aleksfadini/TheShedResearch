#![allow(dead_code)]
#![allow(unused_variables)]
// #![feature(type_name_of_val)]

use anyhow::{anyhow, Result};
use mpl_token_metadata::deser::meta_deser;
use mpl_token_metadata::pda::find_metadata_account;
use mpl_token_metadata::state::Metadata;
use solana_client::{rpc_client::RpcClient, rpc_request::TokenAccountsFilter};
use solana_sdk::{
    commitment_config::CommitmentConfig,
    program_pack::{IsInitialized, Pack},
    pubkey::Pubkey,
};
use std::{fmt::Debug, str::FromStr, time::Duration};

const MAINNET_ENDPOINT: &str = "https://api.mainnet-beta.solana.com";
const DEVNET_ENDPOINT: &str = "https://api.devnet.solana.com";

fn solana_client(endpoint_url: &str) -> RpcClient {
    let url = endpoint_url.to_string();
    let timeout = Duration::from_secs(10);
    let commitment_config = CommitmentConfig::processed();
    let confirm_transaction_initial_timeout = Duration::from_secs(10);
    let client = RpcClient::new_with_timeouts_and_commitment(
        url,
        timeout,
        commitment_config,
        confirm_transaction_initial_timeout,
    );
    client
}

fn main() {
    let client = solana_client(MAINNET_ENDPOINT);

    let owner = Pubkey::from_str("14Bvs8pb6dvnMPDiZ3TLJ1viv19NsfpDhmDNgjB8xo3Q").unwrap();
    let author = Pubkey::from_str("Baj5PNxRVPB4J7PxD214SWzfNqLi6288y59UVkt9S4Wx").unwrap();
    let colletion = Pubkey::from_str("6L86wVKKJWHuobc4qDdB9gbZVu6tBctAk1M7TYxF8ch6").unwrap();

    let program_id = spl_token::id();

    // client.get_program_accounts_with_config(pubkey, config)
    let result = client
        .get_token_accounts_by_owner(&owner, TokenAccountsFilter::ProgramId(program_id.clone()))
        .unwrap();

    println!("{}, {result:#?}\n", result.len());

    // let result = client.get_account(&owner).unwrap();
    // println!("{result:?}");

    let account = "Emb4Td3VrhsYa4jE5jMNsa8FYibWb81Y8VcKotKHibzZ";
    let mint = "7jHNVMSB6X8NgjFHGKSQCxp6AoMycFK2rNyWCjw8E2yp";

    let result = client
        .get_token_account(&Pubkey::from_str(account).unwrap())
        .unwrap();
    println!("{result:#?}\n");

    let (account_key, account) = fetch_typed_account::<spl_token::state::Account>(&client, account);
    let (mint_key, mint) = fetch_typed_account::<spl_token::state::Mint>(&client, mint);
    // fetch_account_data(&client, "8oozoJnyB5xbrYK6tiWcgUbK2q4Eyn6v3QA9s2uTWyJE");

    let (pda_key, pda) = get_metadata_pda(&mint_key, &client).unwrap();
    let account = client.get_account(&pda_key).unwrap();
    println!("Key: {pda_key}");
    println!("Raw account: {account:#?}");
    // println!("{}: {pda:#?}", std::any::type_name_of_val(&pda));
    println!("{}: {pda:#?}", std::any::type_name::<Metadata>());
    // fetch_account_data(&client, pda_key.to_string().as_str());
}

fn fetch_typed_account<T>(client: &RpcClient, key: &str) -> (Pubkey, T)
where
    T: Pack + IsInitialized + Debug + 'static,
{
    let (pubkey, data) = fetch_account(client, key);
    let account = T::unpack(&data).unwrap();
    println!("{} -- {account:#?}\n", std::any::type_name::<T>());
    (pubkey, account)
}

fn fetch_account(client: &RpcClient, key: &str) -> (Pubkey, Vec<u8>) {
    let pubkey = Pubkey::from_str(key).unwrap();
    println!("Key: {pubkey}");

    let account = client.get_account(&pubkey).unwrap();
    println!("Raw account: {account:#?}");
    (pubkey, account.data)
}

fn fetch_account_data(client: &RpcClient, key: &str) -> (Pubkey, Vec<u8>) {
    let pubkey = Pubkey::from_str(key).unwrap();
    println!("Key: {pubkey}");
    // let result = client.get_token_account(&pubkey).unwrap();
    // println!("{result:#?}");

    let data = client.get_account_data(&pubkey).unwrap();
    println!("Raw data: {} {data:?}", data.len());
    (pubkey, data)
}

pub fn find_metadata_pda(mint: &Pubkey) -> Pubkey {
    let (pda, _bump) = find_metadata_account(mint);
    pda
}

pub type PdaInfo<T> = (Pubkey, T);

pub fn get_metadata_pda(mint: &Pubkey, client: &RpcClient) -> Result<PdaInfo<Metadata>> {
    let metadata_pubkey = find_metadata_pda(mint);
    let metadata_account = client.get_account(&metadata_pubkey).map_err(|_| {
        anyhow!(
            "Couldn't find metadata account: {}",
            &metadata_pubkey.to_string()
        )
    })?;
    let metadata = meta_deser(&mut metadata_account.data.as_slice());
    metadata.map(|m| (metadata_pubkey, m)).map_err(|_| {
        anyhow!(
            "Failed to deserialize metadata account: {}",
            &metadata_pubkey.to_string()
        )
    })
}
