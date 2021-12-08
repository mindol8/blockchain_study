import express from "express";
import Web3 from "web3";
const app = express();
const port = 8080;
const URL = "http://127.0.0.1:7545";

const getWeb3 = () =>{
    const web3 = new Web3(new Web3.providers.HttpProvider(URL));//http에서 동작하는 해당 URL을 가지는 node에 연결
    return web3;
}

const getAccount = async () =>{
    try{
        const web3 = getWeb3();
        const accounts = await web3.eth.getAccounts(); 
        return accounts;
    }catch (e){
        return e;
    }
}

const getGasPrice = async () =>{
    try {
        const web3 = getWeb3();
        const gasPrice = await web3.eth.getGasPrice();
        return  gasPrice;
    } catch (error) {
        return error;
    }
}

const getBlock = async () =>{
    try {
        const web3 = getWeb3();
        const block = await web3.eth.getBlock("latest");
        return block;
        /*
            "earliest" => genesis block
            "latest" => 가장 최신 block
            "pending" => pending 상태 block
        */
    } catch (error) {
        return error;
    }
}
app.get('/',(req,res)=>{
    getAccount()
    .then(acc=>{
        res.send(acc);
    })
})

app.get('/gasprice',(req,res)=>{
    getGasPrice()
    .then(gas=>{
        res.send(gas);
    })
})

app.get('/getblock',(req,res)=>{
    getBlock()
    .then(block=>{
        res.send(block);
    })
})

app.listen(port,()=>{
    console.log(`running server port: ${port}`);
})