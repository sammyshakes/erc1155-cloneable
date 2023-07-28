// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./erc6551/examples/simple/SimpleERC6551Account.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

/**
 * @title A smart contract account owned by a single ERC721 token
 */

contract TokenboundAccount is SimpleERC6551Account, IERC721Receiver, IERC1155Receiver {
    address public operator;

    // Arrays to store assets
    IERC20[] public erc20Balances;
    IERC1155[] public erc1155Contracts;
    uint256[][] public erc1155Balances;
    mapping(address => uint256[]) public erc721Tokens;

    modifier onlyOperatorOrOwner() {
        require(msg.sender == owner() || msg.sender == operator, "Not authorized");
        _;
    }

    function onERC721Received(address, address, uint256 tokenId, bytes calldata) external returns (bytes4) {
        _receiveERC721(IERC721(msg.sender), tokenId);
        return this.onERC721Received.selector;
    }

    function onERC1155Received(address, address, uint256 id, uint256 amount, bytes calldata)
        external
        returns (bytes4)
    {
        IERC1155 tokenContract = IERC1155(msg.sender);

        _receiveERC1155(tokenContract, id, amount);

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata
    ) external returns (bytes4) {
        for (uint256 i = 0; i < ids.length; i++) {
            _receiveERC1155(IERC1155(msg.sender), ids[i], amounts[i]);
        }
        return this.onERC1155BatchReceived.selector;
    }

    function _receiveERC721(IERC721 erc721, uint256 tokenId) internal {
        erc721Tokens[address(erc721)].push(tokenId);
    }

    function _receiveERC1155(IERC1155 erc1155, uint256 id, uint256 amount) internal {
        if (!_containsAssetContract(erc1155Contracts, erc1155)) {
            erc1155Contracts.push(erc1155);
            erc1155Balances.push(new uint256[](0));
        }
        erc1155Balances[erc1155Contracts.length - 1].push(id);
        erc1155Balances[erc1155Contracts.length - 1].push(amount);
    }

    function _containsAssetContract(IERC1155[] storage assets, IERC1155 asset) internal view returns (bool) {
        for (uint256 i = 0; i < assets.length; i++) {
            if (assets[i] == asset) {
                return true;
            }
        }
        return false;
    }

    function transferToken(address token, uint256 id, uint256 amount, address to) external onlyOperatorOrOwner {
        if (IERC165(token).supportsInterface(type(IERC1155).interfaceId)) {
            IERC1155(token).safeTransferFrom(address(this), to, id, amount, "");
        } else if (IERC165(token).supportsInterface(type(IERC721).interfaceId)) {
            IERC721(token).transferFrom(address(this), to, id);

            // Remove the token ID from the contract's list of owned tokens
            uint256[] storage ownedTokens = erc721Tokens[token];
            for (uint256 i = 0; i < ownedTokens.length; i++) {
                if (ownedTokens[i] == id) {
                    // Swap the token ID to remove with the last token ID in the array, then remove the last token ID
                    ownedTokens[i] = ownedTokens[ownedTokens.length - 1];
                    ownedTokens.pop();
                    break;
                }
            }
        } else if (IERC165(token).supportsInterface(type(IERC20).interfaceId)) {
            IERC20(token).transfer(to, amount);
        }
    }

    function setOperator(address _operator) external {
        require(msg.sender == owner(), "Not owner");
        operator = _operator;
    }

    // function getAssets()
    //     external
    //     view
    //     returns (
    //         IERC20[] memory,
    //         uint256[] memory,
    //         IERC721[] memory,
    //         uint256[] memory,
    //         IERC1155[] memory,
    //         uint256[][] memory,
    //         uint256[][] memory
    //     )
    // {
    //     uint256[] memory erc20BalancesAmounts = new uint256[](erc20Balances.length);
    //     uint256[] memory erc721TokenIds = new uint256[](erc721Tokens.length);
    //     uint256[][] memory erc1155Ids = new uint256[][](erc1155Contracts.length);
    //     uint256[][] memory erc1155Amounts = new uint256[][](erc1155Contracts.length);

    //     for (uint256 i = 0; i < erc20Balances.length; i++) {
    //         erc20BalancesAmounts[i] = erc20Balances[i].balanceOf(address(this));
    //     }

    //     for (uint256 i = 0; i < erc721Tokens.length; i++) {
    //         erc721TokenIds[i] = erc721Tokens[address(erc721Tokens[i])].length;
    //     }

    //     for (uint256 i = 0; i < erc1155Contracts.length; i++) {
    //         erc1155Ids[i] = new uint256[](erc1155Balances[i].length / 2);
    //         erc1155Amounts[i] = new uint256[](erc1155Balances[i].length / 2);

    //         for (uint256 j = 0; j < erc1155Balances[i].length; j += 2) {
    //             erc1155Ids[i][j / 2] = erc1155Balances[i][j];
    //             erc1155Amounts[i][j / 2] = erc1155Balances[i][j + 1];
    //         }
    //     }

    //     return (
    //         erc20Balances,
    //         erc20BalancesAmounts,
    //         erc721Tokens,
    //         erc721TokenIds,
    //         erc1155Contracts,
    //         erc1155Ids,
    //         erc1155Amounts
    //     );
    // }
}
