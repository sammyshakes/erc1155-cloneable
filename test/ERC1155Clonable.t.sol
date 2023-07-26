// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ERC1155Cloneable.sol";
import "../src/ERC1155CloneFactory.sol";

contract ERC1155CloneTest is Test {
    ERC1155Factory public factory;
    ERC1155Cloneable public cloneable;

    // set users
    address public user1 = address(0x1);
    address public user2 = address(0x2);
    address public user3 = address(0x3);
    address public user4 = address(0x4);

    address public admin1 = address(0x5);
    address public tronicAdmin = address(0x6);

    function setUp() public {
        factory = new ERC1155Factory(tronicAdmin);
        cloneable = new ERC1155Cloneable();
    }

    function testCreateClone() public {
        address clone = factory.createClone("http://example.com1/", admin1);
        console.log("clone address: ", clone);

        assertEq(ERC1155Cloneable(clone).uri(1), "http://example.com1/");
        assertEq(ERC1155Cloneable(clone).balanceOf(user1, 1), 0);
    }

    function testMintClone() public {
        address cloneAddress = factory.createClone("http://example.com2/", admin1);

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
        address clone = factory.createClone("uri", admin1);

        ERC1155Cloneable cloneContract = ERC1155Cloneable(clone);

        assertEq(cloneContract.owner(), tronicAdmin);
    }

    // Test new token types
    function testCreateTokenType() public {
        address clone = factory.createClone("uri", admin1);

        vm.prank(admin1);
        ERC1155Cloneable(clone).createType(4, "http://example.com");

        // assertEq(ERC1155Cloneable(clone).uri(4), "http://example.com");
    }

    // Test setting fungible URI
    function testSetFungibleURI() public {
        address clone = factory.createClone("uri", admin1);

        vm.prank(admin1);
        ERC1155Cloneable(clone).setFungibleURI(1, "http://fungible.com");

        assertEq(ERC1155Cloneable(clone).uri(1), "http://fungible.com");
    }

    // Test safe transfer
    function testSafeTransfer() public {
        address clone = factory.createClone("uri", admin1);

        vm.prank(admin1);
        ERC1155Cloneable(clone).mint(user1, 1, 10);

        // Approve transferFrom
        vm.prank(user1);
        ERC1155Cloneable(clone).safeTransferFrom(user1, user2, 1, 5, "");

        assertEq(ERC1155Cloneable(clone).balanceOf(user1, 1), 5);
        assertEq(ERC1155Cloneable(clone).balanceOf(user2, 1), 5);
    }
}
