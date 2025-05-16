//
//  ███████╗██╗  ██╗ █████╗     ██████╗ ██████╗  ██████╗ ████████╗ ██████╗  ██████╗ ██████╗ ██╗
//  ██╔════╝╚██╗██╔╝██╔══██╗    ██╔══██╗██╔══██╗██╔═══██╗╚══██╔══╝██╔═══██╗██╔════╝██╔═══██╗██║
//  █████╗   ╚███╔╝ ███████║    ██████╔╝██████╔╝██║   ██║   ██║   ██║   ██║██║     ██║   ██║██║
//  ██╔══╝   ██╔██╗ ██╔══██║    ██╔═══╝ ██╔══██╗██║   ██║   ██║   ██║   ██║██║     ██║   ██║██║
//  ███████╗██╔╝ ██╗██║  ██║    ██║     ██║  ██║╚██████╔╝   ██║   ╚██████╔╝╚██████╗╚██████╔╝███████╗
//  ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝     ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝  ╚═════╝ ╚═════╝ ╚══════╝
//

// Project website: https://www.exaprotocol.com
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IERC20
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
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

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @title Ownable
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 */
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @title XAPWithdrawal
 * @dev This contract allows the owner to allocate XAP tokens to specific addresses,
 * which can then withdraw their allocated amount. The contract must hold the XAP tokens
 * intended for withdrawal.
 */
contract XAPWithdrawal is Ownable {
    IERC20 public immutable xapToken;

    // Mapping from user address to the remaining amount they are allowed to withdraw
    mapping(address => uint256) public withdrawableBalance;

    event AllowanceSet(address indexed recipient, uint256 amount);
    event AllowanceAdded(address indexed recipient, uint256 amountAdded);
    event Withdrawn(address indexed recipient, uint256 amount);

    /**
     * @dev Sets the XAP token address. The deployer becomes the owner.
     * @param _xapTokenAddress The address of the XAP ERC20 token contract.
     */
    constructor(address _xapTokenAddress) Ownable(msg.sender) {
        require(
            _xapTokenAddress != address(0),
            "XAP token address cannot be zero"
        );
        xapToken = IERC20(_xapTokenAddress);
    }

    /**
     * @dev Sets the total withdrawable balance for a recipient. Overwrites any existing balance.
     * Can only be called by the owner.
     * @param _recipient The address receiving the allowance.
     * @param _amount The total amount they are allowed to withdraw.
     */
    function setAllowance(
        address _recipient,
        uint256 _amount
    ) external onlyOwner {
        require(
            _recipient != address(0),
            "Recipient cannot be the zero address"
        );
        withdrawableBalance[_recipient] = _amount;
        emit AllowanceSet(_recipient, _amount);
    }

    /**
     * @dev Sets the total withdrawable balance for multiple recipients in a single transaction.
     * Overwrites any existing balances. Can only be called by the owner.
     * This function saves gas when setting allowances for many addresses at once.
     * @param _recipients Array of addresses receiving the allowances.
     * @param _amounts Array of amounts they are allowed to withdraw.
     */
    function setAllowanceBatch(
        address[] calldata _recipients,
        uint256[] calldata _amounts
    ) external onlyOwner {
        require(
            _recipients.length == _amounts.length,
            "Array lengths must match"
        );
        require(_recipients.length > 0, "Arrays cannot be empty");

        for (uint256 i = 0; i < _recipients.length; i++) {
            address recipient = _recipients[i];
            require(
                recipient != address(0),
                "Recipient cannot be the zero address"
            );

            withdrawableBalance[recipient] = _amounts[i];
            emit AllowanceSet(recipient, _amounts[i]);
        }
    }

    /**
     * @dev Adds to the withdrawable balance for multiple recipients in a single transaction.
     * Can only be called by the owner.
     * @param _recipients Array of addresses receiving the additional allowances.
     * @param _amountsToAdd Array of amounts to add to their withdrawable balances.
     */
    function addAllowanceBatch(
        address[] calldata _recipients,
        uint256[] calldata _amountsToAdd
    ) external onlyOwner {
        require(
            _recipients.length == _amountsToAdd.length,
            "Array lengths must match"
        );
        require(_recipients.length > 0, "Arrays cannot be empty");

        for (uint256 i = 0; i < _recipients.length; i++) {
            address recipient = _recipients[i];
            require(
                recipient != address(0),
                "Recipient cannot be the zero address"
            );

            withdrawableBalance[recipient] += _amountsToAdd[i];
            emit AllowanceAdded(recipient, _amountsToAdd[i]);
        }
    }

    /**
     * @dev Adds to the withdrawable balance for a recipient.
     * Can only be called by the owner.
     * @param _recipient The address receiving the additional allowance.
     * @param _amountToAdd The amount to add to their withdrawable balance.
     */
    function addAllowance(
        address _recipient,
        uint256 _amountToAdd
    ) external onlyOwner {
        require(
            _recipient != address(0),
            "Recipient cannot be the zero address"
        );
        withdrawableBalance[_recipient] += _amountToAdd;
        emit AllowanceAdded(_recipient, _amountToAdd);
    }

    /**
     * @dev Allows a user to withdraw their allocated XAP tokens.
     * The user must have sufficient withdrawable balance, and the contract must hold enough tokens.
     * @param _amount The amount of XAP tokens to withdraw.
     */
    function withdraw(uint256 _amount) external {
        require(_amount > 0, "Withdraw amount must be greater than zero");

        uint256 availableBalance = withdrawableBalance[msg.sender];
        require(
            availableBalance >= _amount,
            "Insufficient withdrawable balance"
        );

        require(
            xapToken.balanceOf(address(this)) >= _amount,
            "Contract has insufficient XAP balance"
        );

        // Decrease withdrawable balance first to prevent re-entrancy issues
        withdrawableBalance[msg.sender] = availableBalance - _amount;

        // Transfer the tokens
        bool sent = xapToken.transfer(msg.sender, _amount);
        require(sent, "XAP transfer failed");

        emit Withdrawn(msg.sender, _amount);
    }

    /**
     * @dev Rejects any Ether sent directly to the contract.
     */
    receive() external payable {
        revert("Ether not accepted");
    }
}
