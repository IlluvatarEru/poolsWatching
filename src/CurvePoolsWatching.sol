// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.13;

interface IStableSwap {
    function coins(int128 i) external view returns (address);
    function coins(uint256 i) external view returns (address);
    function underlying_coins(int128 i) external view returns (address);
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

address constant curvePoolAddressBUSD = 0x79a8C46DeA5aDa233ABaFFD40F3A0A2B1e5A4F27;
address constant curvePoolAddress3Pool = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;

contract PriceAndSlippageComputerContract {
    address owner;
    IStableSwap public stableSwap;
    yERC20 public yerc20;
    // for each AMM there are different pairs
    mapping (string => mapping (string => address)) public pools;
    // map token to their addresses
    mapping (string => address) public tokens;

    
    uint256 public PRECISION;
    uint256 public FEE_DENOMINATOR;
    uint256[] public PRECISION_MUL;
    uint8 public N_COINS;


    constructor(address curvePool){
        owner=msg.sender;
        setCurvePoolContractAddress(curvePool);
        setUpVariables();
    }

    function setUpVariables() internal {
        if(getCurvePoolContractAddress()==curvePoolAddressBUSD){
            // This should be done outside of the constructor, we know it before compile time
            tokens["DAI"] = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
            tokens["USDC"] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
            tokens["USDT"] = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
            tokens["BUSD"] = 0x4Fabb145d64652a948d72533023f6E7A623C7C53;
            N_COINS = 4;
            PRECISION = 10 ** 18;
            FEE_DENOMINATOR = 10 ** 10;
            PRECISION_MUL = [uint256(1), uint256(1000000000000), uint256(1000000000000), uint256(1)];
        }else if(getCurvePoolContractAddress()==curvePoolAddress3Pool){
            // This should be done outside of the constructor, we know it before compile time
            tokens["DAI"] = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
            tokens["USDC"] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
            tokens["USDT"] = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
            N_COINS = 3;
            PRECISION = 10 ** 18;
            FEE_DENOMINATOR = 10 ** 10;
            PRECISION_MUL = [1, 1000000000000, 1000000000000];
        }else{
            revert("Address not supported.");
        }
    }

    function setCurvePoolContractAddress(address _address) internal {
        stableSwap = IStableSwap(_address);
    }

    function stored_rates2() public returns(uint256[] memory){
        uint256[] memory result = new uint[](N_COINS);
        uint256 ind=0;
        for(int8 i=0; i<int8(N_COINS);++i){
            result[ind] = PRECISION_MUL[ind] * yERC20(stableSwap.coins(i)).getPricePerFullShare();
            ind++;
        }
        return result;
    }
    // Repdroduced from Curve contract
    function stored_rates() internal returns(uint256[] memory){
        uint256[] memory result = new uint[](N_COINS);
        if(getCurvePoolContractAddress()==curvePoolAddressBUSD){
            uint256 ind=0;
            for(int8 i=0; i<int8(N_COINS);++i){
                result[ind] = PRECISION_MUL[ind] * yERC20(stableSwap.coins(i)).getPricePerFullShare();
                ind++;
            }
            return result;
        }else if(getCurvePoolContractAddress()==curvePoolAddress3Pool){
            result[0] = uint256(1000000000000000000);
            result[1] = uint256(1000000000000000000000000000000);
            result[2] = uint256(1000000000000000000000000000000);
        }else{
            revert("Address not supported.");
        }
        return result;
    }
    // Repdroduced from Curve contract
    function _xp(uint256[] memory rates) internal view returns(uint256[] memory){
        uint256[] memory result = rates;
        uint256 ind=0;
        for(uint8 i=0;i<N_COINS;){
            if(getCurvePoolContractAddress()==curvePoolAddressBUSD){
                result[ind] = result[ind] * stableSwap.balances(int8(i)) / PRECISION;
            }else if(getCurvePoolContractAddress()==curvePoolAddress3Pool){
                result[ind] = result[ind] * stableSwap.balances(i) / PRECISION;
            }else{
                revert("Address not supported.");
            }
            unchecked {
                ind++;
                i++;
            }
        }
        return result;
    }

    // Get the index of the token in all curve arrays
    function getIndexOfToken(string memory token) internal view returns (uint128) {
        address tokenAddress = tokens[token];
        for(uint8 i=0;i<N_COINS;++i){
            if(getCurvePoolContractAddress()==curvePoolAddressBUSD){
                if(tokenAddress==stableSwap.underlying_coins(int8(i))){
                    return i;
                }
            }else if(getCurvePoolContractAddress()==curvePoolAddress3Pool){
                if(tokenAddress==stableSwap.coins(i)){
                    return i;
                }
            }else{
                revert("Address not supported.");
            }
        }
    }

    function getXpsOfToken(string memory token) internal returns(uint256){
        uint256[] memory a = _xp(stored_rates());
        uint128 ind = getIndexOfToken(token);
        //uint256 ind256 = uint256(ind);
        return a[ind];
    }
    
    function getBalanceProduct() internal returns(uint256){
        uint256 s = 1;
        uint256[] memory rates = stored_rates();
        uint256[] memory xps = _xp(rates);
        for(uint8 i=0;i<N_COINS;++i){
            s*=xps[i]/PRECISION;
        }
        return s;
    }
    
    /**
    D is the sum of the balances
     */
    function getD() internal returns(uint){
        uint256 s = 0;
        uint256[] memory rates = stored_rates();
        uint256[] memory xps = _xp(rates);
        for(uint8 i=0;i<N_COINS;++i){
            s+=xps[i]/PRECISION;
        }
        return s;
    }
    
    function computePrice(string memory tokenFrom, string memory tokenTo) public returns(uint){
        uint256[] memory rates = stored_rates();
        uint256[] memory xps = _xp(rates);
        uint256 reserveFrom = xps[getIndexOfToken(tokenFrom)]/PRECISION;
        uint256 reserveTo = xps[getIndexOfToken(tokenTo)]/PRECISION;
        uint256 A = stableSwap.A();
        uint256 n = N_COINS;
        uint256 D = getD();
        uint256 balanceProduct = getBalanceProduct();
        return  (PRECISION*reserveFrom * (reserveTo*A*n**(2*n)*balanceProduct + (D**(n+1)))) / (reserveTo * (reserveFrom*A*n**(2*n)*balanceProduct + D**(n+1)));
    }

    function computePriceWithFee(string memory tokenFrom, string memory tokenTo) public returns(uint){
        uint256 priceWithoutFee = computePrice(tokenFrom, tokenTo);
        return priceWithoutFee * (PRECISION - (PRECISION*stableSwap.fee())/FEE_DENOMINATOR) / PRECISION;
    }

    function computeSlippage(string memory tokenFrom, string memory tokenTo) public returns(uint){
        uint256[] memory rates = stored_rates();
        uint256[] memory xps = _xp(rates);
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

    function getBalance(int128 ind) internal view returns(uint){
        return stableSwap.balances(ind);
    }

    function getCoin(int128 ind) internal view returns(address){
        return stableSwap.coins(ind);
    }

    function getUnderlyingCoin(int128 ind) internal view returns(address){
        return stableSwap.underlying_coins(ind);
    }

    function getCurvePoolContractAddress() public view returns(address) {
        return address(stableSwap);
    }

    function getVirtualPriceForPool(string memory pool, string memory pair) public returns(uint256) {
        require((keccak256(abi.encodePacked(pool)))==keccak256("Curve"));
        return stableSwap.get_virtual_price();
    }

}