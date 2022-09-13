import CollectionConfigInterface from '../lib/CollectionConfigInterface';
import * as Networks from '../lib/Networks';
import * as Marketplaces from '../lib/Marketplaces';
import whitelistAddresses from './whitelist.json';

const CollectionConfig: CollectionConfigInterface = {
  testnet: Networks.ethereumTestnet,
  mainnet: Networks.ethereumMainnet,
  // The contract name can be updated using the following command:
  // yarn rename-contract NEW_CONTRACT_NAME
  // Please DO NOT change it manually!
  contractName: 'TestGenerate',
  tokenName: 'TESTNFT',
  tokenSymbol: 'TEST',
  hiddenMetadataUri: '.json',
  maxSupply: 7641,
  whitelistSale: {
    price: 0.001,
    maxMintAmountPerTx: 3,
  },
  preSale: {
    price: 0.002,
    maxMintAmountPerTx: 2,
  },
  publicSale: {
    price: 0.003,
    maxMintAmountPerTx: 1,
  },
  contractAddress: '0x0F7B5E7728f8fA433c0D670A08491e61A78154E4',
  marketplaceIdentifier: 'Test',
  marketplaceConfig: Marketplaces.openSea,
  whitelistAddresses,
};

export default CollectionConfig;
