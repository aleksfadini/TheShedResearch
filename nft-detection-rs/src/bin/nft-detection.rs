#![allow(dead_code)]
#![allow(unused_variables)]

use solana_client::{rpc_client::RpcClient, rpc_request::TokenAccountsFilter};
use solana_sdk::{
    commitment_config::CommitmentConfig,
    program_pack::{IsInitialized, Pack},
    pubkey::Pubkey,
};
use anyhow::{anyhow, Result};
use mpl_token_metadata::deser::meta_deser;
use mpl_token_metadata::pda::{find_master_edition_account, find_metadata_account};
use mpl_token_metadata::state::{Key, MasterEditionV2, Metadata, MAX_MASTER_EDITION_LEN};
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

    println!("{}, {result:#?}", result.len());

    // let result = client.get_account(&owner).unwrap();
    // println!("{result:?}");

    let token1 = Pubkey::from_str("Emb4Td3VrhsYa4jE5jMNsa8FYibWb81Y8VcKotKHibzZ").unwrap();
    let mint = "7jHNVMSB6X8NgjFHGKSQCxp6AoMycFK2rNyWCjw8E2yp";

    let result = client.get_token_account(&token1).unwrap();
    println!("{result:#?}");

    fetch_account::<spl_token::state::Account>(&client, token1.to_string().as_str());
    fetch_account::<spl_token::state::Mint>(&client, mint);
    fetch_account_data(&client, "8oozoJnyB5xbrYK6tiWcgUbK2q4Eyn6v3QA9s2uTWyJE");
}

fn fetch_account<T>(client: &RpcClient, key: &str)
where
    T: Pack + IsInitialized + Debug + 'static,
{
    let data = fetch_account_data(client, key);
    let account = T::unpack(&data).unwrap();
    println!("{}: {account:#?}", std::any::type_name::<T>());
}

fn fetch_account_data(client: &RpcClient, key: &str) -> Vec<u8> {
    let pubkey = Pubkey::from_str(key).unwrap();
    println!("key: {pubkey}");
    // let result = client.get_token_account(&pubkey).unwrap();
    // println!("{result:#?}");

    let data = client.get_account_data(&pubkey).unwrap();
    println!("data: {} {data:?}", data.len());
    data
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
