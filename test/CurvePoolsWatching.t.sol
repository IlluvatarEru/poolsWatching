// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.13;

import "ds-test/test.sol";
import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../src/CurvePoolsWatching.sol";

contract CurvePoolsWatchingTest is Test {
    PriceAndSlippageComputerContract priceAndSlippageComputer;
    address curvePoolAddress = 0x3B3Ac5386837Dc563660FB6a0937DFAa5924333B;
    
    function setUp() public {
        priceAndSlippageComputer = new PriceAndSlippageComputerContract("Arthur");
    }

    function testNameIsArthur() public {
        assertTrue(keccak256(abi.encodePacked(priceAndSlippageComputer.getOwnerName())) == keccak256("Arthur"));
    }

    function testSettingUpAddress() public {
        priceAndSlippageComputer.setCurvePoolContractAddress(curvePoolAddress);
        address setAddress = priceAndSlippageComputer.getCurvePoolContractAddress();
        assertTrue(setAddress==curvePoolAddress);
    }

    function testCanGetPrice() public {
        priceAndSlippageComputer.setCurvePoolContractAddress(curvePoolAddress);
        uint256 p = priceAndSlippageComputer.getPrice();
        assertTrue(p>0);
    }

// forge test --fork-url http://rpcdaemon.erigon.dappnode:8545
}
