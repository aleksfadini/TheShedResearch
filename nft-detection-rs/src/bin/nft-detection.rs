// #![allow(dead_code)]
// #![allow(unused_variables)]
// #![feature(type_name_of_val)]

use anyhow::{anyhow, Result};
use mpl_token_metadata::deser::meta_deser;
use mpl_token_metadata::pda::find_metadata_account;
use mpl_token_metadata::state::Metadata;
use solana_client::{rpc_client::RpcClient, rpc_request::TokenAccountsFilter};
use solana_sdk::{
    account::Account,
    commitment_config::CommitmentConfig,
    program_pack::{IsInitialized, Pack},
    pubkey::Pubkey,
};
use std::{fmt::Debug, str::FromStr, time::Duration};

// const SERUM_ENDPOINT: &str = "https://solana-api.projectserum.com";
const MAINNET_ENDPOINT: &str = "https://api.mainnet-beta.solana.com";
// const DEVNET_ENDPOINT: &str = "https://api.devnet.solana.com";

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
    let owner = match std::env::args().nth(1) {
        Some(string) => Pubkey::from_str(&string).unwrap(),
        None => {
            eprintln!("Usage: nft-detection <WALLET_ADDRESS> [-v]");
            std::process::exit(1);
        }
    };
    let program_id = spl_token::id();
    let client = solana_client(MAINNET_ENDPOINT);
    let result = client
        .get_token_accounts_by_owner(&owner, TokenAccountsFilter::ProgramId(program_id.clone()))
        .unwrap();

    if let Some("-v") = std::env::args().nth(2).as_deref() {
        let sep = "-".repeat(60);
        for account in result.iter() {
            println!("{sep}\n{account:#?}");
            let info = fetch_nft_full_info(&client, &account.pubkey);
            print_nft_verbose(&info);
            println!();
        }
    } else {
        for account in result.iter() {
            let info = fetch_nft_info(&client, &account.pubkey);
            println!("{info:#?}");
        }
    }
}

struct NFTFullInfo {
    account_key: Pubkey,
    account_raw: Account,
    account: spl_token::state::Account,
    mint_key: Pubkey,
    mint_raw: Account,
    mint: spl_token::state::Mint,
    pda_key: Pubkey,
    pda_raw: Account,
    metadata: mpl_token_metadata::state::Metadata,
}

struct NFTInfo {
    account: Pubkey,
    mint: Pubkey,
    name: Option<String>,
    symbol: Option<String>,
    collection: Option<Pubkey>,
    offchain_metadata_url: Option<String>,
}

impl Debug for NFTInfo {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let mut t = f.debug_struct("NFTInfo");
        macro_rules! field {
            ($name:ident) => {
                t.field(stringify!($name), &self.$name)
            };
        }
        macro_rules! field_opt {
            ($name:ident) => {
                if let Some(x) = &self.$name {
                    t.field(stringify!($name), x);
                }
            };
        }
        field_opt!(symbol);
        field_opt!(name);
        field!(account);
        field!(mint);
        field_opt!(collection);
        field_opt!(offchain_metadata_url);
        t.finish()
    }
}

fn print_nft_verbose(info: &NFTFullInfo) {
    print_account(&info.account_key, &info.account_raw);
    print_typed_account(&info.account);
    print_account(&info.mint_key, &info.mint_raw);
    print_typed_account(&info.mint);
    print_account(&info.pda_key, &info.pda_raw);
    print_typed_account(&info.metadata);
    println!(
        "{}: {:#?}",
        std::any::type_name::<Metadata>(),
        &info.metadata
    );
}

fn print_typed_account<T: Debug>(account: &T) {
    println!("{} -- {account:#?}\n", std::any::type_name::<T>());
}

fn print_account(pubkey: &Pubkey, account: &Account) {
    println!("Key: {pubkey}");
    println!("Raw account: {account:#?}");
}

fn fetch_nft_info(client: &RpcClient, account: &str) -> NFTInfo {
    let (account, mint) = {
        let (account_key, account_raw) = fetch_account(&client, account);
        let account: spl_token::state::Account = to_typed_account(&account_raw);
        (account_key, account.mint)
    };
    let (symbol, name, collection, offchain_metadata_url) = {
        let (mint_key, _) = fetch_account(&client, &mint.to_string());
        let (_, metadata) = get_metadata(&mint_key, &client).unwrap();
        let collection = metadata.collection.unwrap().key;
        let symbol = metadata.data.symbol.trim_end_matches('\0').to_owned();
        let name = metadata.data.name.trim_end_matches('\0').to_owned();
        let url = metadata.data.uri.trim_end_matches('\0').to_owned();
        (symbol, name, collection, url)
    };
    NFTInfo {
        account,
        mint,
        name: Some(name),
        symbol: Some(symbol),
        collection: Some(collection),
        offchain_metadata_url: Some(offchain_metadata_url),
    }
}

fn fetch_nft_full_info(client: &RpcClient, account: &str) -> NFTFullInfo {
    let (account_key, account_raw) = fetch_account(&client, account);
    let account: spl_token::state::Account = to_typed_account(&account_raw);
    let (mint_key, mint_raw) = fetch_account(&client, &account.mint.to_string());
    let mint: spl_token::state::Mint = to_typed_account(&mint_raw);
    let (pda_key, metadata) = get_metadata(&mint_key, &client).unwrap();
    let (pda_key, pda_raw) = fetch_account(&client, &pda_key.to_string());
    NFTFullInfo {
        account_key,
        account_raw,
        account,
        mint_key,
        mint_raw,
        mint,
        pda_key,
        pda_raw,
        metadata,
    }
}

fn to_typed_account<T>(account: &Account) -> T
where
    T: Pack + IsInitialized,
{
    T::unpack(&account.data).unwrap()
}

fn fetch_account(client: &RpcClient, key: &str) -> (Pubkey, Account) {
    let pubkey = Pubkey::from_str(key).unwrap();
    let account = client.get_account(&pubkey).unwrap();
    (pubkey, account)
}

fn find_metadata_pda(mint: &Pubkey) -> Pubkey {
    let (pda, _bump) = find_metadata_account(mint);
    pda
}

type PdaInfo<T> = (Pubkey, T);

fn get_metadata(mint: &Pubkey, client: &RpcClient) -> Result<PdaInfo<Metadata>> {
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
