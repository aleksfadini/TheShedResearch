// #![allow(dead_code)]
// #![allow(unused_variables)]
// #![feature(type_name_of_val)]

use mpl_token_metadata::state::Metadata;
use nft_detection::{
    fetch_nft_full_info, fetch_nft_info, fetch_wallet_tokens, solana_client, NFTFullInfo,
    MAINNET_ENDPOINT,
};
use solana_sdk::{account::Account, pubkey::Pubkey};
use std::{fmt::Debug, str::FromStr};

fn main() {
    let owner = match std::env::args().nth(1) {
        Some(string) => Pubkey::from_str(&string).unwrap(),
        None => {
            eprintln!("Usage: nft-detection <WALLET_ADDRESS> [-v]");
            std::process::exit(1);
        }
    };

    let client = solana_client(MAINNET_ENDPOINT);
    let result = fetch_wallet_tokens(&client, &owner);

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
