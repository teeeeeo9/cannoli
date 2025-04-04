// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract LiquidityHub is Ownable {
    using EnumerableSet for EnumerableSet.UintSet;

    // Allowed tokens for deposit
    mapping(address => bool) public allowedTokens;
    // EnumerableSet.AddressSet private _allowedTokenSet;


    // // Allowed chain IDs
    // EnumerableSet.UintSet private _allowedChainIds;

    // User liquidity positions: user => token => amount
    mapping(address => mapping(address => uint256)) public userBalances;

    // LP positions per user, chain, and pool: user => chainId => poolAddress => amount
    mapping(address => mapping(uint256 => mapping(address => uint256))) public lpPositions;

    // Events
    event Deposit(address indexed user, address indexed token, uint256 amount);
    event Withdraw(address indexed user, address indexed token, uint256 amount);
    event MintLPRequest(address indexed user, uint256[] amounts, uint256[] chains, address[] pools);
    event BurnLPRequest(address indexed user, uint256[] amounts, uint256[] chains, address[] pools);

    constructor(address owner) Ownable(owner) {}

    // --- Configuration ---

    function addAllowedToken(address token) public onlyOwner {
        require(token != address(0), "LiquidityHub: Cannot allow zero address");
        if (!allowedTokens[token]) {
            allowedTokens[token] = true;
            // _allowedTokenSet.add(token);
        }
    }

    function removeAllowedToken(address token) public onlyOwner {
        if (allowedTokens[token]) {
            allowedTokens[token] = false;
            // allowedTokenSet.remove(token);
        }
    }

    // function addAllowedChainId(uint256 chainId) public onlyOwner {
    //     allowedChainIds.add(chainId);
    // }

    // function removeAllowedChainId(uint256 chainId) public onlyOwner {
    //     allowedChainIds.remove(chainId);
    // }

    // --- Liquidity Management ---

    function deposit(address[] memory tokens, uint256[] memory amounts) public {
        require(tokens.length == amounts.length, "LiquidityHub: Tokens and amounts length mismatch");

        for (uint256 i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            uint256 amount = amounts[i];
            require(allowedTokens[token], "LiquidityHub: Token not allowed");
            require(IERC20(token).transferFrom(msg.sender, address(this), amount), "LiquidityHub: Transfer failed");
            userBalances[msg.sender][token] += amount;
        }

    //     emit Deposit(msg.sender, tokens[0], amounts[0]); 
    }

    function withdraw(address token, uint256 amount) public {
        require(allowedTokens[token], "LiquidityHub: Token not allowed");
        require(userBalances[msg.sender][token] >= amount, "LiquidityHub: Insufficient balance");
        userBalances[msg.sender][token] -= amount;
        require(IERC20(token).transfer(msg.sender, amount), "LiquidityHub: Withdraw failed");
        // emit Withdraw(msg.sender, token, amount);
    }

    // --- LP Management ---

    function mintLP(uint256[] memory amounts, address[] memory tokens, uint256[] memory chains, address[] memory pools) public {
        // tokens - TBD not needed
        require(chains.length == pools.length, "LiquidityHub: Chains and pools length mismatch");
        // require(amount > 0, "LiquidityHub: Mint amount must be greater than zero");

        // // Basic check if requested chains are allowed (more sophisticated logic might be needed)
        // for (uint256 i = 0; i < chains.length; i++) {
        //     require(allowedChainIds.contains(chains[i]), "LiquidityHub: Chain not allowed");
        // }

        // For now, we are just emitting an event. The actual minting on rollups
        // will be handled by the off-chain listener and Liquidity Managers.
        emit MintLPRequest(msg.sender, amounts, chains, pools);
    }

    function burnLP(uint256[] memory amounts, uint256[] memory chains, address[] memory pools) public {
        require(chains.length == pools.length, "LiquidityHub: Chains and pools length mismatch");
        // require(amount > 0, "LiquidityHub: Burn amount must be greater than zero");

        // // Basic check if requested chains are allowed
        // for (uint256 i = 0; i < chains.length; i++) {
        //     require(allowedChainIds.contains(chains[i]), "LiquidityHub: Chain not allowed");
        // }

        // For now, we are just emitting an event. The actual burning and withdrawal
        // on rollups will be handled by the off-chain listener and Liquidity Managers.
        emit BurnLPRequest(msg.sender, amounts, chains, pools);
    }

    // // --- View Functions ---

    // function getUserBalance(address user, address token) public view returns (uint256) {
    //     return userBalances[user][token];
    // }

    // function getLPPosition(address user, uint256 chainId, address poolAddress) public view returns (uint256) {
    //     return lpPositions[user][chainId][poolAddress];
    // }

    // function getAllowedTokens() public view returns (address[] memory) {
    //     uint256 size = allowedTokenSet.length();
    //     address[] memory tokens = new address[](size);
    //     for (uint256 i = 0; i < size; i++) {
    //         tokens[i] = allowedTokenSet.at(i);
    //     }
    //     return tokens;
    // }

    // function getAllowedChainIds() public view returns (uint256[] memory) {
    //     uint256 size = allowedChainIds.length();
    //     uint256[] memory ids = new uint256[](size);
    //     for (uint256 i = 0; i < size; i++) {
    //         ids[i] = allowedChainIds.at(i);
    //     }
    //     return ids;
    // }
}