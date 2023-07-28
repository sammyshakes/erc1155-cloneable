// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Test.sol";
import "../src/CloneFactory.sol";
import "../src/TokenboundAccount.sol";
import "../src/ERC721CloneableTBA.sol";
import "../src/ERC1155Cloneable.sol";
import "../src/erc6551/ERC6551Registry.sol";

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
    // new address for an unauthorized user
    address public unauthorizedUser = address(0x4);

    address public tronicOwner = address(0x5);

    address payable public tbaAddress;

    function setUp() public {
        vm.startPrank(tronicOwner);
        account = new TokenboundAccount();
        erc721 = new ERC721CloneableTBA();
        erc1155 = new ERC1155Cloneable();
        registry = new ERC6551Registry();

        tbaAddress = payable(address(account));

        //initialize erc721 and erc1155
        erc721.initialize(tbaAddress, address(registry), "Original721", "OR721", "http://example721.com/", tronicOwner);

        factory = new CloneFactory(tronicOwner, address(erc721), address(erc1155), address(registry), tbaAddress);
        vm.stopPrank();
    }

    function testFactoryOwnership() public {
        assertEq(factory.tronicAdmin(), tronicOwner);
    }

    function testChangeFactoryOwnership() public {
        vm.prank(tronicOwner);
        // Change tronicAdmin to user1
        factory.setTronicAdmin(user1);
        assertEq(factory.tronicAdmin(), user1);

        // Try to change tronicAdmin from a non-admin address should fail
        vm.expectRevert();
        vm.prank(user2);
        factory.setTronicAdmin(user2);
    }

    function testCloneERC1155() public {
        vm.prank(tronicOwner);
        address clone1155Address = factory.cloneERC1155("http://clone1155.com/", user1, "Clone1155", "CL1155");

        // clone should exist
        assertNotEq(clone1155Address, address(0));

        // Check the clone has correct uri and admin
        ERC1155Cloneable clone1155 = ERC1155Cloneable(clone1155Address);
        assertEq(clone1155.uri(1), "http://clone1155.com/");
        assertEq(clone1155.isAdmin(user1), true);

        // Check the clone can be retrieved using getERC1155Clone function
        assertEq(factory.getERC1155Clone(0), clone1155Address);

        // mint token to user1
        vm.prank(user1);
        clone1155.mintFungible(user1, 1, 1);

        // transfer token to user2
        vm.prank(user1);
        clone1155.safeTransferFrom(user1, user2, 1, 1, "");
    }

    function testCloneERC721() public {
        vm.prank(tronicOwner);
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

    function testUnauthorizedCloning() public {
        // Prank the VM to make the unauthorized user the msg.sender
        vm.prank(unauthorizedUser);

        // Expect the cloneERC1155 function to be reverted due to unauthorized access
        vm.expectRevert();
        factory.cloneERC1155("http://unauthorized1155.com/", unauthorizedUser, "Clone1155", "CL1155");

        // Expect the cloneERC721 function to be reverted due to unauthorized access
        vm.expectRevert();
        factory.cloneERC721("Unauthorized721", "UN721", "http://unauthorized721.com/", unauthorizedUser);
    }
}
