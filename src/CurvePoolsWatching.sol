// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.13;

abstract contract CurvePoolInterface {
    function get_virtual_price() virtual external returns (uint256);
}

interface IStableSwapBUSD {
    function get_virtual_price() external returns (uint256);
}

contract PriceAndSlippageComputerContract {
    address owner;
    string ownerName;
    IStableSwapBUSD public stableSwapBUSD;
    constructor(string memory _name){
        owner=msg.sender;
        ownerName=_name;
    }
    
    function getOwnerName() public view returns(string memory) {
        return ownerName;
    }


    function setCurvePoolContractAddress(address _address) external {
        stableSwapBUSD = IStableSwapBUSD(_address);
    }

    function getCurvePoolContractAddress() public view returns(address) {
        return address(stableSwapBUSD);
    }

    function getPrice() public returns(uint256){
        return stableSwapBUSD.get_virtual_price();
    }

}