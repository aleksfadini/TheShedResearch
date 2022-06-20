#![allow(dead_code)]
#![allow(unused_variables)]

use solana_client::{rpc_client::RpcClient, rpc_request::TokenAccountsFilter};
use solana_sdk::{commitment_config::CommitmentConfig, pubkey::Pubkey, program_pack::Pack};
use std::{str::FromStr, time::Duration};

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

    let token1 = Pubkey::from_str("Emb4Td3VrhsYa4jE5jMNsa8FYibWb81Y8VcKotKHibzZ").unwrap();
    let result = client.get_token_account(&token1).unwrap();
    println!("{result:#?}");

    let data = client.get_account_data(&token1).unwrap();
    println!("data: {} {data:?}", data.len());
    let account = spl_token::state::Account::unpack(&data).unwrap();
    println!("account: {account:#?}");

    // let result = client.get_account(&owner).unwrap();

    // println!("{result:?}");
}
