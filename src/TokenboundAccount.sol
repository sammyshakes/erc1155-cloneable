// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./erc6551/examples/simple/SimpleERC6551Account.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title A smart contract account owned by a single ERC721 token
 */
contract TokenboundAccount is SimpleERC6551Account, IERC721Receiver, IERC1155Receiver {
    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external pure returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata)
        external
        pure
        returns (bytes4)
    {
        return this.onERC1155BatchReceived.selector;
    }

    function transferToken(address token, uint256 id, uint256 amount) external {
        require(msg.sender == owner(), "Not owner");

        if (IERC165(token).supportsInterface(type(IERC1155).interfaceId)) {
            IERC1155(token).safeTransferFrom(address(this), msg.sender, id, amount, "");
        } else if (IERC165(token).supportsInterface(type(IERC721).interfaceId)) {
            IERC721(token).transferFrom(address(this), msg.sender, id);
        } else if (IERC165(token).supportsInterface(type(IERC20).interfaceId)) {
            IERC20(token).transfer(msg.sender, amount);
        }
    }
}
