// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Test.sol";
import "../src/TokenboundAccount.sol";
import "../src/ERC721CloneableTBA.sol";
import "../src/ERC1155Cloneable.sol";

contract TokenboundAccountTest is Test {
    TokenboundAccount public account;
    ERC721CloneableTBA public token;
    ERC1155Cloneable public brandERC1155;
    ERC6551Registry public registry;

    // set users
    address public user1 = address(0x1);
    address public user2 = address(0x2);
    address public user3 = address(0x3);

    function setUp() public {
        account = new TokenboundAccount();
        token = new ERC721CloneableTBA(payable(address(account)));
        brandERC1155 = new ERC1155Cloneable();
        registry = new ERC6551Registry();

        // set registry on erc721 cloneable
        token.setRegistry(address(registry));

        // initialize brand erc1155
        brandERC1155.initialize("http://example.com/", address(this), address(this));

        //add admin to account
        token.addAdmin(address(this));
        brandERC1155.addAdmin(address(this));
    }

    function testMintingToken() public {
        console.log("SETUP - tokenbound account address: ", address(account));
        console.log("SETUP - clonable erc721 token address: ", address(token));
        console.log("SETUP - erc1155 token address: ", address(brandERC1155));
        console.log("SETUP - registry address: ", address(registry));

        // Mint test token
        address tba = token.mint(address(this), 1);
        console.log("SETUP - tokenbound account created: ", tba);
        // Account should own token
        // assertEq(token.ownerOf(1), address(this));
        console.log("token owner: ", token.ownerOf(1));

        //deployed tba
        TokenboundAccount tbaAccount = TokenboundAccount(payable(address(tba)));
        console.log("tbaAccount owner: ", tbaAccount.owner());

        //transfer token to another user
        token.transferFrom(address(this), user1, 1);

        //user1 should own token
        assertEq(token.ownerOf(1), user1);

        //user1 should also control tba
        assertEq(tbaAccount.owner(), user1);
    }

    function testOwningERC1155Token() public {
        // Mint test token and grant tba to user1
        address tba = token.mint(user1, 1);
        TokenboundAccount tbaAccount = TokenboundAccount(payable(address(tba)));

        // verify tba == address(tbaAccount)
        assertEq(tba, address(tbaAccount));

        // verify user1 owns token
        assertEq(token.ownerOf(1), user1);

        // mint brand erc1155 tokens to tba
        brandERC1155.mint(address(tbaAccount), 1, 1000);

        //verify tba owns erc1155 token
        assertEq(brandERC1155.balanceOf(address(tbaAccount), 1), 1000);

        //transfer erc1155 token to user2
        vm.startPrank(user1);
        tbaAccount.transferToken(address(brandERC1155), 1, 100, user2);

        //verify user2 owns erc1155 token
        assertEq(brandERC1155.balanceOf(user2, 1), 100);

        //transfer token to another user
        token.transferFrom(user1, user3, 1);

        vm.stopPrank();

        //user3 should own token
        assertEq(token.ownerOf(1), user3);

        //user3 should also control tba
        assertEq(tbaAccount.owner(), user3);
    }

    // function testReceiveTokens(address tokenContract) public {
    //     // Send tokens
    //     IERC20(tokenContract).transfer(address(account), 100);

    //     // Account should receive tokens
    // }

    // function testTransferToken() public {
    //     // Approve account
    //     vm.prank(address(this));
    //     token.approve(address(account), 1);

    //     // Transfer token out
    //     account.transferToken(address(token), 1, 1);

    //     // Token should be transferred back
    // }
}
