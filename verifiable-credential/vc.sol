// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.10;

contract CredentialBox {
    address private issuerAddress;
    uint256 private idCount;
    mapping(uint8 => string) private alumniEnum;

    struct Credential {
        uint256 id;
        address issuer;
        uint8 alumniType; //증명서 type
        string value; //크리덴셜에 포함되어야하는 암호화된 정보.
        //중앙화된 서버에서 제공하는 신원, 신원 제공자, 엔터티, 서명 등이 JSON 형태로 저장
    }

    mapping(address => Credential) private credentials;

    constructor() {
        issuerAddress = msg.sender;
        idCount = 1;
        alumniEnum[0] = "SEB";
        alumniEnum[1] = "BEB";
        alumniEnum[2] = "AIB";
    }

    function claimCredential(
        //발급자(issuer)는 어떠한 주체(_alumniAddress)에게 크리덴셜(Credential)을 발행(claim)
        address _alumniAddress, //credential을 발급받을 네트워크 주소
        uint8 _alumniType, //증명서 type
        string calldata _value // calldata = 수 인자가 저장되고 수정 불가능하며 지속성x. 외부 함수의 함수 매개변수는 calldata에 강제 저장되며 memory처럼 사용됨
    ) public returns (bool) {
        require(issuerAddress == msg.sender, "Not Issuer"); //issuer 유효성 검사
        Credential storage credential = credentials[_alumniAddress];
        //우측의 형태가 사용하기 번거롭기 때문에 다른 저장소를 활용 => 메모리를 조금 더 사용한다.
        //지역 변수의 default = storage, 상태변수는 storage로 강제되어 있다.
        require(credential.id == 0); //credential id 유효성 검사 => 처음 들어가는 것이기 때문에 id 값이 0이어야 한다.
        credential.id = idCount;
        credential.issuer = msg.sender;
        credential.alumniType = _alumniType;
        credential.value = _value;

        idCount += 1;
        // 데이터 갱신
        return true;
    }

    function getCredential(address _alumniAddress)
        public
        view
        returns (Credential memory)
    {
        return credentials[_alumniAddress];
        //해당 주소에 대한 VC return
    }
}