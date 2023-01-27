%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import FALSE, TRUE
from starkware.starknet.common.syscalls import get_contract_address,get_caller_address,get_block_number,get_block_timestamp
from starkware.cairo.common.uint256 import (Uint256,uint256_eq)
from starkware.cairo.common.hash import hash2

@contract_interface
namespace IERC20 {
    func balanceOf(account: felt) -> (balance: Uint256) {
    }
    func transfer(recipient: felt, amount: Uint256) -> (success: felt) {
    }
}

@storage_var
func is_complete() -> (value: felt) {
}

@storage_var
func hash_result() -> (value: felt) {
}

// ######## Constructor
@constructor
func constructor{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
}() {
    alloc_locals;
    let (block_number) = get_block_number();
    let (block_timestamp) = get_block_timestamp();
    let (res) = hash2{hash_ptr=pedersen_ptr}(block_number-1, block_timestamp);
    hash_result.write(value=res);
    is_complete.write(FALSE);
    return ();
}

@view
func isComplete{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (output:felt) {
    alloc_locals;
    let (output)=is_complete.read();
    return (output=output);
}

@external
func guess{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    n:felt) {
    alloc_locals;
    let l2_token_address=0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7;

    let (contract_address)=get_contract_address();
    let (balance)=IERC20.balanceOf(contract_address=l2_token_address,account=contract_address); 

    let amount: Uint256 = Uint256(10000000000000000, 0);
    let (is_equal) = uint256_eq(balance, amount);
    with_attr error_message("Deposit required.") {
        assert is_equal = 1;
    }
    
    let (answer)=hash_result.read();
    let diff = n-answer;

    if (diff==0){
        let (sender)=get_caller_address();
        IERC20.transfer(contract_address=l2_token_address,recipient=sender,amount=amount);
        is_complete.write(TRUE,);
    } else {
        let (block_number) = get_block_number();
        let (block_timestamp) = get_block_timestamp();
        let (res) = hash2{hash_ptr=pedersen_ptr}(block_number-1, block_timestamp);
        hash_result.write(value=res);    
    } 
    
    return();
}
