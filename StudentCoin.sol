// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

pragma solidity ^0.8.0;

contract StudentCoin {
    address public owner;
    string public contractName;

    address[] private admins;

    struct CoinStruct {
        uint totalCoins;
    }

    mapping(string => CoinStruct) public studentCoinMap;

    string[] public studentsInSystem;

    constructor(string memory argContractName) {
        owner = msg.sender;
        contractName = argContractName;
    }

    // ~~~~~~~~~~~~~~~~~~~ UTIL FUNCTIONS (PRIVATE) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    modifier onlyOwnerOrAdmin() {
        require(msg.sender == owner || isAdmin(msg.sender), "Not authorized");
        _;
    }

    function isAdmin(address account) internal view returns (bool) {
        for (uint i = 0; i < admins.length; i++) {
            if (admins[i] == account) {
                return true;
            }
        }
        return false;
    }

    function toLower(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        for (uint i = 0; i < bStr.length; i++) {
            if (uint8(bStr[i]) >= 65 && uint8(bStr[i]) <= 90) {
                bStr[i] = bytes1(uint8(bStr[i]) + 32);
            }
        }
        return string(bStr);
    }
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    function getStudentPoints(string memory studentName) public view returns (CoinStruct memory) {
        string memory lowercaseStudentName = toLower(studentName);
        require(studentExists(lowercaseStudentName), "Student does not exist");
        return studentCoinMap[lowercaseStudentName];
    }

    function studentExists(string memory studentName) internal view returns (bool) {
        return studentCoinMap[toLower(studentName)].totalCoins > 0;
    }

    function addAdmin(address newAdminAddress) public onlyOwnerOrAdmin {
        require(!isAdmin(newAdminAddress), "Address is already an admin");
        admins.push(newAdminAddress);
    }

    function awardStudentPoints(string memory studentName, uint numberOfCoins) public onlyOwnerOrAdmin {
        require(numberOfCoins > 0, "Number of coins must be greater than 0");
        string memory lowercaseStudentName = toLower(studentName);

        if (!studentExists(lowercaseStudentName)) {
            studentsInSystem.push(lowercaseStudentName);
        }

        studentCoinMap[lowercaseStudentName].totalCoins += numberOfCoins;
    }

    function studentPurchase(string memory studentName, uint numberOfCoins) public onlyOwnerOrAdmin{
        string memory lowercaseStudentName = toLower(studentName);
        require(studentCoinMap[lowercaseStudentName].totalCoins >= numberOfCoins, "Insufficient current coins");

        studentCoinMap[lowercaseStudentName].totalCoins -= numberOfCoins;
    }

    function getStudentLeaderboard() public view returns (string[] memory, uint[] memory) {
        uint len = studentsInSystem.length;

        string[] memory studentNames = new string[](len);
        uint[] memory totalCoins = new uint[](len);

        for (uint i = 0; i < len; i++) {
            studentNames[i] = studentsInSystem[i];
            totalCoins[i] = studentCoinMap[studentsInSystem[i]].totalCoins;
        }

        return (studentNames, totalCoins);
    }

}