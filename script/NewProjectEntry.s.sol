// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/CloneFactory.sol";
import "../src/ERC721CloneableTBA.sol";

contract NewProjectEntry is Script {
    // Deployments
    CloneFactory public cloneFactory;
    ERC721CloneableTBA public erc721;

    string public name = "Partner Clone ERC721";
    string public symbol = "CL1155";

    address public tronicAddress = vm.envAddress("TRONIC_ADMIN_ADDRESS");
    address public cloneFactoryAddress = vm.envAddress("CLONE_FACTORY_ADDRESS");

    string public erc115BaseURI = vm.envString("ERC1155_BASE_URI");

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TRONIC_ADMIN");

        cloneFactory = CloneFactory(cloneFactoryAddress);

        vm.startBroadcast(deployerPrivateKey);

        //deploy partner clone erc1155
        cloneFactory.cloneERC1155(erc115BaseURI, tronicAddress, name, symbol);

        vm.stopBroadcast();
    }
}
