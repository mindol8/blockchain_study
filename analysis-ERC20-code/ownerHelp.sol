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
        _owner = newOwner;//갱신
        emit OwnershipTransferred(_owner, newOwner);//이전, 갱신 관리자 주소 로그
  	}
}
