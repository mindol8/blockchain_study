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
            if(transaction.from && web3.utils.toChecksumAddress(transaction.from) === account){
                accountTransactions = accountTransactions.concat(transaction)
            }
            if(transaction.to && web3.utils.toChecksumAddress(transaction.to) === account){
                accountTransactions = accountTransactions.concat(transaction)
            }
          /*
            web3.utils.toChecksumAddress() 함수를 사용하면 lower or upper address를 checksum address로 바꿔준다.
            EIP-55에서 발의
            16진수 문자열로 구성된 이더리움 주소에서 소문자를 체크섬 형태의 대문자로 치환
            1. 기존 이더리움 주소에서 접두어 0x 제거하고 hash(Keccak256).
            2. 이더리움 주소와 해시를 비교 => 주소와 매칭되는 해시의 16진수가 0x8 이상인 경우에 주소의 소문자를 대문자로 변경
            ex.
            주소 : 0x 7f7625faa1ca985e9ad678656a9dcdf79620df6b
            해시 :    3015b5c87eeb15cce85e3e48eefb50b400dd497c7b0bd41f16937ead349b3784
            => 주소에서 처음 문자가 등장: 앞에서 두번째, 소문자 'f'. 해시에서 같은 위치에 있는 것은 '0'. 0x0 < 0x8이므로 계속 소문자로 쓴다.
            => 그다음 문자가 등장 : 앞에서 7번째, 소문자 'f'. 해시에서 같은 위치에 있는 것은 'c'. 0xc > 0x8이므로 checksum address에서는 해당 문자를 대문자 'F'로 쓴다.
            => 모든 과정을 거친 결과 : 0x7f7625FAa1CA985E9Ad678656A9DcdF79620dF6B
            cf. web3.utils.checkAddressChecksum() => 인자로 들어오는 주소값이 checksum주소인지 아닌지 검사한다.
          */
        })
    }
    //console.log(accountTransactions);
    return accountTransactions;

}

export default getTransactionsByAccount;

const _account = "0x459F501012aD38d0cC52C0fd0669B1F7764f3814";
getTransactionsByAccount(_account,11573826,11573826)
.then(res=>{
    console.log(res);
})


/**
 getTransactionReceipt => block에 올라간 transaction만 출력
 getTransaction => 아직 pending상태인 transaction도 출력
  
 */
/*
    web3.eth, web3.eth.subscribe: 노드 관련 라이브러리
    web3.eth.Contract, web3.eth.abi: 컨트랙트 관련 라이브러리
    web3.eth.accounts: 계정, 지갑 관련 라이브러리
    web3.eth.personal: 트랜잭션 관련 라이브러리
    web3.*.net: 이더리움이 아닌 다른 블록체인 네트워크를 추가하여 사용하는 경우
    web3.utils: 암호화 등 유틸 라이브러리
*/