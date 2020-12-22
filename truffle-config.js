const HDWalletProvider = require('@truffle/hdwallet-provider');
const privateKey = '3ddc9f73d55425ca6ce31a26c2e4a70743d85f567436ea5028878ff80083b8b0';
// const endpointUrl = 'https://web3-node.1inch.exchange';
const kovanEndpointUrl = 'https://kovan.infura.io/v3/9e4cfe82e43c48e2afc547c40145dab8';
const mainnetEndpointUrl = 'https://mainnet.infura.io/v3/9e4cfe82e43c48e2afc547c40145dab8';

module.exports = {
    networks: {
        kovan: {
            provider: function() {
                return new HDWalletProvider({
                    privateKeys: [privateKey],
                    providerOrUrl: kovanEndpointUrl,
                    pollingInterval: 5000
                });
            },
            gas: 5000000,
            gasPrice: 25000000000,
            network_id: 42
        },
        mainnet: {
            provider: function() {
                return new HDWalletProvider({
                    privateKeys: [privateKey],
                    providerOrUrl: mainnetEndpointUrl,
                    pollingInterval: 5000
                });
            },
            gas: 6000000,
            gasPrice: 80000000000,
            network_id: 1
        }
    },
    compilers: {
        solc: {
            version: '0.6.12',
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 10000
                }
            }
        }
    },
    plugins: ['solidity-coverage'],
    mocha: { // https://github.com/cgewecke/eth-gas-reporter
        reporter: 'eth-gas-reporter',
        reporterOptions: {
            currency: 'USD',
            gasPrice: 10,
            onlyCalledMethods: true,
            showTimeSpent: true,
            excludeContracts: ['Migrations', 'mocks']
        }
    }
};
