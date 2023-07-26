// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract ERC721Cloneable is ERC721 {
    address public owner;
    mapping(address => bool) private _admins;

    // Token ID => URI mapping
    mapping(uint256 => string) private _tokenURIs;

    constructor() ERC721("") {}

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

    // Create new token
    function createToken(uint256 _id, string memory _uri) external onlyAdmin {
        require(!_exists(_id), "Token already exists");

        _mint(msg.sender, _id);
        _setTokenURI(_id, _uri);
    }

    function setTokenURI(uint256 _id, string memory _uri) external onlyAdmin {
        require(_exists(_id), "Token does not exist");

        _setTokenURI(_id, _uri);
    }

    function tokenURI(uint256 _id) public view override returns (string memory) {
        require(_exists(_id), "Token does not exist");

        return _tokenURIs[_id];
    }

    function addAdmin(address _admin) external onlyOwner {
        _admins[_admin] = true;
    }

    function removeAdmin(address _admin) external onlyOwner {
        _admins[_admin] = false;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC721).interfaceId || super.supportsInterface(interfaceId);
    }
}
