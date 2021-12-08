// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.10;


abstract contract OwnerHelper {
  	address private _owner;

  	event OwnershipTransferred(address indexed preOwner, address indexed nextOwner);

  	modifier onlyOwner {
		require(msg.sender == _owner, "OwnerHelper: caller is not owner");
		_;
  	}

  	constructor() {
		_owner = msg.sender;
  	}

       function owner() public view virtual returns (address) {
              return _owner;
       }

  	function transferOwnership(address newOwner) onlyOwner public {
              require(newOwner != _owner);
              require(newOwner != address(0x0));
              _owner = newOwner;
              emit OwnershipTransferred(_owner, newOwner);
  	}
}

contract SimpleToken is  OwnerHelper {
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
        //관리자 주소일때만 실행 가능
        //토큰 전체에 대해 lock관리
        require(_tokenLock == true);
        _tokenLock = false;//lock 해제
    }

    function removePersonalTokenLock(address _who) onlyOwner public {
        //관리자 주소일때만 실행 가능
        //해당 계정이 소유한 토큰에 대해 lock관리
        require(_personalTokenLock[_who] == true);
        _personalTokenLock[_who] = false;
    }
}