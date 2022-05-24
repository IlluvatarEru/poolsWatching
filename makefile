-include .env.local

export FOUNDRY_ETH_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/${ALCHEMY_KEY}
export FOUNDRY_FORK_BLOCK_NUMBER=14698417

.PHONY: test
test: 
	@forge test -vv > traces.ansi
