// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC1155Cloneable.sol";
import "./ERC721Cloneable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract CloneFactory {
    event CloneCreated(address clone, string name);

    address public tronicAdmin;
    ERC721Cloneable public erc721Implementation;
    ERC1155Cloneable public erc1155implementation;
    mapping(uint256 => address) public erc1155Clones;
    mapping(uint256 => address) public erc721Clones;
    uint256 private _numERC1155Clones;
    uint256 private _numERC721Clones;

    constructor(address _tronicAdmin) {
        erc1155implementation = new ERC1155Cloneable();
        erc721Implementation = new ERC721Cloneable();
        tronicAdmin = _tronicAdmin;
    }

    function getERC1155Clone(uint256 index) external view returns (address) {
        return erc1155Clones[index];
    }

    function getNumERC1155Clones() external view returns (uint256) {
        return _numERC1155Clones;
    }

    function cloneERC1155(string memory uri, address admin) external returns (address erc1155cloneAddress) {
        erc1155cloneAddress = Clones.clone(address(erc1155implementation));
        ERC1155Cloneable erc1155clone = ERC1155Cloneable(erc1155cloneAddress);
        erc1155clone.initialize(uri, admin, tronicAdmin);

        erc1155Clones[_numERC1155Clones] = erc1155cloneAddress;
        _numERC1155Clones++;

        emit CloneCreated(erc1155cloneAddress, uri);
    }

    function cloneERC721(string memory name, string memory symbol, string memory uri, address admin) external returns (address erc721CloneAddress){
        erc721CloneAddress = Clones.clone(address(erc721Implementation));
        ERC721Cloneable erc721Clone = ERC721Cloneable(erc721CloneAddress);
        erc721Clone.initialize(name, symbol, uri, admin);

        // Emit event, store clone, etc
        erc721Clones[_numERC721Clones] = erc721CloneAddress;
        _numERC721Clones++;

        emit CloneCreated(erc721CloneAddress, uri);
    }
}
