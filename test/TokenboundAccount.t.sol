// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Test.sol";
import "../src/TokenboundAccount.sol";
import "../src/ERC721Cloneable.sol";

contract TokenboundAccountTest is Test {
    TokenboundAccount public account;
    ERC721Cloneable public token;
    ERC6551Registry public registry;

    // set users
    address public user1 = address(0x1);
    address public user2 = address(0x2);
    address public user3 = address(0x3);

    function setUp() public {
        account = new TokenboundAccount();
        token = new ERC721Cloneable(payable(address(account)));
        registry = new ERC6551Registry();

        // set registry on erc721 cloneable
        token.setRegistry(address(registry));

        console.log("SETUP - tokenbound account address: ", address(account));
        console.log("SETUP - clonable erc721 token address: ", address(token));

        //add admin to account
        token.addAdmin(address(this));
    }

    function testMintingToken() public {
        // Mint test token
        address tba = token.mint(address(this), 1);
        console.log("SETUP - tokenbound account created: ", tba);
        // Account should own token
        // assertEq(token.ownerOf(1), address(this));
        console.log("token owner: ", token.ownerOf(1));

        //deployed tba
        TokenboundAccount tbaContract = TokenboundAccount(payable(address(tba)));
        console.log("tbaContract owner: ", tbaContract.owner());

        //transfer token to another user
        token.transferFrom(address(this), user1, 1);

        //user1 should own token
        assertEq(token.ownerOf(1), user1);

        //user1 should also control tba
        assertEq(tbaContract.owner(), user1);
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
