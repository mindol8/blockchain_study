// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.10;

interface ERC20Interface {
    //생성하고자하는 토큰의 성질에 따라 override해서 사용한다.
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address spender, address recipient, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Transfer(address indexed spender, address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 oldAmount, uint256 amount);
}

contract SimpleToken is ERC20Interface { //interface 정의한것 상속
    mapping (address => uint256) private _balances;//주소: 잔액 map
    mapping (address => mapping (address => uint256)) public _allowances;//주소 :(주소: 수당 )map => 이중 map. 누가 어디에 얼마를 예치

    uint256 public _totalSupply;//토큰 총 발행량
    string public _name;//토큰 이름
    string public _symbol;//별칭 (ex.ethereum => eth)
    uint8 public _decimals;//소수점, 해당 토큰의 최소단위 설정
    
    constructor(string memory getName, string memory getSymbol) {//토큰 생성
        _name = getName;
        _symbol = getSymbol;
        _decimals = 18;
        _totalSupply = 100000000e18;
        _balances[msg.sender] = _totalSupply;//내가 만든 토큰을 내가 다가진다.
    }
    
    //storage는 블록체인에 영구저장, memory는 임시 저장
    function name() public view returns (string memory) {//토큰 이름 getter
        return _name;
    }
    
    function symbol() public view returns (string memory) {//토큰 별칭 getter
        return _symbol;
    }
    
    function decimals() public view returns (uint8) {//최소단위 getter
        return _decimals;
    }
    
    function totalSupply() external view virtual override returns (uint256) {//총 발행량 getter
        return _totalSupply;
    }
    
    function balanceOf(address account) external view virtual override returns (uint256) {//해당 account가 가지고 있는 토큰의 개수 getter
        return _balances[account];
    }
    
    function transfer(address recipient, uint amount) public virtual override returns (bool) {
        //override key word => IERC20(ERC20의 interface에 관한 내용) 상속받은 함수를 override한다고 명시
        _transfer(msg.sender, recipient, amount);//토큰 전송
        emit Transfer(msg.sender, recipient, amount);//토큰 전송 이벤트 발생 => transaction에 기록
        return true;
    }
    
    function allowance(address owner, address spender) external view override returns (uint256) {//owner가 spender에게 예치한 token개수 getter
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint amount) external virtual override returns (bool) {
        uint256 currentAllownace = _allowances[spender][msg.sender];//spender가 transaction 발생자에게 예치한 token 개수 저장하는 변수
        require(currentAllownace >= amount, "ERC20: Transfer amount exceeds allowance");//보내고자하는 token수량(amount)보다 예치된 token의 개수가 적을 경우 error
        _approve(msg.sender, spender, currentAllownace, amount);//예치작업 실행
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) external virtual override returns (bool) {
        //sender가 토큰을 예치한 중간 교환자가  transaction 발생
        //recipient가 중간 교환자로부터 sender가 예치한 토큰을 구매
        _transfer(sender, recipient, amount);//토큰 보냄
        //실제로 전송이 가능한지 검사는 하나 실패한 경우 예치한 토큰에 대한 갱신이 없다.=> 구현단계에서 return이 false일 경우 처리해줘야 하는건가?
        emit Transfer(msg.sender, sender, recipient, amount);//transfer event 발생
        uint256 currentAllowance = _allowances[sender][msg.sender];//sender가 transaction 발생자에게 예치한 token 수량 저장하는 변수
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");//총량 비교
        _approve(sender, msg.sender, currentAllowance, currentAllowance - amount);//빠져나가는 만큼 갱신
        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        //internal => smart contract의 interface로 비공개한다. 계약서 내용을 비공개한다는 의미며, 계약서 내부에서만 사용하는 함수
        //state variable는 default값이 internal => 계약서 자신과 상속받은 계약만 사용할 수 있다.
        //virtual => 0.6버젼부터 새로 생긴 키워드. virtual이라고 명시되어 있거나, interface에 정의 되어 있어야만 override해서 사용할 수 있다.        
        require(sender != address(0), "ERC20: transfer from the zero address");//sender 주소 검사
        require(recipient != address(0), "ERC20: transfer to the zero address");//recipient 주소 검사
        uint256 senderBalance = _balances[sender];//sender가 가지고 있는 토큰의 개수 저장하는 변수
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        //첫번째 인자로 들어오는 조건이 false일 때 error 발생. 보내고자하는 토큰의 수(amount)보다 sender가 가지고 있는 토큰의 개수(senderBalance)가 더 적은 경우 error발생
        _balances[sender] = senderBalance - amount;//보내는 양 만큼 삭감
        _balances[recipient] += amount;//받는 양만큼 추가
    }
    
    function _approve(address owner, address spender, uint256 currentAmount, uint256 amount) internal virtual {
        //owner가 spender에게 amount만큼 토큰을 예치한다.
        require(owner != address(0), "ERC20: approve from the zero address");//owner 주소검사
        require(spender != address(0), "ERC20: approve to the zero address");//spender 주소 검사
        require(currentAmount == _allowances[owner][spender], "ERC20: invalid currentAmount");//실제로 가지고 있는 토큰수 비교
        _allowances[owner][spender] = amount;//owner가 spender에게 예치한 token 갱신
        emit Approval(owner, spender, currentAmount, amount);//approval event 발생
        //approve과정에서는 실제 보유한 토큰의 개수가 변경되는 것이 아니라, 넘겨줄양을 명시한다.
    }
}