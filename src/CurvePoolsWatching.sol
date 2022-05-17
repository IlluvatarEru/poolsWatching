// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.13;

interface IStableSwap {
    function balances(uint i) external view returns (uint);
    function get_virtual_price() external returns (uint256);
}

contract PriceAndSlippageComputerContract {
    address owner;
    string ownerName;
    IStableSwap public stableSwap;
    // for each AMM there are different pairs
    mapping (string => mapping (string => address)) public pools;

    constructor(string memory _name){
        owner=msg.sender;
        ownerName=_name;
        pools["Curve"]["BUSD"] = 0x79a8C46DeA5aDa233ABaFFD40F3A0A2B1e5A4F27;
    }
    
    function getBalance(uint ind) public view returns(uint256){
        return stableSwap.balances(ind);
    }

    function getOwnerName() public view returns(string memory) {
        return ownerName;
    }


    function setCurvePoolContractAddress(address _address) public {
        stableSwap = IStableSwap(_address);
    }

    function getCurvePoolContractAddress() public view returns(address) {
        return address(stableSwap);
    }

    function getPrice() public returns(uint256){
        return stableSwap.get_virtual_price();
    }

    function getPriceForPoolAndPair(string memory pool, string memory pair) public returns(uint256) {
        require((keccak256(abi.encodePacked(pool)))==keccak256("Curve"));
        address poolAddress = pools[pool][pair];
        setCurvePoolContractAddress(poolAddress);
        return stableSwap.get_virtual_price();
    }

}