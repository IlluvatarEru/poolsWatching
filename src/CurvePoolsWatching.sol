// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.13;

interface IStableSwap {
    function coins(int128 i) external view returns (address);
    function coins(uint256 i) external view returns (address);
    function underlying_coins(int128 i) external view returns (address);
    function underlying_coins(uint256 i) external view returns (address);
    function balances(int128 i) external view returns (uint);
    function balances(uint256 i) external view returns (uint);
    function get_virtual_price() external returns (uint256);
    function A() external view returns (uint256);
    function fee() external view returns (uint256);
}

interface yERC20 {
    function totalSupply() external returns (uint256);
    function allowance(address _owner,address _spender) external returns (uint256);
    function transfer(address _to,uint256 _value) external returns (bool);
    function transferFrom(address _from,address _to,uint256  _value) external returns (bool);
    function approve(address _spender,uint256 _value) external returns (bool);
    function name() external returns (string memory);
    function symbol() external returns (string memory);
    function decimals() external returns (uint256);
    function balanceOf(address arg0) external returns (uint256);
    function getPricePerFullShare() external returns (uint256);
}

interface cERC20 {
    function supplyRatePerBlock() external returns (uint256);
    function accrualBlockNumber() external returns (uint256);
    function exchangeRateStored() external returns (uint256);
}

interface aETH {
    function ratio() external returns(uint256);
}

// Handled pools
address constant curvePoolAddressBUSD = 0x79a8C46DeA5aDa233ABaFFD40F3A0A2B1e5A4F27;
address constant curvePoolAddress3Pool = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;
address constant curvePoolAddressUSDT = 0x52EA46506B9CC5Ef470C5bf89f17Dc28bB35D85C;
address constant curvePoolAddressAAVE = 0xDeBF20617708857ebe4F679508E7b7863a8A8EeE;
address constant curvePoolAddressEURS = 0x0Ce6a5fF5217e38315f87032CF90686C96627CAA;
address constant curvePoolAddressSUSD = 0xA5407eAE9Ba41422680e2e00537571bcC53efBfD;
address constant curvePoolAddressAETH = 0xA96A65c051bF88B4095Ee1f2451C2A9d43F53Ae2;
address constant curvePoolAddressCompound = 0xA2B47E3D5c44877cca798226B7B8118F9BFb7A56;
address constant curvePoolAddressLINK = 0xF178C0b5Bb7e7aBF4e12A4838C7b7c5bA2C623c0;
address constant curvePoolAddressSETH = 0xc5424B857f758E906013F3555Dad202e4bdB4567;
address constant curvePoolAddressStETH = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;
address constant curvePoolAddressSAAVE = 0xEB16Ae0052ed37f479f7fe63849198Df1765a733;


//TODO: Handle the below stable swaps
address constant curvePoolAddressHBTC = 0x4CA9b3063Ec5866A4B82E437059D2C43d1be596F;
address constant curvePoolAddressIB = 0x2dded6Da1BF5DBdF597C45fcFaa3194e53EcfeAF;
address constant curvePoolAddressPax = 0x06364f10B501e868329afBc005b3492902d6C763;
address constant curvePoolAddressRen = 0x93054188d876f558f4a66B2EF1d97d16eDf0895B;
address constant curvePoolAddressSBTC = 0x7fC77b5c7614E1533320Ea6DDc2Eb61fa00A9714;
address constant curvePoolAddressY = 0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51;
address constant curvePoolAddressYv2 = 0x8925D9d9B4569D737a48499DeF3f67BaA5a144b9;


