// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.10;

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


//contract안에서 "using SafeMath for uint256;"라고 명시하는 것으로, uint256자료형에 대해 해당 libary안의 함수를 사용할 수 있다는 것을 명시해줘야 사용할 수 있다.
//ex. uint256 currentAllowance; uint256 amount;
//    currentAllowance - amount; => currentAllowance.sub(amount);로 바꿔 쓸 수 있다.