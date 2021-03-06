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
        priceAndSlippageComputer = new PriceAndSlippageComputerContract(curvePoolAddressStETH);
    }

    function testAddressIsSetup() public {
        address curvePool = priceAndSlippageComputer.getCurvePoolContractAddress();
        assertTrue(
            curvePool==curvePoolAddressBUSD || 
            curvePool==curvePoolAddress3Pool || 
            curvePool==curvePoolAddressUSDT ||
            curvePool==curvePoolAddressAAVE ||
            curvePool==curvePoolAddressEURS ||
            curvePool==curvePoolAddressSUSD ||
            curvePool==curvePoolAddressAETH ||
            curvePool==curvePoolAddressCompound ||
            curvePool==curvePoolAddressLINK ||
            curvePool==curvePoolAddressSETH ||
            curvePool==curvePoolAddressStETH
        );
    }

    function testGetVirtualPriceForPool() public {
        uint256 p = priceAndSlippageComputer.getVirtualPriceForPool("Curve");
        console.log("Virtual Price", p);
        assertTrue(p>0);
    }

    function testComputePriceAndSlippageBUSD() public {
        priceAndSlippageComputer = new PriceAndSlippageComputerContract(curvePoolAddressBUSD);
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
    }

    function testComputePriceAndSlippage3Pool() public {
        priceAndSlippageComputer = new PriceAndSlippageComputerContract(curvePoolAddress3Pool);
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

    function testComputePriceAndSlippageAAVE() public {
        priceAndSlippageComputer = new PriceAndSlippageComputerContract(curvePoolAddressAAVE);
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

    function testComputePriceAndSlippageUSDT() public {
        priceAndSlippageComputer = new PriceAndSlippageComputerContract(curvePoolAddressUSDT);
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

    function testComputePriceAndSlippageEURS() public {
        priceAndSlippageComputer = new PriceAndSlippageComputerContract(curvePoolAddressEURS);
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
    }

    function testComputePriceAndSlippageSUSD() public {
        priceAndSlippageComputer = new PriceAndSlippageComputerContract(curvePoolAddressSUSD);
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
    }

    function testComputePriceAndSlippageAETH() public {
        priceAndSlippageComputer = new PriceAndSlippageComputerContract(curvePoolAddressAETH);
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
    }

    function testComputePriceAndSlippageCompound() public {
        priceAndSlippageComputer = new PriceAndSlippageComputerContract(curvePoolAddressCompound);
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

    function testComputePriceAndSlippageLINK() public {
        priceAndSlippageComputer = new PriceAndSlippageComputerContract(curvePoolAddressLINK);
        string[2] memory tokens = ["LINK","sLINK"];
        string memory tokenTo = "sLINK";
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

    function testComputePriceAndSlippageSSETH() public {
        priceAndSlippageComputer = new PriceAndSlippageComputerContract(curvePoolAddressSETH);
        string[2] memory tokens = ["ETH","sETH"];
        string memory tokenTo = "sETH";
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

    function testComputePriceAndSlippageStETH() public {
        priceAndSlippageComputer = new PriceAndSlippageComputerContract(curvePoolAddressStETH);
        string[2] memory tokens = ["ETH","stETH"];
        string memory tokenTo = "stETH";
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

    function testComputePriceAndSlippageSAAVE() public {
        priceAndSlippageComputer = new PriceAndSlippageComputerContract(curvePoolAddressSAAVE);
        string[2] memory tokens = ["DAI","sUSD"];
        string memory tokenTo = "sUSD";
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
