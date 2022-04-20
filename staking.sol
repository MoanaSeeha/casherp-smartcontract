pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract Staking {
    mapping(address => uint256) public stakedAmount;
    mapping(address => uint256) public stakingEndTime;
    mapping(address => uint256) public nextWithdrawTime;
    uint256 public referalFee = 25; // 25 = 2.5 %,    1000 = 100 %
    address public address_CashP;
    uint256 public stakingPeriod = 180 days;
    uint256 public withdrawPeriod = 1 days;

    uint256 public ROI = 2; // 2 %
    constructor() {

    }

    function deposit(uint256 amount, address referal) external {
        require(amount >= 10 ** 17, "you should stake more than 0.1 CashP");
        uint256 referAmount = amount * referalFee / 1000;
        if(referal == address(0)){
            referAmount = 0;
        }

        IERC20(address_CashP).transferFrom(msg.sender, address(this), amount);
        stakedAmount[msg.sender] += amount;
        nextWithdrawTime[msg.sender] = block.timestamp + withdrawPeriod;
        stakingEndTime[msg.sender] = block.timestamp + stakingPeriod;
        if(referAmount > 0)
            IERC20(address_CashP).transferFrom(address(this), referal, referAmount);
    }

    function claim() external {
        require(stakedAmount[msg.sender] > 0, "You depositted nothing");
        require(nextWithdrawTime[msg.sender] < block.timestamp, "You already withdrawed.");
        require(stakingEndTime[msg.sender] > block.timestamp, "Staking ended.");
        uint256 claimAmount = stakedAmount[msg.sender] * ROI / 100;

        nextWithdrawTime[msg.sender] = block.timestamp + withdrawPeriod;
        IERC20(address_CashP).transferFrom(address(this), msg.sender, claimAmount);
    }

    function depositReward(uint256 amount) external {
        IERC20(address_CashP).transferFrom(msg.sender, address(this), amount);
    }
}