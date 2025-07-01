# ProxySigner EIP712 Interface

A simple web interface for connecting to web3 wallets and signing EIP712 messages based on the ProxySigner smart contract.

## Features

- Connect to MetaMask or other web3 wallets
- Sign EIP712 structured messages
- Real-time message preview
- Clean, responsive UI
- Input validation

## Usage

1. **Open the Interface**
   - Open `index.html` in your web browser
   - Or serve it using a local web server (recommended)

2. **Connect Your Wallet**
   - Click "Connect Wallet" button
   - Approve the connection in your wallet (MetaMask)
   - Your wallet address and chain ID will be displayed

3. **Enter Transaction Parameters**
   - **Action Builder Address**: The address of the action builder contract
   - **Safe Nonce**: The nonce value for the Safe transaction

4. **Sign the Message**
   - Click "Sign EIP712 Message"
   - Review the message in your wallet
   - Approve the signature
   - The signature will be displayed in the results section

## EIP712 Message Structure

The interface uses the following EIP712 structure based on the ProxySigner contract:

```javascript
Domain: {
  name: "ProxySigner",
  version: "1",
  chainId: <current_chain_id>,
  verifyingContract: <contract_address>
}

Message: {
  actionBuilder: <address>,
  safeNonce: <uint256>
}
```

## Requirements

- Modern web browser with ES6 support
- MetaMask or compatible web3 wallet
- Internet connection (for loading web3.js from CDN)

## Local Development

For development, it's recommended to serve the files using a local HTTP server:

```bash
# Using Python
python -m http.server 8000

# Using Node.js (http-server)
npx http-server

# Using PHP
php -S localhost:8000
```

Then open `http://localhost:8000` in your browser.

## Files

- `index.html` - Main HTML interface
- `app.js` - JavaScript application logic
- `styles.css` - CSS styling and layout
- `README.md` - This documentation

## Security Notes

- This is a development interface - do not use with mainnet funds without proper security review
- Always verify the message content before signing
- The interface loads web3.js from a CDN - consider hosting locally for production use
- The verifyingContract address should be set to your deployed ProxySigner contract address 