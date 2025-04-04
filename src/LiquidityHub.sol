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
    event MintLPRequest(address indexed user, uint256 amount, uint256[] chains, address[] pools);
    event BurnLPRequest(address indexed user, uint256 amount, uint256[] chains, address[] pools);

    // Mapping to store token pairs for each pool
    mapping(address => address[2]) public poolTokens;


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

    // Function to set the token pair for a pool
    function setPoolTokens(address poolAddress, address tokenA, address tokenB) public onlyOwner {
        require(poolAddress != address(0) && tokenA != address(0) && tokenB != address(0), "LiquidityHub: Invalid addresses");
        poolTokens[poolAddress] = [tokenA, tokenB]; // TBD add chain identifiers
    }    

    // function addAllowedChainId(uint256 chainId) public onlyOwner {
    //     allowedChainIds.add(chainId);
    // }

    // function removeAllowedChainId(uint256 chainId) public onlyOwner {
    //     allowedChainIds.remove(chainId);
    // }

    // --- Liquidity Management ---

    function getTokenPairHash(address tokenA, address tokenB) public pure returns (address) {
        // Ensure consistent order to avoid duplicate keys (e.g., sort addresses)
        if (tokenA < tokenB) {
            return address(uint160(uint256(keccak256(abi.encodePacked(tokenA, tokenB)))));
        } else {
            return address(uint160(uint256(keccak256(abi.encodePacked(tokenB, tokenA)))));
        }
    }


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


    function mintLP(uint256 amount, uint256[] memory chains, address[] memory pools) public {
        // require(chains.length == pools.length, "LiquidityHub: Chains and pools length mismatch"); // TBD
        require(amount > 0, "LiquidityHub: Mint amount must be greater than zero");

        // TBD add variable availableUserBalances - so that the user cannot mint twice the same position without depositing more. the funds should be blocked after the mint

        // Check if user has deposited enough tokens for each pool
        for (uint256 i = 0; i < pools.length; i++) {
            address poolAddress = pools[i];
            address[2] memory tokens = poolTokens[poolAddress];
            require(tokens[0] != address(0) && tokens[1] != address(0), "LiquidityHub: Pool tokens not set");

            uint256 requiredAmountA = amount; // Assuming 1:1 ratio TBD - remove fixed price oracle 
            uint256 requiredAmountB = amount; // Assuming 1:1 ratio

            require(userBalances[msg.sender][tokens[0]] >= requiredAmountA &&
                    userBalances[msg.sender][tokens[1]] >= requiredAmountB,
                    "LiquidityHub: Insufficient deposits for LP minting");

            // Compute the token pair hash for the Liquidity Hub
            address tokenPairHash = getTokenPairHash(tokens[0], tokens[1]);

            // Update LP positions on all chains and the overall LP position
            for (uint256 j = 0; j < chains.length; j++) {
                lpPositions[msg.sender][chains[j]][poolAddress] += amount;
            }
            lpPositions[msg.sender][0][tokenPairHash] += amount; // Chain ID 0 for Liquidity Hub

        }

        // TBD additional check that all pools specified are indeed the pools containing the same tokens on different chains


        // // TBD Basic check if requested chains are allowed
        // for (uint256 i = 0; i < chains.length; i++) {
        //     require(allowedChainIds.contains(chains[i]), "LiquidityHub: Chain not allowed");
        // }        

        // For now, we are just emitting an event. The actual minting on rollups
        // will be handled by the off-chain listener and Liquidity Managers.
        emit MintLPRequest(msg.sender, amount, chains, pools);
    }

    function burnLP(uint256 amount, uint256[] memory chains, address[] memory pools) public {
        require(chains.length == pools.length, "LiquidityHub: Chains and pools length mismatch");
        // require(amount > 0, "LiquidityHub: Burn amount must be greater than zero");

        // // TDB Basic check if requested chains are allowed
        // for (uint256 i = 0; i < chains.length; i++) {
        //     require(allowedChainIds.contains(chains[i]), "LiquidityHub: Chain not allowed");
        // }

        // For now, we are just emitting an event. The actual burning and withdrawal
        // on rollups will be handled by the off-chain listener and Liquidity Managers.
        emit BurnLPRequest(msg.sender, amount, chains, pools);
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