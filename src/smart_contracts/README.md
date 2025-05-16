# XAP Withdrawal Contract

A Solidity smart contract that enables distribution of XAP tokens to specific wallet addresses. The contract owner can allocate withdrawal allowances to users who can then claim their tokens.

## Overview

The XAPWithdrawal contract manages XAP token distribution by:

1. Allowing the contract owner to specify how much XAP each address can withdraw
2. Permitting users to withdraw their allocated tokens up to their allowance
3. Keeping track of remaining balances for each user

## Contract Details

- **Token Standard**: ERC20 (XAP)
- **Decimals**: 8 (1 XAP = 10^8 units)
- **Access Control**: Ownable pattern (only owner can set allowances)

## Functions

### For Contract Owner

#### `constructor(address _xapTokenAddress)`

- Creates the contract, setting the XAP token address and the deployer as owner
- Example: `new XAPWithdrawal("0x123...789")`

#### `setAllowance(address _recipient, uint256 _amount)`

- Sets a specific withdrawal allowance for a single address (overwrites any previous amount)
- Example: To allow withdrawal of 5 XAP: `setAllowance("0xabc...def", 500000000)`

#### `addAllowance(address _recipient, uint256 _amountToAdd)`

- Adds to the existing allowance for a single address
- Example: To add 2.5 XAP to existing allowance: `addAllowance("0xabc...def", 250000000)`

#### `setAllowanceBatch(address[] _recipients, uint256[] _amounts)`

- Sets allowances for multiple addresses in one transaction (gas-efficient)
- Example:
  ```
  setAllowanceBatch(
    ["0xabc...def", "0x123...456", "0x789...abc"],
    [100000000, 200000000, 300000000]
  )
  ```
  This allows the first address to withdraw 1 XAP, second address 2 XAP, and third address 3 XAP.

#### `addAllowanceBatch(address[] _recipients, uint256[] _amountsToAdd)`

- Adds allowances for multiple addresses in one transaction
- Example:
  ```
  addAllowanceBatch(
    ["0xabc...def", "0x123...456"],
    [50000000, 75000000]
  )
  ```
  This adds 0.5 XAP to the first address and 0.75 XAP to the second address.

#### `transferOwnership(address newOwner)`

- Transfers contract ownership to another address
- Example: `transferOwnership("0xnew...owner")`

### For Users

#### `withdraw(uint256 _amount)`

- Allows a user to withdraw their allocated XAP tokens up to their allowance
- Example: To withdraw 1 XAP: `withdraw(100000000)`

### View Functions

#### `withdrawableBalance(address user)`

- Returns the amount a specific address is allowed to withdraw
- Example: `withdrawableBalance("0xabc...def")` might return `150000000` (1.5 XAP)

#### `owner()`

- Returns the current contract owner's address

#### `xapToken()`

- Returns the address of the XAP token contract

## Deployment

1. Deploy the contract with the XAP token contract address as the constructor parameter
2. Fund the contract by sending XAP tokens to the contract address
3. Set allowances for users who should be able to withdraw tokens

## Usage Example

### For Contract Owner:

1. **Deploy contract:**

   ```solidity
   XAPWithdrawal withdrawalContract = new XAPWithdrawal("0xXAP_TOKEN_ADDRESS");
   ```

2. **Fund the contract:**
   Send XAP tokens to the contract address using the XAP token contract's transfer function.

3. **Set allowances:**

   ```solidity
   // Set single allowance (10 XAP)
   withdrawalContract.setAllowance("0xUSER_ADDRESS", 1000000000);

   // Set batch allowances
   withdrawalContract.setAllowanceBatch(
     ["0xUSER1", "0xUSER2", "0xUSER3"],
     [500000000, 750000000, 1250000000] // 5 XAP, 7.5 XAP, 12.5 XAP
   );
   ```

### For Users:

1. **Check allowance:**

   ```solidity
   uint256 myAllowance = withdrawalContract.withdrawableBalance(myAddress);
   ```

2. **Withdraw tokens:**
   ```solidity
   // Withdraw 3 XAP
   withdrawalContract.withdraw(300000000);
   ```

## Interacting on Etherscan

### For Contract Owner:

1. Navigate to the verified contract on Etherscan and connect your wallet
2. Go to "Write Contract" tab
3. Use setAllowance or setAllowanceBatch to grant withdrawal permissions:
   - For setAllowanceBatch, use array format: ["0xADDR1","0xADDR2"] and [100000000,200000000]

### For Users:

1. Navigate to the verified contract on Etherscan and connect your wallet
2. Go to "Write Contract" tab
3. Use the withdraw function with the amount you wish to withdraw (in smallest units)
   - Example: To withdraw 5 XAP, enter 500000000

## Notes

- All token amounts are specified in the smallest unit (1 XAP = 10^8 units)
- The contract must have sufficient XAP balance for withdrawals to succeed
- Only the contract owner can set or add allowances
- Users can only withdraw up to their allowance amount
