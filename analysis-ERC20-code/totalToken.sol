// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.10;

abstract contract OwnerHelper {
    //abstract cnotract = 추상 contract
    //contract의 구현된 기능과 interface의 추상화 기능 모두를 포함. 만약 실제 contract에서 사용하지 않는다면 추상으로 표시되어 사용되지 않음
  	address private _owner;

  	event OwnershipTransferred(address indexed preOwner, address indexed nextOwner);

  	modifier onlyOwner {//관리자주소인지 검사
		require(msg.sender == _owner, "OwnerHelper: caller is not owner");
		_;
  	}

  	constructor() {//관리자 등록
		_owner = msg.sender;
  	}

    function owner() public view virtual returns (address) {
        //관리자 주소 getter
        return _owner;
    }

  	function transferOwnership(address newOwner) onlyOwner public {
        //관리자가 변경되었을 때 이전관리자 주소와 새로운 관리자의 주소 로그
        require(newOwner != _owner);//이전 == 현재인지 검사
        require(newOwner != address(0x0));//주소 유효성 검사
        address preOwner = _owner;
        _owner = newOwner;//갱신
        emit OwnershipTransferred(preOwner, newOwner);//이전, 갱신 관리자 주소 로그
  	}
}

library SafeMath {
  	function mul(uint256 a, uint256 b) internal pure returns (uint256) {//pure => storage에서 변수를 읽어오거나 쓰지 않는 함수임을 명시
		uint256 c = a * b;
		assert(a == 0 || c / a == b);
        //assert는 gas limit를 초과시켜서 작업 중단시킴.  절대 변해선 안되는 값에 대한 체크를 할때만 활용 
        //a가 이거나 c를 다시 0이 아닌 a로 나누어서 b값이 나오는지 검사한 후, 해당 검사를 통과한 경우에만 c를 return
		return c;
  	}

  	function div(uint256 a, uint256 b) internal pure returns (uint256) {
	    uint256 c = a / b;
		return c;
  	}

  	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
        //balance가 음수가 되는 경우 방지
		return a - b;
  	}

  	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		assert(c >= a);//overflow check
		return c;
	}
}

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

contract SimpleToken is ERC20Interface,OwnerHelper { //interface 정의한것 상속 상속되는 순간 abstract contract가 실행된다.
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) public _allowances;

    uint256 public _totalSupply;
    string public _name;
    string public _symbol;
    uint8 public _decimals;
    bool public _tokenLock;
    mapping (address => bool) public _personalTokenLock;

    constructor(string memory getName, string memory getSymbol) {
        _name = getName;
        _symbol = getSymbol;
        _decimals = 18;
        _totalSupply = 100000000e18;
        _balances[msg.sender] = _totalSupply;
        _tokenLock = true;
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
        //interface에서 정의된 함수 이외에 추가적인 기능을 가진 function을 추가할 수 있으나, gas비가 상승한다.
        emit Transfer(msg.sender, sender, recipient, amount);//transfer event 발생
        uint256 currentAllowance = _allowances[sender][msg.sender];//sender가 transaction 발생자에게 예치한 token 수량 저장하는 변수
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");//총량 비교
        _approve(sender, msg.sender, currentAllowance, currentAllowance - amount);//빠져나가는 만큼 갱신
        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(isTokenLock(sender, recipient) == false, "TokenLock: invalid token transfer");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance.sub(amount);
        _balances[recipient].add(amount);
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

    function isTokenLock(address from, address to) public view returns (bool lock) {
        lock = false;

        if(_tokenLock == true)
        {
             lock = true;
        }

        if(_personalTokenLock[from] == true || _personalTokenLock[to] == true) {
             lock = true;
        }
    }

    function removeTokenLock() onlyOwner public {
        require(_tokenLock == true);
        _tokenLock = false;
    }

    function removePersonalTokenLock(address _who) onlyOwner public {
        require(_personalTokenLock[_who] == true);
        _personalTokenLock[_who] = false;
    }
}