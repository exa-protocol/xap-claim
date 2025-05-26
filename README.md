# XAP Token Withdrawal Page

This project is a Vue.js application for withdrawing XAP tokens. It interacts with an Ethereum smart contract to allow users to connect their wallets, view their XAP and ETH balances, and withdraw available XAP tokens.

The application supports both the Sepolia testnet (for development) and Ethereum mainnet (for production).

## Features

- Wallet Connection (MetaMask or other compatible wallets)
- Display ETH Balance
- Display XAP Token Balance
- Display Withdrawable XAP Token Balance
- Withdraw XAP Tokens
- Network Switching (between Sepolia and Mainnet)
- Responsive Design

## Project Setup

### Prerequisites

- Node.js (v18 or later recommended)
- npm (comes with Node.js)
- A web browser with a compatible Ethereum wallet extension (e.g., MetaMask)

### Installation

1.  Clone the repository:

    ```sh
    git clone <your-repository-url>
    cd xap-claim
    ```

2.  Install dependencies:
    ```sh
    npm install
    ```

### Configuration

The smart contract addresses and network details are configured in `src/views/ClaimView.vue` within the `contracts` data property.

- **Development (Sepolia Testnet):**
  - `withdrawalContract`: Address of the withdrawal contract on Sepolia.
  - `xapTokenContract`: Address of the XAP token contract on Sepolia.
- **Production (Ethereum Mainnet):**
  - Update `withdrawalContract` with your mainnet withdrawal contract address.
  - Update `xapTokenContract` with your mainnet XAP token contract address.

## Running the Application

### Development Mode (Hot-Reload)

This mode typically uses the Sepolia testnet configuration.

```sh
npm run dev
```

The application will be served locally, usually at `http://localhost:5173`.

### Production Build

This will compile and minify the application for production. Ensure your mainnet contract addresses are correctly set before building.

```sh
npm run build
```

The production-ready files will be generated in the `dist` directory. You can then deploy this directory to your hosting provider.

## Smart Contracts

The application interacts with two main smart contracts:

1.  **Withdrawal Contract:** Handles the logic for token withdrawals. The ABI for this contract is located in `src/smart_contracts/abi.json`.
2.  **XAP Token Contract:** An ERC20 token contract for XAP.

Ensure these contracts are deployed to the respective networks (Sepolia and Mainnet) and their addresses are correctly configured in the application.

## Key Components

- `src/views/ClaimView.vue`: The main Vue component for the withdrawal page, containing all the logic for wallet interaction, balance display, and withdrawals.
- `src/components/AppNavbar.vue`: The navigation bar component.
- `src/components/AppFooter.vue`: The footer component.
- `src/components/ClaimWidget.vue`: The UI component for the withdrawal widget.
- `src/smart_contracts/abi.json`: ABI for the withdrawal smart contract.
- `src/assets/`: Contains static assets like images and CSS.

## Recommended IDE Setup

- [VSCode](https://code.visualstudio.com/)
- [Volar](https://marketplace.visualstudio.com/items?itemName=Vue.volar) (ensure Vetur is disabled if previously installed)

## Customizing Vite Configuration

See [Vite Configuration Reference](https://vite.dev/config/).
