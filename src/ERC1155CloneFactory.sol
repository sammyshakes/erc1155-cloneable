// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC1155Cloneable.sol";

contract ERC1155Factory {
    event CloneCreated(address clone, string name);

    address public tronicAdmin;

    ERC1155Cloneable public implementation;
    mapping(uint256 => address) public clones;
    uint256 public numClones;

    constructor(address _tronicAdmin) {
        implementation = new ERC1155Cloneable();
        tronicAdmin = _tronicAdmin;
    }

    function getClone(uint256 index) external view returns (address) {
        return clones[index];
    }

    function createClone(string memory uri, address admin) external returns (address clone) {
        clone = Clones.clone(address(implementation));
        ERC1155Cloneable(clone).initialize(uri, admin, tronicAdmin);

        clones[numClones] = clone;
        numClones++;

        emit CloneCreated(clone, uri);
    }
}
