import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

// Base ERC1155 contract 
contract ERC1155Base is ERC1155 {

  function initialize(string memory uri_) external initializer {
    __ERC1155_init(uri_);
  }

  function uri(uint256 _id) public view virtual override returns (string memory) {
    return super.uri(_id); 
  }

  function mint(address to, uint256 id, uint256 amount, bytes memory data) public {
    _mint(to, id, amount, data);
  }
  
}

contract ERC1155Factory {

  event CloneCreated(address cloneContract, string name, string symbol);

  function createClone(string memory name, string memory symbol) external {
    address clone = Clones.clone(address(ERC1155Base));
    ERC1155Base(clone).initialize(name);
    emit CloneCreated(clone, name, symbol);
  }

}