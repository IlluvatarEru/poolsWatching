// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.13;

import "ds-test/test.sol";
import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../src/CurvePoolsWatching.sol";

contract CurvePoolsWatchingTest is Test {
    PriceAndSlippageComputerContract priceAndSlippageComputer;
    address curvePoolAddress = 0x79a8C46DeA5aDa233ABaFFD40F3A0A2B1e5A4F27;
    
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
        console.log("price", p);
        assertTrue(p>0);
    }

    function testGetBalances() public {
        priceAndSlippageComputer.setCurvePoolContractAddress(curvePoolAddress);
        uint256 b = priceAndSlippageComputer.getBalance(0);
        console.log("balance:", b);
        assert(b>0);
    }
    function testGetPriceForPoolAndPair() public {
        uint256 p = priceAndSlippageComputer.getPriceForPoolAndPair("Curve","BUSD");
        console.log("price", p);
        assertTrue(p>0);
    }

// forge test --fork-url http://rpcdaemon.erigon.dappnode:8545
}