# Curve Pools Watching

A simple smart contract to compute price and slippage given a pair of tokens and a pool

### How does it work?

You can call:
`computePrice(string memory tokenFrom, string memory tokenTo)`
`computePriceWithFee(string memory tokenFrom, string memory tokenTo)`
`computeSlippage(string memory tokenFrom, string memory tokenTo)`

### How are the formulas derived?
Take a look at how we derived the formulas in our [research paper](https://github.com/Arthurim/poolsWatching/blob/master/research/stableswapexplainer.pdf).
