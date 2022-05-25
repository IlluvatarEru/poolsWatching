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
        priceAndSlippageComputer = new PriceAndSlippageComputerContract();
        priceAndSlippageComputer.setCurvePoolContractAddress(curvePoolAddress);
    }


    function testSettingUpAddress() public {
        address setAddress = priceAndSlippageComputer.getCurvePoolContractAddress();
        assertTrue(setAddress==curvePoolAddress);
    }

    function testGetIndex() public {
        uint daiIndex = priceAndSlippageComputer.getIndexOfToken("DAI");
        assert(daiIndex == 0);
    }

    function testGetUnderlyingCoin() public {
        address b = priceAndSlippageComputer.getUnderlyingCoin(0);
        console.log("Underlying Coin Address:", b);
        assert(b==0x6B175474E89094C44Da98b954EedeAC495271d0F);
    }

    function testGetVirtualPriceForPool() public {
        uint256 p = priceAndSlippageComputer.getVirtualPriceForPool("Curve","BUSD");
        console.log("price", p);
        assertTrue(p>0);
    }

    function testBalanceRates() public {
        string[4] memory ttt = ["DAI","USDC","USDT","BUSD"];

        string memory tokenTo = "BUSD";
        string memory tokenFrom;
        uint price;
        uint priceWithFee;
        uint slippage;
        for(uint256 i=0;i<4;++i){
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
    }

}
