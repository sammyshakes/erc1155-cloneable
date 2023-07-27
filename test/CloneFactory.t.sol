// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Test.sol";
import "../src/CloneFactory.sol";
import "../src/TokenboundAccount.sol";
import "../src/ERC721CloneableTBA.sol";
import "../src/ERC1155Cloneable.sol";

contract CloneFactoryTest is Test {
    CloneFactory public factory;
    ERC721CloneableTBA public erc721;
    ERC1155Cloneable public erc1155;
    TokenboundAccount public account;
    ERC6551Registry public registry;

    // set users
    address public user1 = address(0x1);
    address public user2 = address(0x2);
    address public user3 = address(0x3);

    address payable public tbaAddress;

    function setUp() public {
        account = new TokenboundAccount();
        erc721 = new ERC721CloneableTBA();
        erc1155 = new ERC1155Cloneable();
        registry = new ERC6551Registry();

        tbaAddress = payable(address(account));

        //initialize erc721 and erc1155
        erc721.initialize(
            tbaAddress, address(registry), "Original721", "OR721", "http://example721.com/", address(this)
        );
        erc1155.initialize("http://example1155.com/", address(this), address(this));

        factory = new CloneFactory(address(this), address(erc721), address(erc1155), address(registry), tbaAddress);
    }

    function testCloneERC1155() public {
        address clone1155Address = factory.cloneERC1155("http://clone1155.com/", user1);

        // clone should exist
        assertNotEq(clone1155Address, address(0));

        // Check the clone has correct uri and admin
        ERC1155Cloneable clone1155 = ERC1155Cloneable(clone1155Address);
        assertEq(clone1155.uri(1), "http://clone1155.com/");
        assertEq(clone1155.isAdmin(user1), true);

        // Check the clone can be retrieved using getERC1155Clone function
        assertEq(factory.getERC1155Clone(0), clone1155Address);
    }

    function testCloneERC721() public {
        address clone721Address = factory.cloneERC721("Clone721", "CL721", "http://clone721.com/", user2);

        // clone should exist
        assertNotEq(clone721Address, address(0));

        // Check the clone has correct name, symbol, uri and admin
        ERC721CloneableTBA clone721 = ERC721CloneableTBA(clone721Address);
        assertEq(clone721.name(), "Clone721");
        assertEq(clone721.symbol(), "CL721");
        assertEq(clone721.isAdmin(user2), true);

        // Check the clone can be retrieved using getERC721Clone function
        assertEq(factory.getERC721Clone(0), clone721Address);

        console.log("clone721Address: ", clone721Address);
        // console clone's registry address
        console.log("clone721Address registry: ", address(clone721.registry()));

        // check clone registry is set
        assertEq(address(clone721.registry()), address(registry));

        //mint token to user2
        vm.prank(user2);
        clone721.mint(user2, 1);

        //check user2 owns token
        assertEq(clone721.ownerOf(1), user2);

        // verify uri
        assertEq(clone721.tokenURI(1), "http://clone721.com/1");
    }
}
