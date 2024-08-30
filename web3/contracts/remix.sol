//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
        // account.code.length returns the length of this bytecode
        //If account.code.length > 0, it means there is bytecode at that address, indicating that the address is a smart contract.
    }
    function sendValue(address payable recipient, uint amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance in contract"
        );
        //below line sends amount to the recipient
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
    function functionCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address:Address: low-level call failed"
            );
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(
        address target,
        bytes memory data
    ) internal view returns (bytes memory) {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low level delegate call failed"
            );
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
pragma solidity ^0.8.9;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
pragma solidity ^0.8.9;
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approaval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
pragma solidity ^0.8.9;
abstract contract Initializable {
    uint8 private _initialized;
    bool private _initializing;
    event Initialized(uint8 version);
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) ||
                (!Address.isContract(address(this)) && _initialized == 1),
            "Initializable contract already initialized"
        );
        _initializing = true;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }
    modifier reinitializer(uint8 version) {
        require(
            !_initializing && _initialized < version,
            "Initializable contracts is already intialized"
        );
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized((type(uint8).max));
        }
    }
}
pragma solidity ^0.8.9;

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    constructor() {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Owner caller is not owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable new address is the zero address"
        );
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
pragma solidity ^0.8.9;
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

pragma solidity ^0.8.9;
contract SpringTokens {
    string public name = "springtokens";
    string public symbol = "ST";
    string public standard = "springtokens v.0.1";
    uint256 public totalSupply;
    address public ownerOfContract;
    uint256 public _userId;
    uint256 constant initialSupply = 1000000 * (10 ** 18);
    address[] public holderToken;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
    mapping(address => TokenHolderInfo) public tokenHolderInfos;
    struct TokenHolderInfo {
        uint256 _tokenId;
        address _from;
        address _to;
        uint256 _totalToken;
        bool _tokenHolder;
    }
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance; //This is a nested mapping where the first address represents the owner's address, the second address represents the spender's address, and uint256 is the amount of tokens the spender is allowed to spend on behalf of the owner.
    constructor() {
        ownerOfContract = msg.sender;
        balanceOf[msg.sender] = initialSupply;
        totalSupply = initialSupply;
    }
    function inc() internal {
        _userId++;
    }
    function transfer(
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        inc();
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        TokenHolderInfo storage tokenHolderInfo = tokenHolderInfos[_to];
        tokenHolderInfo._to = _to;
        tokenHolderInfo._from = msg.sender;
        tokenHolderInfo._totalToken = _value;
        tokenHolderInfo._tokenHolder = true;
        tokenHolderInfo._tokenId = _userId;
        holderToken.push(_to);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    function approve(
        address _spender,
        uint256 _value
    ) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
    function getTokenHolderData(
        address _address
    ) public view returns (uint256, address, address, uint256, bool) {
        return (
            tokenHolderInfos[_address]._tokenId,
            tokenHolderInfos[_address]._to,
            tokenHolderInfos[_address]._from,
            tokenHolderInfos[_address]._totalToken,
            tokenHolderInfos[_address]._tokenHolder
        );
    }
    function getTokenHolderData() public view returns (address[] memory) {
        return holderToken;
    }
}
pragma solidity ^0.8.9;

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
