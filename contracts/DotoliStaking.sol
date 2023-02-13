// SPDX-License-Identifier: MIT
// Inspired by https://github.com/smartcontractkit/defi-minimal
pragma solidity =0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import './interfaces/IDotoliStaking.sol';

error TransferFailed();
error NeedsMoreThanZero();
error RewardOverLimit();

contract DotoliStaking is ReentrancyGuard {

    uint256 public constant maxReward = 10000000 * 1e18;
    uint256 public totalClaimedReward = 0;

    IERC20 public s_rewardsToken;
    IERC20 public s_stakingToken;

    // This is the reward token per second
    // Which will be multiplied by the tokens the user staked divided by the total
    // This ensures a steady reward rate of the platform
    // So the more users stake, the less for everyone who is staking.
    uint256 public constant REWARD_RATE = 1000000;
    uint256 public s_lastUpdateTime;
    uint256 public s_rewardPerTokenStored;

    mapping(address => uint256) public s_userRewardPerTokenPaid;
    mapping(address => uint256) public s_rewards;

    uint256 public s_totalStakedSupply;
    mapping(address => uint256) public s_balances;

    event Staked(address indexed user, uint256 indexed amount);
    event WithdrewStake(address indexed user, uint256 indexed amount);
    event RewardsClaimed(address indexed user, uint256 indexed amount);

    constructor(address stakingToken, address rewardsToken) {
        s_stakingToken = IERC20(stakingToken);
        s_rewardsToken = IERC20(rewardsToken);
    }

    modifier updateReward(address account) {
        s_rewardPerTokenStored = rewardPerToken();
        s_lastUpdateTime = block.timestamp;
        s_rewards[account] = reward(account);
        s_userRewardPerTokenPaid[account] = s_rewardPerTokenStored;
        _;
    }

    function rewardPerToken() public view returns (uint256) {
        if (s_totalStakedSupply == 0) {
            return s_rewardPerTokenStored;
        }
        return
            s_rewardPerTokenStored +
            (((block.timestamp - s_lastUpdateTime) * REWARD_RATE * 1e18) / s_totalStakedSupply);
    }

    function reward(address account) public view returns (uint256) {
        uint256 reward = ((s_balances[account] * (rewardPerToken() - s_userRewardPerTokenPaid[account])) 
            / 1e4) + s_rewards[account];

        uint256 remainReward = s_rewardsToken.balanceOf(address(this));
        if (reward >= remainReward) {
            return remainReward;
        } else {
            return reward;
        }
    }

    function stake(uint256 amount)
        external
        updateReward(msg.sender)
        nonReentrant
    {
        require(amount > 0, 'ZERO');
        s_totalStakedSupply += amount;
        s_balances[msg.sender] += amount;
        emit Staked(msg.sender, amount);
        bool success = s_stakingToken.transferFrom(msg.sender, address(this), amount);
        if (!success) {
            revert TransferFailed();
        }
    }

    function withdraw(uint256 amount) 
        external 
        updateReward(msg.sender) 
        nonReentrant 
    {
        require(amount <= s_totalStakedSupply, 'LIMIT');
        s_totalStakedSupply -= amount;
        s_balances[msg.sender] -= amount;
        emit WithdrewStake(msg.sender, amount);
        bool success = s_stakingToken.transfer(msg.sender, amount);
        if (!success) {
            revert TransferFailed();
        }
    }

    function claimReward(uint256 amount) 
        external
        updateReward(msg.sender)
        nonReentrant
    {
        uint256 afterGetReward = amount + totalClaimedReward;
        require(afterGetReward <= maxReward, 'LIMIT');
        s_rewards[msg.sender] -= amount;
        totalClaimedReward += amount;
        emit RewardsClaimed(msg.sender, amount);
        bool success = s_rewardsToken.transfer(msg.sender, amount);
        if (!success) {
            revert TransferFailed();
        }
    }

    function getStaked(address account) public view returns (uint256) {
        return s_balances[account];
    }
}