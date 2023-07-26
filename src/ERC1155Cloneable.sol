// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract ERC1155Cloneable is ERC1155 {
    address public owner;
    mapping(address => bool) private _admins;

    // Token ID => URI mapping
    mapping(uint256 => string) private _fungibleTokenURIs;

    constructor() ERC1155("") {}

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier onlyAdmin() {
        require(_admins[msg.sender], "Only admin");
        _;
    }

    function initialize(string memory _uri, address _admin, address _owner) external {
        _setURI(_uri);
        _admins[_admin] = true;
        owner = _owner;
    }

    mapping(uint256 => bool) private _tokenTypes;

    // Create new token type
    function createType(uint256 _id, string memory _uri) external onlyAdmin {
        require(!_tokenTypes[_id], "Token type already exists");

        // Set URI with id suffix
        _setURI(string(abi.encodePacked(_uri, _id)));

        // Mark id as existing
        _tokenTypes[_id] = true;
    }

    // Mint tokens of existing type
    function mintToken(uint256 id, uint256 amount) external onlyAdmin {
        require(_tokenTypes[id], "Token type does not exist");

        _mint(msg.sender, id, amount, "");
    }

    function mint(address to, uint256 id, uint256 amount) public onlyAdmin {
        _mint(to, id, amount, "");
    }

    function burn(address account, uint256 id, uint256 amount) public onlyAdmin {
        _burn(account, id, amount);
    }

    function setFungibleURI(uint256 id, string memory uri_) external onlyAdmin {
        _fungibleTokenURIs[id] = uri_;
    }

    function uri(uint256 id) public view override returns (string memory) {
        if (bytes(_fungibleTokenURIs[id]).length > 0) {
            return _fungibleTokenURIs[id];
        } else {
            return super.uri(id);
        }
    }

    function addAdmin(address admin) external onlyOwner {
        _admins[admin] = true;
    }

    function removeAdmin(address admin) external onlyOwner {
        _admins[admin] = false;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC1155).interfaceId || super.supportsInterface(interfaceId);
    }
}
