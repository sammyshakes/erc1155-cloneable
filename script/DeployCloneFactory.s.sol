// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/CloneFactory.sol";

contract DeployCloneFactory is Script {
    // Deployments
    CloneFactory public cloneFactory;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_2");

        //Deploy Tronic Master Contracts
        vm.startBroadcast(deployerPrivateKey);

        // deploy new clone factory with environment variables
        cloneFactory = new CloneFactory(
            vm.envAddress("TRONIC_ADMIN_ADDRESS"),
            vm.envAddress("ERC721_CLONEABLE_ADDRESS"),
            vm.envAddress("ERC1155_CLONEABLE_ADDRESS"),
            vm.envAddress("ERC6551_REGISTRY_ADDRESS"),
            payable(vm.envAddress("TOKENBOUND_ACCOUNT_ADDRESS"))
        );

        vm.stopBroadcast();
    }
}
