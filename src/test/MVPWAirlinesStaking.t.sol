// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

import "forge-std/Test.sol";
//import "ds-test/test.sol";
import "../MVPWAirlinesStaking.sol";
import "./mocks/MockERC20.sol";


contract MVPWAirlinesStakingTest is Test {
    MVPWAirlinesStaking public stakeContract;
    MockERC20 public mockToken; 
    uint256 apy;
    MockERC20 public nativeToken;
    uint256 public prevAmount;

    function setUp() public {
        mockToken = new MockERC20();
        nativeToken = new MockERC20();
        //apy = _apy;
        stakeContract = new MVPWAirlinesStaking(address(mockToken), address(nativeToken), 5);
        prevAmount = stakeContract.stakers(msg.sender);

        //mockToken = new MockERC20();
    }

    function test_staking_tokens() public {
        mockToken.approve(address(stakeContract), 50*10**18);
        //uint256 prevAmount = stakeContract.stakers(msg.sender);
        bool stakePassed = stakeContract.stakeTokens(50*10**18);
        assertTrue(stakePassed);
    }

    function test_withdraw_stake() public {
        mockToken.approve(address(stakeContract), 50*10**18);
        stakeContract.stakeTokens(50*10**18);        
        bool withdrawPassed = stakeContract.withdrawStake();
        assertTrue(withdrawPassed);
    }

    function test_withdraw_owner() public {
        bool withdrawPassed = stakeContract.withdrawOwner();

        assertTrue(withdrawPassed);
    }
    function test_withdraw_reward() public {
        mockToken.approve(address(stakeContract), 50*10**18);
        stakeContract.stakeTokens(50*10**18);
        bool withdrawPassed = stakeContract.withdrawReward();

        assertTrue(withdrawPassed);
    }
}

