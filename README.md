# Basic Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply lists the available accounts.

Try running some of the following tasks:

```
owner account signature offline
https://ethereum.stackexchange.com/questions/23701/can-i-web3-eth-sign-with-private-key
https://blog.openzeppelin.com/signing-and-validating-ethereum-signatures/
https://ethereum.stackexchange.com/questions/98935/modify-block-number-when-testing-with-hardhat
```

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help

npx hardhat run .\scripts\sample-script.js --network rinkeby
npx hardhat verify 0x55f06a5DAC7a0A04e9b5CD8fb306429778b57FAD --network rinkeby 0 0
```
