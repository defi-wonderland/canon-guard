class ProxySignerApp {
    constructor() {
        this.web3 = null;
        this.account = null;
        this.chainId = null;
        
        // EIP712 domain based on ProxySigner contract
        this.domain = {
            name: 'ProxySigner',
            version: '1',
            chainId: null, // Will be set after connecting
            verifyingContract: '0x0000000000000000000000000000000000000000' // This would be the deployed ProxySigner contract address
        };
        
        // EIP712 types based on ProxySigner contract
        this.types = {
            Tx: [
                { name: 'actionBuilder', type: 'address' },
                { name: 'safeNonce', type: 'uint256' }
            ]
        };
        
        this.initializeEventListeners();
        this.updatePreview();
    }
    
    initializeEventListeners() {
        document.getElementById('connectWallet').addEventListener('click', () => this.connectWallet());
        document.getElementById('signMessage').addEventListener('click', () => this.signMessage());
        
        // Update preview when inputs change
        document.getElementById('actionBuilder').addEventListener('input', () => this.updatePreview());
        document.getElementById('safeNonce').addEventListener('input', () => this.updatePreview());
    }
    
    async connectWallet() {
        try {
            // Check if MetaMask is installed
            if (typeof window.ethereum === 'undefined') {
                this.showError('MetaMask is not installed. Please install MetaMask to continue.');
                return;
            }
            
            // Initialize Web3
            this.web3 = new Web3(window.ethereum);
            
            // Request account access
            const accounts = await window.ethereum.request({
                method: 'eth_requestAccounts'
            });
            
            this.account = accounts[0];
            const chainIdBigInt = await this.web3.eth.getChainId();
            this.chainId = Number(chainIdBigInt); // Convert BigInt to number
            
            // Update domain with chain ID
            this.domain.chainId = this.chainId;
            
            // Update UI
            this.showConnected();
            this.updatePreview();
            
            // Listen for account changes
            window.ethereum.on('accountsChanged', (accounts) => {
                if (accounts.length === 0) {
                    this.disconnect();
                } else {
                    this.account = accounts[0];
                    this.showConnected();
                }
            });
            
            // Listen for chain changes
            window.ethereum.on('chainChanged', (chainId) => {
                // chainId comes as hex string from the event
                this.chainId = parseInt(chainId, 16);
                this.domain.chainId = this.chainId;
                this.updatePreview();
            });
            
        } catch (error) {
            console.error('Error connecting wallet:', error);
            this.showError('Failed to connect wallet: ' + error.message);
        }
    }
    
    async signMessage() {
        try {
            if (!this.account) {
                this.showError('Please connect your wallet first.');
                return;
            }
            
            const actionBuilder = document.getElementById('actionBuilder').value.trim();
            const safeNonce = document.getElementById('safeNonce').value.trim();
            
            // Validate inputs
            if (!actionBuilder || !this.web3.utils.isAddress(actionBuilder)) {
                this.showError('Please enter a valid action builder address.');
                return;
            }
            
            if (!safeNonce || isNaN(safeNonce) || parseInt(safeNonce) < 0) {
                this.showError('Please enter a valid safe nonce (non-negative number).');
                return;
            }
            
            // Prepare the message
            const message = {
                actionBuilder: actionBuilder,
                safeNonce: safeNonce
            };
            
            // Create the EIP712 data structure
            const typedData = {
                types: {
                    EIP712Domain: [
                        { name: 'name', type: 'string' },
                        { name: 'version', type: 'string' },
                        { name: 'chainId', type: 'uint256' },
                        { name: 'verifyingContract', type: 'address' }
                    ],
                    ...this.types
                },
                primaryType: 'Tx',
                domain: this.domain,
                message: message
            };
            
            this.showResult('Signing message... Please check your wallet.');
            
            // Sign the message using EIP712
            const signature = await window.ethereum.request({
                method: 'eth_signTypedData_v4',
                params: [this.account, JSON.stringify(typedData)]
            });
            
            // Display the result
            const result = {
                signature: signature,
                message: message,
                signer: this.account,
                chainId: this.chainId
            };
            
            this.showResult(`Signature: ${signature}\n\nFull Result:\n${JSON.stringify(result, null, 2)}`);
            
        } catch (error) {
            console.error('Error signing message:', error);
            this.showError('Failed to sign message: ' + error.message);
        }
    }
    
    updatePreview() {
        const actionBuilder = document.getElementById('actionBuilder').value.trim() || '0x0000000000000000000000000000000000000000';
        const safeNonce = document.getElementById('safeNonce').value.trim() || '0';
        
        const message = {
            actionBuilder: actionBuilder,
            safeNonce: safeNonce
        };
        
        const previewData = {
            domain: this.domain,
            types: this.types,
            message: message
        };
        
        document.getElementById('messagePreview').textContent = JSON.stringify(previewData, null, 2);
    }
    
    showConnected() {
        const statusDiv = document.getElementById('walletStatus');
        statusDiv.className = 'status connected';
        statusDiv.textContent = `Connected: ${this.account} (Chain ID: ${this.chainId})`;
        
        document.getElementById('signMessage').disabled = false;
    }
    
    showError(message) {
        const statusDiv = document.getElementById('walletStatus');
        statusDiv.className = 'status error';
        statusDiv.textContent = message;
        
        document.getElementById('signMessage').disabled = true;
    }
    
    showResult(result) {
        const resultDiv = document.getElementById('signatureResult');
        resultDiv.textContent = result;
    }
    
    disconnect() {
        this.account = null;
        this.web3 = null;
        
        document.getElementById('walletStatus').textContent = '';
        document.getElementById('walletStatus').className = 'status';
        document.getElementById('signMessage').disabled = true;
        document.getElementById('signatureResult').textContent = '';
    }
}

// Initialize the app when the page loads
document.addEventListener('DOMContentLoaded', () => {
    new ProxySignerApp();
});

// Add some utility functions
window.addEventListener('load', () => {
    // Check if MetaMask is installed
    if (typeof window.ethereum === 'undefined') {
        document.getElementById('walletStatus').innerHTML = 
            '<div class="status error">MetaMask not detected. <a href="https://metamask.io/download/" target="_blank">Install MetaMask</a></div>';
    }
}); 