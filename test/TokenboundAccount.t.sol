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

        // new brand joins tronic anclones erc1155

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

    // function testGetAssets() public {
    //     // Mint test token and grant tba to user1
    //     address tba = token.mint(user1, 1);
    //     TokenboundAccount tbaAccount = TokenboundAccount(payable(address(tba)));

    //     // Mint brand erc1155 tokens to tba
    //     brandERC1155.mint(address(tbaAccount), 1, 1000);

    //     // Use getAssets function to fetch assets
    //     (
    //         IERC20[] memory erc20s,
    //         uint256[] memory erc20BalancesAmounts,
    //         IERC721[] memory erc721s,
    //         uint256[] memory erc721TokenIds,
    //         IERC1155[] memory erc1155s,
    //         uint256[][] memory erc1155Ids,
    //         uint256[][] memory erc1155Amounts
    //     ) = tbaAccount.getAssets();

    //     // There should be 1 ERC721 token (the one we minted)
    //     assertEq(erc721s.length, 1);
    //     // The balance of the ERC721 token should be 1
    //     assertEq(erc721TokenIds[0], 1);

    //     // There should be 1 ERC1155 token (the one we minted)
    //     assertEq(erc1155s.length, 1);
    //     // The ERC1155 token should have the ID 1 and the amount 1000
    //     assertEq(erc1155Ids[0][0], 1);
    //     assertEq(erc1155Amounts[0][0], 1000);

    //     // There should be no ERC20 tokens
    //     assertEq(erc20s.length, 0);
    // }

    // function testERC721Integration() public {
    //     vm.startPrank(user1);
    //     token.mint(address(this), 1);
    //     token.approve(address(account), 1);
    //     token.safeTransferFrom(address(this), address(account), 1);

    //     (,, IERC1155[] memory erc1155Tokens) = account.getAssets();
    //     assertEq(erc1155Tokens.length, 0);

    //     (, IERC721[] memory erc721Tokens,) = account.getAssets();
    //     assertEq(erc721Tokens.length, 1);
    //     console.log("erc721Tokens[0]: ", erc721Tokens[0]);
    //     // assertEq(erc721Tokens[0], token);

    //     vm.stopPrank();
    // }

    // function testERC1155Integration() public {
    //     vm.startPrank(user1);

    //     brandERC1155.mint(address(this), 1, 10);
    //     brandERC1155.setApprovalForAll(address(account), true);
    //     brandERC1155.safeTransferFrom(address(this), address(account), 1, 5, "");

    //     (,, IERC1155[] memory erc1155Tokens) = account.getAssets();
    //     assertEq(erc1155Tokens.length, 1);
    //     assertEq(erc1155Tokens[0], brandERC1155);

    //     vm.stopPrank();
    // }

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
