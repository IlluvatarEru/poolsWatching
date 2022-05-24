// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.13;

interface IStableSwap {
    function coins(int128 i) external view returns (address);
    function underlying_coins(int128 i) external view returns (address);
    function balances(int128 i) external view returns (uint);
    function get_virtual_price() external returns (uint256);
    function A() external view returns (uint256);
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

contract PriceAndSlippageComputerContract {
    address owner;
    string ownerName;
    IStableSwap public stableSwap;
    yERC20 public y;
    // for each AMM there are different pairs
    mapping (string => mapping (string => address)) public pools;
    // map token to their addresses
    mapping (string => address) public tokens;
    uint128 N_COINS=4;
    uint256 PRECISION = 10 ** 18;
    uint256 PRECISION_I = 10 ** 18;
    uint256[4] PRECISION_MUL = [uint256(1), uint256(1000000000000), uint256(1000000000000), uint256(1)];


    constructor(string memory _name){
        owner=msg.sender;
        ownerName=_name;
        pools["Curve"]["BUSD"] = 0x79a8C46DeA5aDa233ABaFFD40F3A0A2B1e5A4F27;
        setUpTokens();
    }

    function setUpTokens() public {
        // This should be done outside of the constructor, we know it before compile time
        tokens["DAI"] = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        tokens["USDC"] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        tokens["USDT"] = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        tokens["BUSD"] = 0x4Fabb145d64652a948d72533023f6E7A623C7C53;
    }

    // Repdroduced from Curve contract
    function stored_rates() public returns(uint256[4] memory){
        uint256[4] memory result;
        uint256 ind=0;
        for(int128 i=0; i<int128(N_COINS);++i){
            result[ind] = PRECISION_MUL[ind] * yERC20(stableSwap.coins(i)).getPricePerFullShare();
            ind++;
        }
        return result;
    }
    // Repdroduced from Curve contract
    function _xp(uint256[4] memory rates) public returns(uint256[4] memory){
        uint256[4] memory result = rates;
        uint256 ind=0;
        
        for(uint128 i=0; i < N_COINS;){
            result[ind] = result[ind] * stableSwap.balances(int128(i)) / PRECISION;    
        
        unchecked {
            ++i;
            ++ind;
        }
        }

        return result;
    }

    // Get the index of the token in all curve arrays
    function getIndexOfToken(string memory token) public view returns (uint128) {
        address tokenAddress = tokens[token];
        for(uint128 i=0; i<N_COINS;){

            if(tokenAddress==stableSwap.underlying_coins(int128(i))) {
                return i;
            }
            
            unchecked {
                ++i;
            }
        }
    }

    function getBalanceOfToken(string memory token) public view returns(uint){
        return stableSwap.balances(int128(getIndexOfToken(token))); //PRECISION;
    }

    function getXpsOfToken(string memory token) public returns(uint256){
        uint256[4] memory a = _xp(stored_rates());
        uint256 ind = getIndexOfToken(token);
        return a[ind];
    }

    function computePrice(string memory tokenFrom, string memory tokenTo, uint256 amount) public returns(uint){
        address poolAddress = pools["Curve"][tokenFrom];
        setCurvePoolContractAddress(poolAddress);
        uint x = getBalanceOfToken(tokenFrom);
        uint y = getBalanceOfToken(tokenTo);
        //int k = x*y;
        uint A = stableSwap.A()/PRECISION_I;
        return y; 
        // TODO: modifffy to actually return
        //int(amount*PRECISION)* (2*x*int(sqrt(uint(x*(4*A*(k**3)+x*(- 4*A*k + 4*A*x+k)**2))))+8*A*k*x**2 -8*A*x**3+k**3-2*k*x**2);
        //(4*x*int(sqrt(uint(4*A*k**3+x*(-4*A*k+4*A*x+k)**2))));
    }

    function sqrt(uint256 y) internal pure returns (uint z) {
    if (y > 3) {
        z = y;
        uint x = y / 2 + 1;
        while (x < z) {
            z = x;
            x = (y / x + x) / 2;
        }
    } else if (y != 0) {
        z = 1;
    }
}

    function getBalance(int128 ind) public view returns(uint){
        return stableSwap.balances(ind);
    }

    function getCoin(int128 ind) public view returns(address){
        return stableSwap.coins(ind);
    }

    function getUnderlyingCoin(int128 ind) public view returns(address){
        return stableSwap.underlying_coins(ind);
    }

    function getOwnerName() public view returns(string memory) {
        return ownerName;
    }

    function setCurvePoolContractAddress(address _address) public {
        stableSwap = IStableSwap(_address);
    }

    function getCurvePoolContractAddress() public view returns(address) {
        return address(stableSwap);
    }

    function getVirtualPriceForPool(string memory pool, string memory pair) public returns(uint256) {
        require((keccak256(abi.encodePacked(pool)))==keccak256("Curve"));
        address poolAddress = pools[pool][pair];
        setCurvePoolContractAddress(poolAddress);
        return stableSwap.get_virtual_price();
    }

}