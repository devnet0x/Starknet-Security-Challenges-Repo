#[contract]

mod call_me {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use box::BoxTrait;

    const FALSE: felt252 = 0;
    const TRUE: felt252 = 1;
    

    struct Storage {
        is_complete: felt252,
        balances: LegacyMap::<ContractAddress, u256>,
        totalSupply :felt252,
    }

    #[constructor]
    fn constructor() {
        let TOKEN_20: u256 = u256 { high: 0x01158e460913d00000_u128, low: 0_u128 }; //20*10**18
        let tx_info = starknet::get_tx_info().unbox();
        let owner: ContractAddress = tx_info.account_contract_address;
        balances::write(owner, TOKEN_20);
    }

    #[external]
    fn transfer(_to: ContractAddress, amount: u256) {
        let TOKEN_0: u256 = u256 { high: 0_u128, low: 0_u128 };
        let sender = get_caller_address();

        assert (balances::read(sender) - amount >= TOKEN_0,'Insufficient funds');
        
        balances::write(sender, balances::read(sender) - amount);
        balances::write(_to, balances::read(_to) + amount);

        return();
    }

    #[view]
    fn balanceOf(owner: ContractAddress) -> u256 {
        return(balances::read(owner));
    }

    #[view]
    fn isComplete() -> felt252 {
        let TOKEN_20: u256 = u256 { high: 0x01158e460913d00000_u128, low: 0_u128 }; //20*10**18
        let tx_info = starknet::get_tx_info().unbox();
        let owner: ContractAddress = tx_info.account_contract_address;
        assert(balances::read(owner)>TOKEN_20,'Challenge not resolved');
        is_complete::read()
    }
}
