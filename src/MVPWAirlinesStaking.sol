// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

error NotStaker();
error ZeroAddress();

/// @title MVPWAirlinesStaking
/// @author Rastko Misulic
/// @notice You can use this contract to stake token and get MVPWAIR as reward
contract MVPWAirlinesStaking is Ownable {
   
    //VESTING_TIME = three mounths
    uint256 private constant VESTING_TIME = 3*30*24*3600;
    uint256 private constant ONE_YEAR = 365*24*3600;
    uint256 private immutable apy;
    IERC20 private immutable stakingToken;
    IERC20 private immutable nativeToken;
    mapping(address => uint256) public stakers;
    mapping(address => uint256) private stakeTimestamp;
    mapping (address => uint256) private withdrawTimestamp;

    event NewStaking(address indexed staker, uint256 amount);
    event WithdrawStake(address indexed staker, uint256 amount);
    event OwnerWithdraw(address indexed owner, uint256 amount);
    event StakerWithdrawReward(address indexed staker, uint256 amount);

    modifier onlyStaker {
        if (stakers[msg.sender] <= 0) {
            revert NotStaker();
        }
        _;
    }

   constructor(address _stakingToken, address _nativeToken, uint256 _apy) {
        if(_stakingToken == address(0) || _nativeToken == address(0)) {
            revert ZeroAddress();
        }
        stakingToken = IERC20(_stakingToken);
        nativeToken = IERC20(_nativeToken);
        apy = _apy;
   }

    /// @notice Enables you to stake stakingToken
    /// @dev Updates stakers, stakeTimestamp and withdrawTimestamp mappings
    /// @dev Emits NewStaking event
    /// @param amount - amount of stakingToken you want to stake
   function stakeTokens(uint256 amount) external returns (bool success){
        require(IERC20(stakingToken).balanceOf(msg.sender) >= amount, "Invalid balance");
        stakers[msg.sender] += amount;
        stakeTimestamp[msg.sender] = block.timestamp;
        withdrawTimestamp[msg.sender] = block.timestamp;
        success = IERC20(stakingToken).transferFrom(msg.sender, address(this), amount);

        emit NewStaking(msg.sender, amount);

   }

    /// @notice Enables to withraw staked tokens, if staking time is less than 3 months you can withdraw half
    /// @dev Updates stakers mapping, calculate amount to withdraw
    /// @dev Emits WithdrawStake event
   function withdrawStake() external onlyStaker returns(bool success){
        uint256 amount = stakers[msg.sender];
        if((block.timestamp - stakeTimestamp[msg.sender]) < VESTING_TIME){
            amount = amount / 2;
        } 
        stakers[msg.sender] = 0;
        success = IERC20(stakingToken).transfer(msg.sender, amount);

        emit WithdrawStake(msg.sender, amount);

   }
    /// @notice Enables owner to withdraw tokens left in contract
    /// @dev Emits OwnerWithdraw event
    function withdrawOwner() external onlyOwner returns(bool success){
        //add check, owner shouldn't withdraw before some time passes
        uint256 amount = IERC20(stakingToken).balanceOf(address(this));        
        success = IERC20(stakingToken).transfer(msg.sender, amount);

        emit OwnerWithdraw(msg.sender, amount);
    }

    /// @notice Enables to withraw reward in MVPWAIR tokens
    /// @dev Calculate amount = time passed * amount staked * (apy / 100) / ONE_YEAR
    /// @dev Emits StakerWithdrawReward event
    function withdrawReward() external onlyStaker returns(bool success){
        uint256 amount = ((block.timestamp - withdrawTimestamp[msg.sender]) * stakers[msg.sender] * apy) / (100 * ONE_YEAR);
        withdrawTimestamp[msg.sender] = block.timestamp;

        success = IERC20(nativeToken).transfer(msg.sender, amount);

        emit StakerWithdrawReward(msg.sender, amount);
    }
}


