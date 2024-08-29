//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
//IMPORTING CONTRACTS
import "./IERC20.sol";
import "./Initializable.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";
contract TokenStaking is Ownable, ReentrancyGuard, Initializable {
    //This contract, TokenStaking, is designed for a staking mechanism where users can stake tokens and earn rewards based on the time their tokens are staked.
    //STRUCT
    struct User {
        uint256 stakeAmount;
        uint256 rewardAmount;
        uint256 lastStakeTime;
        uint256 lastRewardCalculationTime;
        uint256 rewardsClaimedSoFar;
    }
    uint256 _minimumStakingAmount;
    uint256 _maxStakeTokenLimit;
    uint256 _stakeEndDate;
    uint256 _stakeStartDate;
    uint256 _totalStakedTokens;
    uint256 _totalUsers;
    uint256 _stakeDays;
    uint256 _earlyUnstakeFeePercentage;
    bool _isStakingPaused;
    address private _tokenAddress; //Token contract address
    uint256 _apyRate;
    uint256 public constant PERCENTAGE_DENOMINATOR = 10000;
    uint256 public constant APY_RATE_CHANGE_THRESHOLD = 10;
    // User address => User
    mapping(address => User) private _users;
    event Stake(address indexed user, uint256 amount);
    event UnStake(address indexed user, uint256 amount);
    event EarlyUnStakeFee(address indexed user, uint256 amount);
    event ClaimReward(address indexed user, uint256 amount);
    modifier whenTreasuryHasBalance(uint256 amount) {
        require(
            IERC20(_tokenAddress).balanceOf(address(this)) >= amount,
            "TokenStaking: insufficient funds in the treasury"
        );
        _;
    }
    function initialize(
        address _owner,
        address _tokenAddress,
        uint256 _apyRate,
        uint256 _minimumStakingAmount,
        uint256 _maxStakeTokenLimit,
        uint256 _stakeStartDate,
        uint256 _stakeEndDate,
        uint256 _stakeDays,
        uint256 _earlyUnstakeFeePercentage
    ) public virtual initializer {
        //initializer is from initilizable contract
        __TokenStaking_init_unchained(
            _owner,
            _tokenAddress,
            _apyRate,
            _minimumStakingAmount,
            _maxStakeTokenLimit,
            _stakeStartDate,
            _stakeEndDate,
            _stakeDays,
            _earlyUnstakeFeePercentage
        );
    }
    function __TokenStaking_init_unchained(
        address owner_,
        address tokenAddress_,
        uint256 apyRate_,
        uint256 minimumStakingAmount_,
        uint256 maxStakeTokenLimit_,
        uint256 stakeStartDate_,
        uint256 stakeEndDate_,
        uint256 stakeDays_,
        uint256 earlyUnstakeFeePercentage_
    ) internal onlyInitializing {
        require(
            apyRate_ <= 10000,
            "TokenStaking: apy rate should be less than 10000"
        );
        require(stakeDays_ > 0, "TokenStaking: stake days must be non-zero");
        require(
            tokenAddress_ != address(0),
            "TokenStaking: token address cannot be 0 address"
        );
        require(
            stakeStartDate_ < stakeEndDate_,
            "TokenStaking: start date must be less than end date"
        );
        _transferOwnership(owner_); // _transferOwnership is from ownable contract
        _tokenAddress = tokenAddress_;
        _apyRate = apyRate_;
        _minimumStakingAmount = minimumStakingAmount_;
        _maxStakeTokenLimit = maxStakeTokenLimit_;
        _stakeStartDate = stakeStartDate_;
        _stakeEndDate = stakeEndDate_;
        _stakeDays = stakeDays_ * 1 days;
        _earlyUnstakeFeePercentage = earlyUnstakeFeePercentage_;
    }

    /**View methods start */
    /**
     *@notice This function is used to get the minimum staking amount */
    function getMinimumStakingAmount() external view returns (uint256) {
        return _minimumStakingAmount;
    }
    /**
     * @notice This function is used to get the maximum staking token limit for program
     */
    function getMaxStakingTokenLimit() external view returns (uint256) {
        return _maxStakeTokenLimit;
    }
    /**
     * @notice This function is used to get the staking start date for program
     */
    function getStakeStartDate() external view returns (uint256) {
        return _stakeStartDate;
    }
    /**
     * @notice This function is used to get the staking end date for program
     */
    function getStakeEndDate() external view returns (uint256) {
        return _stakeEndDate;
    }
    /**
     * @notice This function is used to get the total no. of tokens that are staked
     */
    function getTotalStakedTokens() external view returns (uint256) {
        return _totalStakedTokens;
    }
    /**
     * @notice This function is used to get stake days
     */
    function getStakeDays() external view returns (uint256) {
        return _stakeDays;
    }
    /**
     * @notice This function is used to get unstake fee percentage
     */
    function getEarlyUnstakeFeePercentage() external view returns (uint256) {
        return _earlyUnstakeFeePercentage;
    }
    /**
     * @notice This function is used to get staking status
     */
    function getStakingStatus() external view returns (bool) {
        return _isStakingPaused;
    }
    /**
     * @notice This function is used to get the current APY Rate
     * @return Current APY Rate
     */
    function getAPY() external view returns (uint256) {
        return _apyRate;
    }
    /**
     * @notice This function is used to get the msg.sender's estimated reward amount
     * @return msg.sender's estimated reward amount
     */
    function getUserEstimatedRewards() external view returns (uint256) {
        (uint256 amount, ) = _getUserEstimatedRewards(msg.sender);
        return _users[msg.sender].rewardAmount + amount;
    }
    /**
     * @notice This function is used to get withdrawable amount from contract
     */
    function getWithdrawableAmount() external view returns (uint256) {
        return
            IERC20(_tokenAddress).balanceOf(address(this)) - _totalStakedTokens;
    }
    /**
     * @notice This function is used to get User's details
     * @param userAddress User's address to get details of
     * @return User struct
     */
    function getUser(address userAddress) external view returns (User memory) {
        return _users[userAddress];
    }
    function getTotalUsers() external view returns (uint256) {
        return _totalUsers;
    }
    /**
     * @notice This function is used to check if a user is a stakeholder
     * @param _user Address of the user to check
     * @return True if user is a stakeholder, false othwewise
     */
    function isStakeHolder(address _user) external view returns (bool) {
        return _users[_user].stakeAmount != 0;
    }
    /**
     * @notice This function is used to update minimum staking amount
     */
    function updateMinimumStakingAmount(uint256 newAmount) external onlyOwner {
        _minimumStakingAmount = newAmount;
    }
    /**
     * @notice This function is used to update maximum staking amount
     */
    function updateMaximumStakingAmount(uint256 newAmount) external onlyOwner {
        _maxStakeTokenLimit = newAmount;
    }
    /**
     * @notice This function is used to update early unstake fee percentage
     */
    function updateEarlyUnstakeFeePercentage(
        uint256 newPercentage
    ) external onlyOwner {
        _earlyUnstakeFeePercentage = newPercentage;
    }
    /**
     * @notice stake tokens for specific user
     * @dev This function can be used to stake tokens for specific user
     * @param amount the amount to stake
     * @param user user's address
     */

    /* User methods starts */
    function stakeForUser(
        uint256 amount,
        address user
    ) external onlyOwner nonReentrant {
        _stakeTokens(amount, user);
    }
    /**
     * @notice enable/disable staking
     * @dev This function can be used to toggle staking status
     */
    function toggleStakingStatus() external onlyOwner {
        _isStakingPaused = !_isStakingPaused;
    }
    /**
     * @notice Withdraw the specified amount if possible
     * @dev This function can be used to withdraw the available tokens
     * with this contract to the caller
     * @param amount the amount to withdraw
     */
    function withdraw(uint256 amount) external onlyOwner nonReentrant {
        require(
            this.getWithdrawableAmount() >= amount,
            "TokenStaking: not enough withdrawable tokens"
        );
        IERC20(_tokenAddress).transfer(msg.sender, amount);
    }
    /*User Methods start */
    function stake(uint256 _amount) external nonReentrant {
        _stakeTokens(_amount, msg.sender);
    }
    function _stakeTokens(uint256 _amount, address _user) private {
        require(!_isStakingPaused, "TokenStaking: staking is paused");
        uint256 currentTime = getCurrentTime();
        require(
            currentTime > _stakeStartDate,
            "TokenStaking: staking is not started yet"
        );
        require(
            currentTime < _stakeEndDate,
            "TokenStaking: max staking token limit reached"
        );
        require(
            _totalStakedTokens + _amount <= _maxStakeTokenLimit,
            "TokenStaking: max staking token limit reached"
        );
        require(_amount > 0, "TokenStaking: stake amount must be non zero");
        require(
            _amount >= _minimumStakingAmount,
            "TokenStaking: staking amount must be greater tha the minimum allowed"
        );
        if (_users[_user].stakeAmount != 0) {
            _calculateRewards(_user);
        } else {
            _users[_user].lastRewardCalculationTime = currentTime;
            _totalUsers += 1;
        }
        _users[_user].stakeAmount += _amount;
        _users[_user].lastStakeTime = currentTime;
        _totalStakedTokens += _amount;
        require(
            IERC20(_tokenAddress).transferFrom(
                msg.sender,
                address(this),
                _amount
            ),
            "TokenStaking: failed to transfer tokens"
        );
        emit Stake(_user, _amount);
    }
    function unstake(
        uint256 _amount
    ) external nonReentrant whenTreasuryHasBalance(_amount) {
        address _user = msg.sender;
        require(_amount != 0, "TokenStaking: amount should be non zero");
        require(this.isStakeHolder(_user), "TokenStaking: not a stakeholder");
        require(
            _users[_user].stakeAmount >= _amount,
            "TokenStaking: not enough stake to unstake"
        );
        _calculateRewards(_user);
        uint256 feeEarlyUnstake;
        if (getCurrentTime() <= _users[_user].lastStakeTime + _stakeDays) {
            //if a user wishes to withdraw tokens before the token stake time then he has to pay the fee and he will receive the deducted amount
            feeEarlyUnstake = ((_amount * _earlyUnstakeFeePercentage) /
                PERCENTAGE_DENOMINATOR);
            emit EarlyUnStakeFee(_user, feeEarlyUnstake);
        }
        uint256 amountToUnstake = _amount - feeEarlyUnstake;
        _users[_user].stakeAmount -= _amount;
        _totalStakedTokens -= _amount;
        if (_users[_user].stakeAmount == 0) {
            //if user has not staked then we will del that user
            _totalUsers -= 1;
        }
        require(
            IERC20(_tokenAddress).transfer(_user, amountToUnstake),
            "TokenStaking: failed to transfer"
        );
        emit UnStake(_user, _amount);
    }
    function claimReward()
        external
        nonReentrant
        whenTreasuryHasBalance(_users[msg.sender].rewardAmount)
    {
        _calculateRewards(msg.sender);
        uint256 rewardAmount = _users[msg.sender].rewardAmount;
        require(rewardAmount > 0, "TokenStaking: no reward to claim");
        require(IERC20(_tokenAddress).transfer(msg.sender, rewardAmount));
        _users[msg.sender].rewardAmount = 0; // after transfering the reward we are updating the _users mapping
        _users[msg.sender].rewardsClaimedSoFar += rewardAmount;
        emit ClaimReward(msg.sender, rewardAmount);
    }
    /* User methods end */
    /* Private helper function */
    function _calculateRewards(address _user) private {
        (uint256 userReward, uint256 currentTime) = _getUserEstimatedRewards(
            _user
        );
        _users[_user].rewardAmount += userReward;
        _users[_user].lastRewardCalculationTime = currentTime;
    }
    function _getUserEstimatedRewards(
        address _user
    ) private view returns (uint256, uint256) {
        uint256 userReward;
        uint256 userTimestamp = _users[_user].lastRewardCalculationTime;
        uint256 currentTime = getCurrentTime();
        if (currentTime > _users[_user].lastStakeTime + _stakeDays) {
            currentTime = _users[_user].lastStakeTime + _stakeDays;
        }
        uint256 totalStakedTime = currentTime - userTimestamp;
        userReward +=
            ((totalStakedTime * _users[_user].stakeAmount * _apyRate) /
                365 days) /
            PERCENTAGE_DENOMINATOR;
        return (userReward, currentTime);
    }
    function getCurrentTime() internal view virtual returns (uint256) {
        return block.timestamp;
    }
}
