import Web3 from "web3";
const rpcUrl = "https://ropsten.infura.io/v3/84c17e384bc64fab95c2181c7bc1c507";
const getTransactionsByAccount = async (account,startBlock,endBlock) => {
    const web3 = new Web3(rpcUrl);
    let transactions = [];
    let accountTransactions=[];
    for(let i=startBlock;i<=endBlock;i++){
        await web3.eth.getBlock(i)
        .then(block=>{
            transactions = transactions.concat(block.transactions);
        })
    }
    
    for(let i=0;i<transactions.length;i++){
        /*
         await web3.eth.getTransaction(transactions[i])
        .then(transaction=>{  
           console.log("trans ",transaction.from);
           if(transaction.from === account || transaction.to === account){
                //console.log(transaction);
                accountTransactions = accountTransactions.concat(transaction)

           }
        })
        */
       
        await web3.eth.getTransactionReceipt(transactions[i])
        .then(transaction=>{  
            if(transaction.from === account.toLowerCase() || transaction.to === account.toLowerCase()){
                //console.log(transaction);
                accountTransactions = accountTransactions.concat(transaction)

           }
          
        })
    }
    //console.log(accountTransactions);
    return accountTransactions;

}

export default getTransactionsByAccount;

//const _account = "0x459F501012aD38d0cC52C0fd0669B1F7764f3814";
//getTransactionsByAccount(_account,11573826,11573826)


/**
 getTransactionReceipt => block에 올라간 transaction만 출력
 getTransaction => 아직 pending상태인 transaction도 출력
  
 */