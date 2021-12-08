// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.10;

//issuer = vc 발급자
//holder = 발급받은 vc를 가지고 있는 주체
abstract contract OwnerHelper {
    address private owner;

    event OwnerTransferPropose(address indexed _from, address indexed _to);

    modifier onlyOwner() {
        require(msg.sender == owner); //권한 검사
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address _to) public onlyOwner {
        //owner 전환
        require(_to != owner); //이전 owner과 같은지 검사
        require(_to != address(0x0)); // 주소 유효성 검사
        owner = _to; //갱신
        emit OwnerTransferPropose(owner, _to); //event 발생
    }
}

abstract contract IssuerHelper is OwnerHelper {
    //OwnerHelper 상속
    mapping(address => bool) public issuers;

    event AddIssuer(address indexed _issuer);
    event DelIssuer(address indexed _issuer);

    modifier onlyIssuer() {
        require(isIssuer(msg.sender) == true);
        _;
    }

    constructor() {
        issuers[msg.sender] = true; //issuers 등록 => contract 호출하는 대상은 항상 isser이다.
    }

    function isIssuer(address _addr) public view returns (bool) {
        //등록되어 있는 issuer인지 검사
        return issuers[_addr];
    }

    function addIssuer(address _addr) public onlyOwner returns (bool) {
        //issuer 추가
        require(issuers[_addr] == false);
        //require은 해당 조건이 참이면 내려오고 거짓이면 error 발생
        
        issuers[_addr] = true;
        emit AddIssuer(_addr);
        return true;
    }

    function delIssuer(address _addr) public onlyOwner returns (bool) {
        require(issuers[_addr] == true);
        //해당 주소가 이미 issuer이면 issuers[_addr] == true이고, require를 통과하지 못한다.
        //조건이 == true여야 하는게 아닐까?
        issuers[_addr] = false;
        emit DelIssuer(_addr);
        return true;
    }
}

contract CredentialBox is IssuerHelper {
    //issuer 정보 및 갱신 contract 상속
    uint256 private idCount;
    mapping(uint8 => string) private alumniEnum;
    mapping(uint8 => string) private statusEnum;

    struct Credential {
        uint256 id;
        address issuer; //issuer 정보
        uint8 alumniType; //증명서 타입
        uint8 statusType; //사용자의 상태 타입
        string value;
        uint256 createDate; //생성 시간
    }

    mapping(address => Credential) private credentials;

    constructor() {
        idCount = 1;
        alumniEnum[0] = "SEB";
        alumniEnum[1] = "BEB";
        alumniEnum[2] = "AIB";
    }

    function claimCredential(
        address _alumniAddress,
        uint8 _alumniType,
        string calldata _value
    ) public onlyIssuer returns (bool) {
        Credential storage credential = credentials[_alumniAddress];
        require(credential.id == 0);
        credential.id = idCount;
        credential.issuer = msg.sender;
        credential.alumniType = _alumniType;
        credential.statusType = 0;
        credential.value = _value;
        credential.createDate = block.timestamp;

        idCount += 1;

        return true;
    }

    function getCredential(address _alumniAddress)
        public
        view
        returns (Credential memory)
    {
        return credentials[_alumniAddress];
    }

    function addAlumniType(uint8 _type, string calldata _value)
        public
        onlyIssuer
        returns (bool)
    {
        //증명서 type 추가
        require(bytes(alumniEnum[_type]).length == 0); //해당 번호로 등록되어 있는 증명서가 없는 경우에만 작동
        //솔리디티 내부에서는 String을 검사하는 방법이 두가지가 존재합니다.
        //첫번째는 bytes로 변환하여 길이로 null인지 검사하는 방법,
        //두번째는 keccak256 함수를 사용하여 두 스트링을 해쉬로 변환하여 비교하는 방법입니다.
        // 해당 require에서는 첫번째 방법 사용
        alumniEnum[_type] = _value; //등록
        return true;
    }

    function getAlumniType(uint8 _type) public view returns (string memory) {
        //번호와 매칭되는 증명서 return
        return alumniEnum[_type];
    }

    function addStatusType(uint8 _type, string calldata _value)
        public
        onlyIssuer
        returns (bool)
    {
        //사용자의 상태 정보 추가
        require(bytes(statusEnum[_type]).length == 0);
        statusEnum[_type] = _value;
        return true;
    }

    function getStatusType(uint8 _type) public view returns (string memory) {
        //상태정보 getter
        return statusEnum[_type];
    }

    function changeStatus(address _alumni, uint8 _type)
        public
        onlyIssuer
        returns (bool)
    {
        //사용자의 상태 갱신
        require(credentials[_alumni].id != 0); //id 유효성 검사
        require(bytes(statusEnum[_type]).length != 0); //해당 번호에 해당하는 상태가 있어야 한다.
        credentials[_alumni].statusType = _type; //갱신
        return true;
    }
}