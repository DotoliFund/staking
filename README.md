# Dotoli staking

This repository contains the staking smart contracts for the Dotoli Protocol.

## Smart Contract

### DotoliStaking

When this contract is first created receive 9999999 Dotoli Tokens from contract producers. 
It provides staking rewards to stakers. As the number of staking participants increases, 
each staker will share the rewards.

```
Token : DTL (0xFd78b26D1E5fcAC01ba43479a44afB69a8073716)
REWARD_RATE = 1000
Max reward : 10000000 * 1e18
```

### REWARD_RATE

This is the reward token per second which will be multiplied by the tokens the user staked divided by the total.
This ensures a steady reward rate of the platform. So the more users stake, the less for everyone who is staking.


## Contract Address

| Contract         | Mainnet Address | 
| ----------------------------------- | ---------------------------------------- | 
| [DotoliStaking](https://github.com/DotoliFund/staking/blob/master/contracts/DotoliStaking.sol)                                                    | `0x480E6993dA410D5026D7bD3652F53D99845B6fc3`           | 

## Licensing

Inspired by https://github.com/smartcontractkit/defi-minimal
```
MIT
```
