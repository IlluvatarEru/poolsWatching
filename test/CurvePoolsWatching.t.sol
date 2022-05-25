// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.13;

import "ds-test/test.sol";
import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../src/CurvePoolsWatching.sol";

contract CurvePoolsWatchingTest is Test {
    PriceAndSlippageComputerContract priceAndSlippageComputer;
    address curvePoolAddressBUSD = 0x79a8C46DeA5aDa233ABaFFD40F3A0A2B1e5A4F27;
    address curvePoolAddress3Pool =0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;
    
    function setUp() public {
        priceAndSlippageComputer = new PriceAndSlippageComputerContract(curvePoolAddress3Pool);
    }

    function testAddressIsSetup() public {
        address setAddress = priceAndSlippageComputer.getCurvePoolContractAddress();
        assertTrue(setAddress==curvePoolAddress3Pool);
    }

    function testGetVirtualPriceForPool() public {
        uint256 p = priceAndSlippageComputer.getVirtualPriceForPool("Curve","BUSD");
        console.log("price", p);
        assertTrue(p>0);
    }

    function testComputePriceAndSlippage() public {
        console.log("address",priceAndSlippageComputer.getCurvePoolContractAddress());
        if(priceAndSlippageComputer.getCurvePoolContractAddress()==curvePoolAddressBUSD){
            string[4] memory ttt = ["DAI","USDC","USDT","BUSD"];
            string memory tokenTo = "BUSD";
            string memory tokenFrom;
            uint price;
            uint priceWithFee;
            uint slippage;
            for(uint8 i=0;i<4;++i){
                tokenFrom = ttt[i];
                price = priceAndSlippageComputer.computePrice(tokenFrom,tokenTo);
                priceWithFee = priceAndSlippageComputer.computePriceWithFee(tokenFrom,tokenTo);
                slippage = priceAndSlippageComputer.computeSlippage(tokenFrom,tokenTo);
                console.log("---------------");
                console.log("Looking at swap from ", tokenFrom,"to",tokenTo);
                console.log("Rate 1",tokenFrom, "to BUSD without fee", price);
                console.log("Rate 1",tokenFrom, "to BUSD with fee", priceWithFee);
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
            tokenFrom = tokens[0];
            price = priceAndSlippageComputer.computePrice(tokenFrom,tokenTo);
            console.log("---------------");
            console.log("Looking at swap from ", tokenFrom,"to",tokenTo);
            console.log("Rate 1",tokenFrom, "to BUSD without fee", price);
            assertTrue(price>0);
        }
    }

}
