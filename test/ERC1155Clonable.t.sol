// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ERC1155Cloneable.sol";
import "../src/ERC721CloneableTBA.sol";
import "../src/CloneFactory.sol";
import "../src/TokenboundAccount.sol";

contract ERC1155CloneTest is Test {
    CloneFactory public factory;
    ERC1155Cloneable public erc1155cloneable;
    ERC721CloneableTBA public erc721cloneable;
    TokenboundAccount public tbaCloneable;

    // set users
    address public user1 = address(0x1);
    address public user2 = address(0x2);
    address public user3 = address(0x3);
    address public user4 = address(0x4);

    address public admin1 = address(0x5);
    address public tronicAdmin = address(0x6);

    address payable public tbaAddress;

    function setUp() public {
        tbaCloneable = new TokenboundAccount();
        erc1155cloneable = new ERC1155Cloneable();
        erc721cloneable = new ERC721CloneableTBA();

        tbaAddress = payable(address(tbaCloneable));

        factory =
        new CloneFactory(tronicAdmin, address(erc721cloneable), address(erc1155cloneable), address(tbaCloneable), tbaAddress);

        //initialize erc721 and erc1155
        erc721cloneable.initialize(
            tbaAddress, address(this), "Original721", "OR721", "http://example721.com/", address(this)
        );

        erc1155cloneable.initialize("http://example1155.com/", address(this), address(this));
    }

    function testCreateClone() public {
        vm.prank(tronicAdmin);
        address clone = factory.cloneERC1155("http://example.com1/", admin1);
        console.log("clone address: ", clone);

        assertEq(ERC1155Cloneable(clone).uri(1), "http://example.com1/");
        assertEq(ERC1155Cloneable(clone).balanceOf(user1, 1), 0);
    }

    function testMintClone() public {
        vm.prank(tronicAdmin);
        address cloneAddress = factory.cloneERC1155("http://example.com2/", admin1);

        ERC1155Cloneable clone = ERC1155Cloneable(cloneAddress);

        vm.startPrank(admin1);
        clone.mint(user1, 1, 1);
        assertEq(clone.uri(1), "http://example.com2/");
        assertEq(clone.balanceOf(user1, 1), 1);

        clone.mint(user1, 2, 10);
        clone.mint(user1, 3, 5);

        assertEq(clone.balanceOf(user1, 2), 10);
        assertEq(clone.balanceOf(user1, 3), 5);

        clone.mint(user2, 1, 10);
        clone.mint(user2, 2, 5);

        assertEq(clone.balanceOf(user2, 1), 10);
        assertEq(clone.balanceOf(user2, 2), 5);
        vm.stopPrank();
    }

    // Test admin roles
    function testAdminRoles() public {
        vm.prank(tronicAdmin);
        address clone = factory.cloneERC1155("uri", admin1);

        ERC1155Cloneable cloneContract = ERC1155Cloneable(clone);

        assertEq(cloneContract.owner(), tronicAdmin);
    }

    // Test new token types
    function testCreateTokenType() public {
        vm.prank(tronicAdmin);
        address clone = factory.cloneERC1155("uri", admin1);

        vm.prank(admin1);
        ERC1155Cloneable(clone).createType(4, "http://example.com");

        // assertEq(ERC1155Cloneable(clone).uri(4), "http://example.com");
    }

    // Test setting fungible URI
    function testSetFungibleURI() public {
        vm.prank(tronicAdmin);
        address clone = factory.cloneERC1155("uri", admin1);

        vm.prank(admin1);
        ERC1155Cloneable(clone).setFungibleURI(1, "http://fungible.com");

        assertEq(ERC1155Cloneable(clone).uri(1), "http://fungible.com");
    }

    // Test safe transfer
    function testSafeTransfer() public {
        vm.prank(tronicAdmin);
        address clone = factory.cloneERC1155("uri", admin1);

        vm.prank(admin1);
        ERC1155Cloneable(clone).mint(user1, 1, 10);

        // Approve transferFrom
        vm.prank(user1);
        ERC1155Cloneable(clone).safeTransferFrom(user1, user2, 1, 5, "");

        assertEq(ERC1155Cloneable(clone).balanceOf(user1, 1), 5);
        assertEq(ERC1155Cloneable(clone).balanceOf(user2, 1), 5);
    }

    // Clone ERC721 token
    function testCloneERC721() public {
        string memory name = "MyToken";
        string memory symbol = "MTK";

        vm.prank(tronicAdmin);
        address clone = factory.cloneERC721(name, symbol, "http://example.com/", admin1);

        ERC721CloneableTBA token = ERC721CloneableTBA(clone);

        assertEq(token.name(), name);
        assertEq(token.symbol(), symbol);
    }

    // // Mint ERC721 token
    // function testMintBurnERC721() public {
    //     address clone = factory.cloneERC721("Name", "SYM", "http://example.com/", admin1);

    //     vm.startPrank(admin1);
    //     ERC721CloneableTBA(clone).mint(user1, 1);

    //     assertEq(ERC721CloneableTBA(clone).ownerOf(1), user1);

    //     ERC721CloneableTBA(clone).burn(1);

    //     vm.expectRevert();
    //     ERC721CloneableTBA(clone).ownerOf(1);
    //     vm.stopPrank();
    // }

    // // Test ERC721 approvals
    // function testERC721Approve() public {
    //     address clone = factory.cloneERC721("Name", "SYM", "http://example.com/", admin1);

    //     vm.prank(admin1);
    //     ERC721CloneableTBA(clone).mint(user1, 1);

    //     vm.prank(user1);
    //     ERC721CloneableTBA(clone).approve(user2, 1);

    //     assertEq(ERC721CloneableTBA(clone).getApproved(1), user2);

    //     // Test approval
    // }
}
