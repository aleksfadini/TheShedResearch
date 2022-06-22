// #![allow(dead_code)]
// #![allow(unused_variables)]
// #![feature(type_name_of_val)]

use clap::{arg, command, Arg, ArgAction, ArgMatches};
use nft_detection::{
    fetch_nft_full_info, fetch_nft_info, fetch_wallet_tokens, solana_client, Account, Metadata,
    NFTFullInfo, NFTInfo, Pubkey, RpcKeyedAccount, MAINNET_ENDPOINT,
};
use std::{fmt::Debug, str::FromStr};

fn arg_matches() -> ArgMatches {
    let matches = command!()
        .arg(arg!(<WALLET_ADDRESS>))
        .arg(arg!([COLLECTION_ADDRESS]))
        .arg(
            Arg::new("verbose")
                .short('v')
                .long("verbose")
                .action(ArgAction::SetTrue),
        )
        .get_matches();
    matches
}

fn arg_pubkey(msg: &str) -> impl Fn(&String) -> Pubkey + '_ {
    |s: &String| Pubkey::from_str(s.as_str()).expect(msg)
}

fn main() {
    let matches = arg_matches();
    let wallet_address: Pubkey = matches
        .get_one("WALLET_ADDRESS")
        .map(arg_pubkey("Wallet address isn't valid"))
        .expect("Wallet address is required");
    let collection_address = matches
        .get_one("COLLECTION_ADDRESS")
        .map(arg_pubkey("Collection address isn't valid"));
    let verbose: Option<&bool> = matches.get_one("verbose");

    let client = solana_client(MAINNET_ENDPOINT);
    let result = fetch_wallet_tokens(&client, &wallet_address);

    let accounts = result.iter();
    if let Some(true) = verbose {
        let infos: Vec<(&RpcKeyedAccount, NFTFullInfo)> = match collection_address {
            Some(pubkey) => accounts
                .filter_map(|account| {
                    let info = fetch_nft_full_info(&client, &account.pubkey);
                    match info.metadata.collection {
                        Some(ref collection) if collection.key == pubkey => Some((account, info)),
                        _ => None,
                    }
                })
                .collect(),
            None => accounts
                .map(|account| (account, fetch_nft_full_info(&client, &account.pubkey)))
                .collect(),
        };
        let sep = "-".repeat(60);
        for (account, info) in infos {
            println!("{sep}\n{account:#?}");
            print_nft_verbose(&info);
            println!();
        }
    } else {
        let infos: Vec<NFTInfo> = match collection_address {
            Some(pubkey) => accounts
                .filter_map(|account| {
                    let info = fetch_nft_info(&client, &account.pubkey);
                    match info.collection {
                        Some(collection) if collection == pubkey => Some(info),
                        _ => None,
                    }
                })
                .collect(),
            None => accounts
                .map(|account| fetch_nft_info(&client, &account.pubkey))
                .collect(),
        };
        for info in infos {
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
