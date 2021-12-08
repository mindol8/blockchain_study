import Web3 from "web3";

const rpcUrl = "https://ropsten.infura.io/v3/84c17e384bc64fab95c2181c7bc1c507";

const web3 = new Web3(rpcUrl);

const account = "0x459F501012aD38d0cC52C0fd0669B1F7764f3814";
/*
//잔액조회
web3.eth.getBalance(account)
.then(res=>{
    console.log(`${res} wei`);
    return web3.utils.fromWei(res,"ether");
})
.then(res=>{
    console.log(`${res} eth`);
})
*/


/*
//getTransaction => 생성한 트랜잭션에 대한 정보를 가져온다.
//getTransactionReceipt => receipt은 블록체인에 deploy 된 이후 생긴다.
//getPendingTransactions => 블럭에 올라가지 못하고 대기중인 트랜잭션 반환
//트랜잭션 조회
const txid = "0x0246ae641cc5989bfa821b4084155380fcb09a55f4cbf20947db15ba8744b1eb";
web3.eth.getTransaction(1,1)
.then(res=>{
    console.log(res);
})

*/

/*
//특정 블록 조회
const blockNum = "11573826";

web3.eth.getBlock(blockNum).then((obj) => {
  console.log(obj);
});
*/

getTransactionsByAccount(account,11573000,11573826)
.then(res=>{
    console.log(`${res} wei`);
    return web3.utils.fromWei(res,"ether");
})
.then(res=>{
    console.log(`${res} eth`);
})