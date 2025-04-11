// SPDX-License-Identifier: MIT

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

pragma solidity ^0.8.18;

contract HelperConfig is Script{
    // If we are on a local network, we want to deploy mocks
    // Otherwise, we want to use the existing price feeds from the live network

    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        }
        else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    } 

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // Return the address of the Sepolia ETH/USD price feed
        
        NetworkConfig memory sepoliaConfig = NetworkConfig(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        
        // We can be more explicit and use the curly braces to define the struct
        // NetworkConfig sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        // Return the address of the Sepolia ETH/USD price feed
        
        NetworkConfig memory ethConfig = NetworkConfig(
            {priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419}
            );
        return ethConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // Return the address of the Anvil ETH/USD price feed

        // 1. Deploy the mocks
        // 2. Return the mock address

        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig(
            {priceFeed: address(mockPriceFeed)}
        );
        return anvilConfig;
    }
}

// 1. Deploy mocks when we are on a local network
// 2. Keep track of contract address accross different chains
// Sepolia ETH/USD
// Mainnet ETH/USD