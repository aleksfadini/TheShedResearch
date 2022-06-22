use anyhow::{anyhow, Result};
use mpl_token_metadata::deser::meta_deser;
use mpl_token_metadata::pda::find_metadata_account;
use mpl_token_metadata::state::Metadata;
use solana_client::{
    rpc_client::RpcClient, rpc_request::TokenAccountsFilter, rpc_response::RpcKeyedAccount,
};
use solana_sdk::{
    account::Account,
    commitment_config::CommitmentConfig,
    program_pack::{IsInitialized, Pack},
    pubkey::Pubkey,
};
use std::{fmt::Debug, str::FromStr, time::Duration};

// const SERUM_ENDPOINT: &str = "https://solana-api.projectserum.com";
pub const MAINNET_ENDPOINT: &str = "https://api.mainnet-beta.solana.com";
// const DEVNET_ENDPOINT: &str = "https://api.devnet.solana.com";

pub struct NFTFullInfo {
    pub account_key: Pubkey,
    pub account_raw: Account,
    pub account: spl_token::state::Account,
    pub mint_key: Pubkey,
    pub mint_raw: Account,
    pub mint: spl_token::state::Mint,
    pub pda_key: Pubkey,
    pub pda_raw: Account,
    pub metadata: mpl_token_metadata::state::Metadata,
}

pub struct NFTInfo {
    pub account: Pubkey,
    pub mint: Pubkey,
    pub name: Option<String>,
    pub symbol: Option<String>,
    pub collection: Option<Pubkey>,
    pub offchain_metadata_url: Option<String>,
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

pub fn solana_client(endpoint_url: &str) -> RpcClient {
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

pub fn filter_collection_nfts(
    accounts: impl Iterator<Item = NFTInfo>,
    collection_address: Option<Pubkey>,
) -> impl Iterator<Item = NFTInfo> {
    let x = accounts.filter_map(move |info| {
        if collection_address.is_none() || collection_address == info.collection {
            Some(info)
        } else {
            None
        }
    });
    x
}

pub fn fetch_wallet_nfts(client: &RpcClient, tokens: &[RpcKeyedAccount]) -> Vec<NFTInfo> {
    tokens
        .iter()
        .map(|account| fetch_nft_info(client, &account.pubkey))
        .collect()
}

pub fn fetch_wallet_tokens(client: &RpcClient, owner: &Pubkey) -> Vec<RpcKeyedAccount> {
    let program_id = spl_token::id();
    client
        .get_token_accounts_by_owner(&owner, TokenAccountsFilter::ProgramId(program_id.clone()))
        .unwrap()
}

pub fn fetch_nft_info(client: &RpcClient, account: &str) -> NFTInfo {
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

pub fn fetch_nft_full_info(client: &RpcClient, account: &str) -> NFTFullInfo {
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

pub fn to_typed_account<T>(account: &Account) -> T
where
    T: Pack + IsInitialized,
{
    T::unpack(&account.data).unwrap()
}

pub fn fetch_account(client: &RpcClient, key: &str) -> (Pubkey, Account) {
    let pubkey = Pubkey::from_str(key).unwrap();
    let account = client.get_account(&pubkey).unwrap();
    (pubkey, account)
}

pub fn find_metadata_pda(mint: &Pubkey) -> Pubkey {
    let (pda, _bump) = find_metadata_account(mint);
    pda
}

pub type PdaInfo<T> = (Pubkey, T);

pub fn get_metadata(mint: &Pubkey, client: &RpcClient) -> Result<PdaInfo<Metadata>> {
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
