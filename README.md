### Verfiy Tokenbound Account 

```js
forge verify-contract --chain-id 5 --watch 0xCB732ebe48daaf08E9F7C3d14968a5F1E72A045A --etherscan-api-key goerli src/TokenboundAccount.sol:TokenboundAccount
```

### Verfiy ERC721 

```js
forge verify-contract --chain-id 5 --watch 0xe931e45265b58a77328B0c0bABcb6Af417c18154 --etherscan-api-key goerli src/ERC721CloneableTBA.sol:ERC721CloneableTBA
```

### Verfiy ERC1155 

```js
forge verify-contract --chain-id 5 --watch 0x1AEaFDcfb6b7E0322023FC58cf91B34D3076B21d --etherscan-api-key goerli src/ERC1155Cloneable.sol:ERC1155Cloneable
```

### Verfiy ERC6551Registry 

```js
forge verify-contract --chain-id 5 --watch 0xb6F028F59c95F09331776069ccd2bEf85b0C2b1E --etherscan-api-key goerli src/erc6551/ERC6551Registry.sol:ERC6551Registry
```

## Deploy CloneFactory.sol
```js
forge script script/DeployCloneFactory.s.sol:DeployCloneFactory -vvvv --rpc-url goerli --broadcast
```

### Verfiy CloneFactory 

```js
forge verify-contract --chain-id 5 --watch 0x2Da15A03C216dd726bDbB7E003935DB7407a0300 --constructor-args $(cast abi-encode "constructor(address,address,address,address,address)" 0x42C7eF198f8aC9888E2B1b73e5B71f1D4535194A 0xe931e45265b58a77328B0c0bABcb6Af417c18154 0x1AEaFDcfb6b7E0322023FC58cf91B34D3076B21d 0xb6F028F59c95F09331776069ccd2bEf85b0C2b1E 0xCB732ebe48daaf08E9F7C3d14968a5F1E72A045A) --etherscan-api-key goerli src/CloneFactory.sol:CloneFactory
```