contract PriceAndSlippageComputerContract {
    address internal owner;
    IStableSwap internal stableSwap;
    uint256 internal PRECISION;
    uint256 internal FEE_DENOMINATOR;
    uint256 internal N_COINS;
    uint256 internal LENDING_PRECISION;
    uint256[] internal PRECISION_MUL;
    bool[] internal USE_LENDING;
    

    constructor(address curvePool){
        owner=msg.sender;
        setCurvePoolContractAddress(curvePool);
        setUpVariables();
    }

    function setUpVariables() internal {
        address curvePool = getCurvePoolContractAddress();
        if(curvePool==curvePoolAddressBUSD || curvePool==curvePoolAddressSUSD){
            N_COINS = 4;
            PRECISION = 10 ** 18;
            FEE_DENOMINATOR = 10 ** 10;
            PRECISION_MUL = [uint256(1), uint256(1000000000000), uint256(1000000000000), uint256(1)];
            USE_LENDING =[false, false, false,false];
        }else if(
            curvePool==curvePoolAddress3Pool || 
            curvePool==curvePoolAddressUSDT || 
            curvePool==curvePoolAddressAAVE
        ){
            N_COINS = 3;
            PRECISION = 10 ** 18;
            FEE_DENOMINATOR = 10 ** 10;
            PRECISION_MUL = [1, 1000000000000, 1000000000000];
            USE_LENDING =[true, true, false];
        } else if(curvePool==curvePoolAddressEURS ||
                    curvePool==curvePoolAddressAETH ||
                    curvePool==curvePoolAddressSETH){
            N_COINS = 2;
            PRECISION = 10 ** 18;
            FEE_DENOMINATOR = 10 ** 10;
            PRECISION_MUL = [1000000000000, 1];
            LENDING_PRECISION = 10 ** 18;
        }else if(curvePool==curvePoolAddressCompound){
            N_COINS = 2;
            PRECISION = 10 ** 18;
            FEE_DENOMINATOR = 10 ** 10;
            PRECISION_MUL = [1, 1000000000000];
            LENDING_PRECISION = 10 ** 18;
            USE_LENDING =[true, true];
        }else if(curvePool==curvePoolAddressLINK){
            N_COINS = 2;
            PRECISION = 10 ** 18;
            FEE_DENOMINATOR = 10 ** 10;
            PRECISION_MUL = [1, 1000000000000];
        }else if(curvePool==curvePoolAddressStETH){
            N_COINS = 2;
            PRECISION = 10 ** 18;
            FEE_DENOMINATOR = 10 ** 10;
        }else if(curvePool==curvePoolAddressSAAVE){
            N_COINS = 2;
            PRECISION = 10 ** 18;
            FEE_DENOMINATOR = 10 ** 10;
            PRECISION_MUL = [1000000000000, 1];
        }else{
            revert("Cannot setup variables, address not supported.");
        }
    }

    function setCurvePoolContractAddress(address _address) internal {
        stableSwap = IStableSwap(_address);
    }

    function getAddressOfToken(string memory token) internal pure returns (address){
        bytes32 tokenHash = keccak256(bytes(token));
        if(tokenHash==keccak256(bytes("DAI"))){
            return 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        } else if(tokenHash==keccak256(bytes("USDC"))){
            return 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        }else if(tokenHash==keccak256(bytes("USDT"))){
            return 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        }else if(tokenHash==keccak256(bytes("BUSD"))){
            return 0x4Fabb145d64652a948d72533023f6E7A623C7C53;
        }else if(tokenHash==keccak256(bytes("EURS"))){
            return 0xdB25f211AB05b1c97D595516F45794528a807ad8;
        }else if(tokenHash==keccak256(bytes("sEUR"))){
            return 0xD71eCFF9342A5Ced620049e616c5035F1dB98620;
        }else if(tokenHash==keccak256(bytes("sUSD"))){
            return 0x57Ab1ec28D129707052df4dF418D58a2D46d5f51;
        }else if(tokenHash==keccak256(bytes("aETH"))){
            return 0xE95A203B1a91a908F9B9CE46459d101078c2c3cb;
        }else if(tokenHash==keccak256(bytes("ETH"))){
            return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        }else if(tokenHash==keccak256(bytes("stETH"))){
            return 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;
        }else if(tokenHash==keccak256(bytes("sETH"))){
            return 0x5e74C9036fb86BD7eCdcb084a0673EFc32eA31cb;
        }else if(tokenHash==keccak256(bytes("LINK"))){
            return 0x514910771AF9Ca656af840dff83E8264EcF986CA;
        }else if(tokenHash==keccak256(bytes("sLINK"))){
            return 0xbBC455cb4F1B9e4bFC4B73970d360c8f032EfEE6;
        }else{
            revert("Token not supported.");
        }
    }

    // Repdroduced from Curve contract
    function stored_rates() internal returns(uint256[] memory){
        uint256[] memory result = new uint[](N_COINS);
        address curvePool = getCurvePoolContractAddress();
        if(curvePool==curvePoolAddressBUSD){
            uint256 ind=0;
            for(int8 i=0; i<int256(N_COINS);++i){
                result[ind] = PRECISION_MUL[ind] * yERC20(stableSwap.coins(i)).getPricePerFullShare();
                ind++;
            }
            delete ind;
            return result;
        }else if(curvePool==curvePoolAddress3Pool){
            result[0] = uint256(1000000000000000000);
            result[1] = uint256(1000000000000000000000000000000);
            result[2] = uint256(1000000000000000000000000000000);
        }else if(curvePool==curvePoolAddressEURS){
            result[0] = 10000000000000000000000000000000000;
            result[1] = 1000000000000000000;
        }else if(curvePool==curvePoolAddressUSDT ||
                curvePool==curvePoolAddressSUSD ||
                curvePool==curvePoolAddressCompound){
            uint256 ind=0;
            result = PRECISION_MUL;
            for(int8 i=0; i<int256(N_COINS);++i){
                uint256 rate = PRECISION;
                if(USE_LENDING[ind]){
                    rate = cERC20(stableSwap.coins(i)).exchangeRateStored();
                    uint256 supply_rate  = cERC20(stableSwap.coins(i)).supplyRatePerBlock();
                    uint256 old_block = cERC20(stableSwap.coins(i)).accrualBlockNumber();
                    rate += rate * supply_rate * (block.number - old_block) / PRECISION;
                }
                result[ind] *= rate;
                ind++;
            }
            return result;
        }else if(curvePool==curvePoolAddressAAVE || curvePool==curvePoolAddressSAAVE){
            result = PRECISION_MUL;
        }else if(curvePool==curvePoolAddressLINK ||
                    curvePool==curvePoolAddressSETH ||
                    curvePool==curvePoolAddressStETH){
            result[0] = 1;
            result[1] = 1;
        }else if(curvePool==curvePoolAddressAETH){
            result[0] = PRECISION;
            result[1] = PRECISION * LENDING_PRECISION / aETH(stableSwap.coins(uint256(1))).ratio();
        }else{
            revert("Cannot get rates, address not supported.");
        }
        return result;
    }

    // Repdroduced from Curve contract
    function _xp(uint256[] memory rates) internal view returns(uint256[] memory){
        address curvePool = getCurvePoolContractAddress();
        uint256[] memory result = rates;
        uint256 ind=0;
        if(curvePool==curvePoolAddressBUSD || 
                curvePool==curvePoolAddressUSDT ||
                curvePool==curvePoolAddressSUSD ||
                curvePool==curvePoolAddressCompound){
            for(uint8 i=0;i<N_COINS;){
                result[ind] = result[ind] * stableSwap.balances(int8(i)) / PRECISION;
                unchecked {
                    ind++;
                    i++;
                }
            }
        }else if(curvePool==curvePoolAddress3Pool ||
                curvePool==curvePoolAddressEURS ||
                curvePool==curvePoolAddressAETH){
            for(uint8 i=0;i<N_COINS;){
                result[ind] = result[ind] * stableSwap.balances(i) / PRECISION;
                unchecked {
                    ind++;
                    i++;
                }
            }
        }else if(curvePool==curvePoolAddressLINK ||
                    curvePool==curvePoolAddressSETH ||
                    curvePool==curvePoolAddressStETH ||
                    curvePool==curvePoolAddressSAAVE){
            for(uint8 i=0;i<N_COINS;){
                result[ind] = stableSwap.balances(i);
                unchecked {
                    ind++;
                    i++;
                }
            }
        }else if(curvePool==curvePoolAddressAAVE){
            for(uint8 i=0;i<N_COINS;){
                result[ind] = result[ind]*stableSwap.balances(i);
                unchecked {
                    ind++;
                    i++;
                }
            }
        }
        return result;
    }

    // Get the index of the token in all curve arrays
    function getIndexOfToken(string memory token) internal view returns (uint128) {
        address curvePool = getCurvePoolContractAddress();
        address tokenAddress = getAddressOfToken(token);
        for(uint8 i=0;i<N_COINS;){
            if(curvePool==curvePoolAddressBUSD || 
                    curvePool==curvePoolAddressUSDT ||
                    curvePool==curvePoolAddressSUSD ||
                    curvePool==curvePoolAddressCompound) {
                if(tokenAddress==stableSwap.underlying_coins(int8(i))){
                    delete tokenAddress;
                    return i;
                }
            }else if(curvePool==curvePoolAddress3Pool|| 
                    curvePool==curvePoolAddressEURS ||
                    curvePool==curvePoolAddressAETH ||
                    curvePool==curvePoolAddressLINK ||
                    curvePool==curvePoolAddressSETH ||
                    curvePool==curvePoolAddressStETH){
                if(tokenAddress==stableSwap.coins(i)){
                    delete tokenAddress;
                    return i;
                }
            }else if(curvePool==curvePoolAddressAAVE || curvePool==curvePoolAddressSAAVE){
                if(tokenAddress==stableSwap.underlying_coins(i)){
                    delete tokenAddress;
                    return i;
                }
            }else{
                revert("Address not supported.");
            }

            unchecked {
                i++;
            }
        }
        delete tokenAddress;
        return 100;
    }

    function getBalanceProduct() internal returns(uint256){
        uint256 s = 1;
        uint256[] memory xps = _xp(stored_rates());
        for(uint256 i=0;i<N_COINS;){
            s*=xps[i]/PRECISION;
            unchecked {
                i++;
            }
        }
        return s;
    }
    
    /**
    D is the sum of the balances
     */
    function getD() internal returns(uint){
        uint256 s = 0;
        uint256[] memory xps = _xp(stored_rates());
        for(uint256 i=0;i<N_COINS;){
            s+=xps[i]/PRECISION;
            unchecked {
                i++;
            }
        }
        return s;
    }
    
    function computePrice(string memory tokenFrom, string memory tokenTo) public returns(uint){
        uint256[] memory xps = _xp(stored_rates());
        uint256 reserveFrom = xps[getIndexOfToken(tokenFrom)]/PRECISION;
        uint256 reserveTo = xps[getIndexOfToken(tokenTo)]/PRECISION;
        uint256 A = stableSwap.A();
        uint256 n = N_COINS;
        uint256 D = getD();
        uint256 balanceProduct = getBalanceProduct();
        return (PRECISION*reserveFrom * (reserveTo*A*n**(2*n)*balanceProduct + (D**(n+1)))) / (reserveTo * (reserveFrom*A*n**(2*n)*balanceProduct + D**(n+1)));
    }

    function computePriceWithFee(string memory tokenFrom, string memory tokenTo) public returns(uint){
        return computePrice(tokenFrom, tokenTo) * (PRECISION - (PRECISION*stableSwap.fee())/FEE_DENOMINATOR) / PRECISION;
    }

    function computeSlippage(string memory tokenFrom, string memory tokenTo) external returns(uint){
        uint256[] memory xps = _xp(stored_rates());
        uint256 reserveFrom = xps[getIndexOfToken(tokenFrom)]/PRECISION;
        uint256 reserveTo = xps[getIndexOfToken(tokenTo)]/PRECISION;
        uint256 A = stableSwap.A();
        uint256 n = N_COINS;
        uint256 D = getD();
        uint256 balanceProduct = getBalanceProduct();
        return (PRECISION*reserveFrom*2*D**(n+1))/(reserveTo*reserveTo*(A*balanceProduct*n**(2*n)*reserveFrom+D**(n+1)));
    }

    function sqrtInt(int256 y) internal pure returns (int z) {
        return int(sqrt(uint256(y)));
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function getCurvePoolContractAddress() public view returns(address) {
        return address(stableSwap);
    }

    function getVirtualPriceForPool(string memory pool) external returns(uint256) {
        require((keccak256(abi.encodePacked(pool)))==keccak256("Curve"));
        return stableSwap.get_virtual_price();
    }

}