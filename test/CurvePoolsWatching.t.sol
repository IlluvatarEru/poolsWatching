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

    function testGetIndex() public {
        priceAndSlippageComputer.setCurvePoolContractAddress(curvePoolAddress);
        uint daiIndex = priceAndSlippageComputer.getIndexOfToken("DAI");
        assert(daiIndex == 0);
    }

    function testGetBalances() public {
        priceAndSlippageComputer.setCurvePoolContractAddress(curvePoolAddress);
        uint256 b = priceAndSlippageComputer.getBalance(0);
        console.log("balance:", b);
        assert(b>0);
        uint256 bDAI = priceAndSlippageComputer.getBalanceOfToken("DAI");
        assert(b==bDAI);
    }

    function testGetCoin() public {
        priceAndSlippageComputer.setCurvePoolContractAddress(curvePoolAddress);
        address b = priceAndSlippageComputer.getCoin(0);
        console.log("Coin Address:", b);
        assert(b==0xC2cB1040220768554cf699b0d863A3cd4324ce32);
    }

    function testGetUnderlyingCoin() public {
        priceAndSlippageComputer.setCurvePoolContractAddress(curvePoolAddress);
        address b = priceAndSlippageComputer.getUnderlyingCoin(0);
        console.log("Underlying Coin Address:", b);
        assert(b==0x6B175474E89094C44Da98b954EedeAC495271d0F);
    }

    function testGetVirtualPriceForPool() public {
        uint256 p = priceAndSlippageComputer.getVirtualPriceForPool("Curve","BUSD");
        console.log("price", p);
        assertTrue(p>0);
    }
    function testAmplificationFactor() public {
        priceAndSlippageComputer.setCurvePoolContractAddress(curvePoolAddress);
        uint a = priceAndSlippageComputer.getAmplificationFactor();
        console.log("A",a);
        assertTrue(a>0);
    }

    function testBalanceRates() public {
        priceAndSlippageComputer.setCurvePoolContractAddress(curvePoolAddress);
        uint256[4] memory rates = priceAndSlippageComputer.stored_rates();
        uint256[4] memory xps = priceAndSlippageComputer._xp(rates);
        string[4] memory ttt = ["DAI","USDC","USDT","BUSD"];

        string memory tokenTo = "BUSD";
        string memory tokenFrom;
        uint price;
        uint priceWithFee;
        for(uint256 i=0;i<4;++i){
            tokenFrom = ttt[i];
            price = priceAndSlippageComputer.computePrice(tokenFrom,tokenTo);
            priceWithFee = priceAndSlippageComputer.computePriceWithFee(tokenFrom,tokenTo);
            console.log("---------------");
            console.log("Looking at swap from ", tokenFrom,"to",tokenTo);
            console.log("Rate 1",tokenFrom, "to BUSD without fee", price);
            console.log("Rate 1",tokenFrom, "to BUSD with fee", priceWithFee);
            assertTrue(price>priceWithFee);
        }        
    }

//openvpn3 session-start --config ~/Downloads/dappnode.ovpn

// forge test --fork-url http://rpcdaemon.erigon.dappnode:8545

// forge test --fork-url http://rpcdaemon.erigon.dappnode:8545 -vvvv --match-test testP


}
