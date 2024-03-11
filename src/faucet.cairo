use starknet::ContractAddress;

#[starknet::interface]
trait IFaucet<TContractState> {
    fn request_strk_token(ref self: TContractState, receiver_address: ContractAddress) -> bool;
    fn request_receipt_token(ref self: TContractState, receiver_address: ContractAddress) -> bool;
    fn request_reward_token(ref self: TContractState, receiver_address: ContractAddress) -> bool;
}

#[starknet::contract]
mod Faucet {
    /////////////////////////////
    //LIBRARY IMPORTS
    /////////////////////////////        
    use core::num::traits::zero::Zero;
    use core::serde::Serde;
    use core::integer::u64;
    use core::zeroable::Zeroable;
    use basic_staking_dapp::strk_staking_contract::IStake;
    use basic_staking_dapp::erc20_token::{IERC20Dispatcher, IERC20DispatcherTrait};
    use starknet::{ContractAddress, get_caller_address, get_contract_address, get_block_timestamp};


    ////////////////////
    //STORAGE
    ////////////////////
    #[storage]
    struct Storage {
        strkerc20_token_address: ContractAddress,
        receipt_token_address: ContractAddress,
        reward_token_address: ContractAddress,
    }

    const FAUCET_TRANSFER_AMOUNT: u256 = 10000000000000000000_u256;

    #[constructor]
    fn constructor(
        ref self: ContractState,
        strkerc20_token_address: ContractAddress,
        receipt_token_address: ContractAddress,
        reward_token_address: ContractAddress,
    ) {
        self.strkerc20_token_address.write(strkerc20_token_address);
        self.reward_token_address.write(reward_token_address);
        self.receipt_token_address.write(receipt_token_address);
    }

    #[abi(embed_v0)]
    impl IFaucetImpl of super::IFaucet<ContractState> {
        fn request_strk_token(ref self: ContractState, receiver_address: ContractAddress) -> bool {
            let address_this: ContractAddress = get_contract_address();
            let strk_erc20_contract = IERC20Dispatcher {
                contract_address: self.strkerc20_token_address.read()
            };

            assert(
                strk_erc20_contract.balance_of(address_this) >= FAUCET_TRANSFER_AMOUNT,
                'Insufficient funds'
            );

            strk_erc20_contract.transfer(receiver_address, FAUCET_TRANSFER_AMOUNT);

            true
        }

        fn request_receipt_token(ref self: ContractState, receiver_address: ContractAddress) -> bool {
            let address_this: ContractAddress = get_contract_address();
            let receipt_contract = IERC20Dispatcher {
                contract_address: self.receipt_token_address.read()
            };

            assert(
                receipt_contract.balance_of(address_this) >= FAUCET_TRANSFER_AMOUNT,
                'Insufficient funds'
            );

            receipt_contract.transfer(receiver_address, FAUCET_TRANSFER_AMOUNT);

            true
        }

        fn request_reward_token(ref self: ContractState, receiver_address: ContractAddress) -> bool {
            let address_this: ContractAddress = get_contract_address();
            let reward_contract = IERC20Dispatcher {
                contract_address: self.reward_token_address.read()
            };

            assert(
                reward_contract.balance_of(address_this) >= FAUCET_TRANSFER_AMOUNT,
                'Insufficient funds'
            );

            reward_contract.transfer(receiver_address, FAUCET_TRANSFER_AMOUNT);

            true
        }
    }
}

