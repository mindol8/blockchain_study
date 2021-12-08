//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract RPS {
    constructor () payable {}

    enum Hand{
        rock,paper,scissors
    }
    
    enum Status{
        WIN,LOSE,TIE,PENDING
    }
    //승,패,비김,대기
    
    enum GameStatus{
        NOT_START,STARTED, COMPLETE, ERROR
    }
    //game의 상태, 대기,시작함,끝남,에러

    struct Player{
        address payable addr; // 주소
        uint256 playBetAmount; // 배팅 금액
        Hand hand;//패
        Status status; //승패여부
    }

    struct Game{
        Player originator;//방장
        Player taker;//참가자
        uint256 BetAmount;//총 배팅 금액
        GameStatus gameStatus;
    }

    mapping(uint => Game) rooms; //rooms라는 map은 uint형식의 key로 Game 구조체 형식의 데이터에 접근이 가능하다.
    uint roomKey = 0;//room 번호, 생성될 때 마다 1씩 증가


    modifier isValidHand(Hand _hand){
        require((_hand == Hand.rock) || (_hand == Hand.paper) || (_hand == Hand.scissors));
        _;
    }
    //검사 
    //create room
    function createRoom (Hand _hand) public payable isValidHand(_hand) returns (uint roomNum){

        rooms[roomKey] = Game({
            BetAmount:msg.value, //contract 시작한 transaction call, msg call에 대한 정보
            gameStatus:GameStatus.NOT_START,
            originator:Player({
                hand:_hand,
                addr:payable(msg.sender),
                status:Status.PENDING,
                playBetAmount:msg.value//msg와 함께 보낸 이더 금액
            }),
            taker:Player({
                hand:Hand.rock,
                addr:payable(msg.sender),//msg 메시지 발신자
                playBetAmount:0,
                status:Status.PENDING
            })
            //처음 방생성할 땐 taker정보를 default로 초기화
        });
        roomNum = roomKey;
        roomKey=roomKey+1;
    }       

    function joinRoom (uint roomNum, Hand _hand) public payable isValidHand(_hand){
        rooms[roomNum].taker = Player({
            hand:_hand,
            addr:payable(msg.sender),
            status:Status.PENDING,
            playBetAmount: msg.value
        });
        rooms[roomNum].BetAmount = rooms[roomNum].BetAmount + msg.value;
        //총 배팅금액 갱신
        compareHands(roomNum);
    }
    //승패 결정
    function compareHands(uint roomNum) private{
        uint8 originator = uint8(rooms[roomNum].originator.hand);
        uint8 taker = uint8(rooms[roomNum].taker.hand);

        rooms[roomNum].gameStatus = GameStatus.STARTED;

        //비교
        if(taker == originator){
            //비김
            rooms[roomNum].originator.status = Status.TIE;
            rooms[roomNum].taker.status = Status.TIE;
        }else if((taker+1)%3 == originator){
            //방장이 이김
            rooms[roomNum].originator.status= Status.WIN;
            rooms[roomNum].taker.status = Status.LOSE;
        }else if((originator+1)%3 == taker){
            //참가자가 이김
            rooms[roomNum].originator.status = Status.LOSE;
            rooms[roomNum].taker.status = Status.WIN;
        }else{
            rooms[roomNum].gameStatus = GameStatus.ERROR;
        }
    }

    modifier isPlayer(uint roomNum, address sender){
        //참가자가 중간에 바뀔 수 도 있다.
        require(sender == rooms[roomNum].originator.addr || sender == rooms[roomNum].taker.addr);
        _;
    }
    //배팅금 배분
    function payout(uint roomNum) public payable isPlayer(roomNum,msg.sender){
        if(rooms[roomNum].originator.status == Status.TIE && rooms[roomNum].taker.status == Status.TIE){
            //비김 => 자신이 배팅한 금액을 그대로 돌려 받는다.
            rooms[roomNum].originator.addr.transfer(rooms[roomNum].originator.playBetAmount);
            rooms[roomNum].taker.addr.transfer(rooms[roomNum].taker.playBetAmount);
        }else if(rooms[roomNum].originator.status == Status.WIN){
            //방장이 이김 => 총 배팅 금액을 받는다.
            rooms[roomNum].originator.addr.transfer(rooms[roomNum].BetAmount);
        }else if(rooms[roomNum].taker.status == Status.WIN){
            //참가자가 이김
            rooms[roomNum].taker.addr.transfer(rooms[roomNum].BetAmount);
        }

        rooms[roomNum].gameStatus = GameStatus.COMPLETE;
    }
    
}