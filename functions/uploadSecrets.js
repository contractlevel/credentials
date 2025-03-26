const { SecretsManager } = require('@chainlink/functions-toolkit');
const { ethers } = require('ethers');
require('dotenv').config();

(async () => {
  try {
    // Load environment variables
    const cheqdApiKey = process.env.CHEQD_API_KEY;
    const provider = new ethers.providers.JsonRpcProvider(
      process.env.ETH_SEPOLIA_RPC_URL
    );
    const signer = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
    const functionsRouterAddress = process.env.CLF_ROUTER_ADDRESS_ETH_SEPOLIA;
    const donId = process.env.CLF_DON_ID_ETH_SEPOLIA;

    // Validate environment variables
    if (
      !cheqdApiKey ||
      !provider ||
      !signer ||
      !functionsRouterAddress ||
      !donId
    ) {
      throw new Error('Missing required environment variables');
    }

    // Initialize SecretsManager
    const secretsManager = new SecretsManager({
      signer,
      functionsRouterAddress,
      donId,
    });
    await secretsManager.initialize();
    console.log('SecretsManager initialized');

    // Fetch public keys
    const keys = await secretsManager.fetchKeys();
    console.log('Public Keys:', keys);

    // Encrypt the cheqd API key
    const secrets = { apiKey: cheqdApiKey };
    const encryptedSecretsObj = await secretsManager.encryptSecrets(secrets);
    console.log('Encrypted Secrets:', encryptedSecretsObj);

    const gatewayUrls = [
      'https://01.functions-gateway.testnet.chain.link/',
      'https://02.functions-gateway.testnet.chain.link/',
    ];
    const slotId = 0;
    const minutesUntilExpiration = 1440; // 24 hours

    // Upload encrypted secrets to DON
    const uploadResult = await secretsManager.uploadEncryptedSecretsToDON({
      encryptedSecretsHexstring: encryptedSecretsObj.encryptedSecrets,
      gatewayUrls,
      slotId,
      minutesUntilExpiration,
    });
    console.log('Upload Result:', uploadResult);

    // Build encrypted secrets reference
    const encryptedSecretsReference =
      secretsManager.buildDONHostedEncryptedSecretsReference({
        slotId,
        version: uploadResult.version,
      });
    console.log('Encrypted Secrets Reference:', encryptedSecretsReference);
  } catch (error) {
    console.error('Error:', error.message);
  }
})();
