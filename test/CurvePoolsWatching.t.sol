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
        priceAndSlippageComputer = new PriceAndSlippageComputerContract(curvePoolAddressCompound);
    }

    function testAddressIsSetup() public {
        address curvePool = priceAndSlippageComputer.getCurvePoolContractAddress();
        assertTrue(curvePool==curvePoolAddressBUSD || 
        curvePool==curvePoolAddress3Pool || 
        curvePool==curvePoolAddressUSDT ||
        curvePool==curvePoolAddressAAVE ||
        curvePool==curvePoolAddressEURS ||
        curvePool==curvePoolAddressSUSD ||
        curvePool==curvePoolAddressAETH ||
        curvePool==curvePoolAddressCompound
        );
    }

    function testGetVirtualPriceForPool() public {
        uint256 p = priceAndSlippageComputer.getVirtualPriceForPool("Curve");
        console.log("Virtual Price", p);
        assertTrue(p>0);
    }

    function testComputePriceAndSlippage() public {
        address curvePool = priceAndSlippageComputer.getCurvePoolContractAddress();
        console.log("address",curvePool);
        if(curvePool==curvePoolAddressBUSD){
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
        }else if(curvePool==curvePoolAddress3Pool || 
        curvePool==curvePoolAddressUSDT || 
        curvePool==curvePoolAddressAAVE){
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
        }else if(curvePool==curvePoolAddressEURS){
            string[2] memory tokens = ["EURS","sEUR"];
            string memory tokenTo = "EURS";
            string memory tokenFrom;
            uint price;
            uint priceWithFee;
            uint slippage;
            for(uint8 i=0;i<2;++i){
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
        }else if(curvePool==curvePoolAddressSUSD){
            string[4] memory tokens = ["sUSD", "DAI","USDC","USDT"];
            string memory tokenTo = "USDC";
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
        }else if(curvePool==curvePoolAddressAETH){
            string[2] memory tokens = ["ETH","aETH"];
            string memory tokenTo = "aETH";
            string memory tokenFrom;
            uint price;
            uint priceWithFee;
            uint slippage;
            for(uint8 i=0;i<2;++i){
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
        }else if(curvePool==curvePoolAddressCompound){
            string[2] memory tokens = ["DAI","USDC"];
            string memory tokenTo = "DAI";
            string memory tokenFrom;
            uint price;
            uint priceWithFee;
            uint slippage;
            for(uint8 i=0;i<2;++i){
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
