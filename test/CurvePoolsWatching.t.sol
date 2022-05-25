// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.13;

import "ds-test/test.sol";
import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../src/CurvePoolsWatching.sol";

contract CurvePoolsWatchingTest is Test {
    PriceAndSlippageComputerContract priceAndSlippageComputer;
    
    function setUp() public {
        // Change the address to test other pools
        priceAndSlippageComputer = new PriceAndSlippageComputerContract(curvePoolAddress3Pool);
    }

    function testAddressIsSetup() public {
        address setAddress = priceAndSlippageComputer.getCurvePoolContractAddress();
        assertTrue(setAddress==curvePoolAddressBUSD || setAddress==curvePoolAddress3Pool);
    }

    function testGetVirtualPriceForPool() public {
        uint256 p = priceAndSlippageComputer.getVirtualPriceForPool("Curve");
        console.log("price", p);
        assertTrue(p>0);
    }

    function testComputePriceAndSlippage() public {
        console.log("address",priceAndSlippageComputer.getCurvePoolContractAddress());
        if(priceAndSlippageComputer.getCurvePoolContractAddress()==curvePoolAddressBUSD){
            string[4] memory tokens = ["DAI","USDC","USDT","BUSD"];
            string memory tokenTo = "BUSD";
            string memory tokenFrom;
            uint price;
            uint priceWithFee;
            uint slippage;
            for(uint8 i=0;i<4;++i){
                tokenFrom = tokens[i];
                price = priceAndSlippageComputer.computePrice(tokenFrom,tokenTo);
                priceWithFee = priceAndSlippageComputer.computePriceWithFee(tokenFrom,tokenTo);
                slippage = priceAndSlippageComputer.computeSlippage(tokenFrom,tokenTo);
                console.log("---------------");
                console.log("Looking at swap from ", tokenFrom,"to",tokenTo);
                console.log("Rate without fee", price);
                console.log("Rate with fee", priceWithFee);
                console.log("Slippage", slippage);
                assertTrue(price>priceWithFee);
            }
        }else if(priceAndSlippageComputer.getCurvePoolContractAddress()==curvePoolAddress3Pool){
            string[3] memory tokens = ["DAI","USDC","USDT"];
            string memory tokenTo = "USDT";
            string memory tokenFrom;
            uint price;
            uint priceWithFee;
            uint slippage;
            for(uint8 i=0;i<3;++i){
                tokenFrom = tokens[i];
                price = priceAndSlippageComputer.computePrice(tokenFrom,tokenTo);
                priceWithFee = priceAndSlippageComputer.computePriceWithFee(tokenFrom,tokenTo);
                slippage = priceAndSlippageComputer.computeSlippage(tokenFrom,tokenTo);
                console.log("---------------");
                console.log("Looking at swap from ", tokenFrom,"to",tokenTo);
                console.log("Rate without fee", price);
                console.log("Rate with fee", priceWithFee);
                console.log("Slippage", slippage);
                assertTrue(price>priceWithFee);
            }
        }
    }

}
