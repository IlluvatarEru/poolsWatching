// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.13;

interface IStableSwap {
    function coins(int128 i) external view returns (address);
    function underlying_coins(int128 i) external view returns (address);
    function balances(int128 i) external view returns (uint);
    function get_virtual_price() external returns (uint256);
}

contract PriceAndSlippageComputerContract {
    address owner;
    string ownerName;
    IStableSwap public stableSwap;
    // for each AMM there are different pairs
    mapping (string => mapping (string => address)) public pools;
    // map token to their addresses
    mapping (string => address) public tokens;
    int N_COINS;

    constructor(string memory _name){
        owner=msg.sender;
        ownerName=_name;
        pools["Curve"]["BUSD"] = 0x79a8C46DeA5aDa233ABaFFD40F3A0A2B1e5A4F27;
        setUpTokens();
    }

    function setUpTokens() public {
        tokens["DAI"] = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        tokens["USDC"] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        tokens["USDT"] = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        tokens["BUSD"] = 0x4Fabb145d64652a948d72533023f6E7A623C7C53;
        N_COINS = 4;
    }
    
    function getIndexOfToken(string memory token) public view returns (int128) {
        address tokenAddress = tokens[token];
        for(int128 i=0;i<N_COINS;++i){
            if(tokenAddress==stableSwap.underlying_coins(i)){
                return i;
            }
        }
        return -1;
    }

    function getBalanceOfToken(string memory token) public view returns(uint){
        return stableSwap.balances(getIndexOfToken(token));

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

    function getPrice() public returns(uint256){
        return stableSwap.get_virtual_price();
    }

    function getPriceForPoolAndPair(string memory pool, string memory pair) public returns(uint256) {
        require((keccak256(abi.encodePacked(pool)))==keccak256("Curve"));
        address poolAddress = pools[pool][pair];
        setCurvePoolContractAddress(poolAddress);
        return stableSwap.get_virtual_price();
    }

}