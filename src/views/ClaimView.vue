<template>
  <AppNavbar :exa-logo="exaLogo" />

  <section
    class="hero-section"
    :style="{ backgroundImage: `url(${heroBackground})` }"
  >
    <div class="container">
      <div class="row align-items-center justify-content-center">
        <div class="col-lg-10">
          <ClaimWidget
            :xap-coin="xapCoin"
            :eth-coin="ethCoin"
            :network-color="networkColor"
            :network-name="networkName"
            :is-connected="isConnected"
            :is-connecting="isConnecting"
            :user-account="userAccount"
            :is-correct-network="isCorrectNetwork"
            :required-network-name="requiredNetworkName"
            :is-switching-network="isSwitchingNetwork"
            :is-loading="isLoading"
            :eth-balance="ethBalance"
            :xap-balance="xapBalance"
            :withdrawableXAP="claimableXAP"
            :can-withdraw="canClaim"
            :is-withdrawing="isClaiming"
            :transaction-hash="transactionHash"
            :error-message="errorMessage"
            :shorten-address="shortenAddress"
            :format-balance="formatBalance"
            :get-explorer-url="getExplorerUrl"
            @connect-wallet="connectWallet"
            @copy-address="copyAddress"
            @switch-network="switchNetwork"
            @withdraw-tokens="claimTokens"
          />
        </div>
      </div>
    </div>
  </section>

  <AppFooter :exa-logo="exaLogo" />
</template>

<script>
import { ethers } from "ethers";
import contractABI from "../smart_contracts/abi.json";
import exaLogo from "../assets/images/exa_logo.png";
import xapCoin from "../assets/images/xap_coin.png";
import ethCoin from "../assets/images/eth_coin.png";
import connectButton from "../assets/images/connect_button_hero.png";
import downArrow from "../assets/images/down_arrow.png";
import heroBackground from "../assets/images/hero.png";

import AppNavbar from "../components/AppNavbar.vue";
import AppFooter from "../components/AppFooter.vue";
import ClaimWidget from "../components/ClaimWidget.vue";

export default {
  name: "ClaimView",
  components: {
    AppNavbar,
    AppFooter,
    ClaimWidget,
  },
  data() {
    return {
      // Images
      exaLogo,
      xapCoin,
      ethCoin,
      connectButton,
      downArrow,
      heroBackground,

      // Wallet connection states
      userAccount: "",
      isConnected: false,
      isConnecting: false,

      // Network states
      chainId: null,

      isCorrectNetwork: false,
      isSwitchingNetwork: false,

      // Balance states
      ethBalance: "0",
      xapBalance: "0",
      claimableXAP: "0",
      isLoading: false,

      // Claim states
      canClaim: false,
      isClaiming: false,
      transactionHash: "",
      errorMessage: "",

      // Contract addresses (environment-dependent)
      contracts: {
        development: {
          // Sepolia testnet
          chainId: "0xaa36a7",
          withdrawalContract: "0xa765a5db753648AA0683Eec66D02736d522d624d",
          xapTokenContract: "0xE3FAD904f18CCb463a426d02c3dF73B72f158372",
          explorerUrl: "https://sepolia.etherscan.io",
        },
        production: {
          // Ethereum mainnet
          chainId: "0x1",
          withdrawalContract: "0x3185141a79094C751b9f313D4e9B75e6ECa3D914", // Replace with actual mainnet address
          xapTokenContract: "0x66aA0E04864F2dE0Ee44d9e508e68415C04E2F57", // Replace with actual mainnet token address
          explorerUrl: "https://etherscan.io",
        },
      },

      // Contract instances
      provider: null,
      signer: null,
      withdrawalContract: null,
      xapTokenContract: null,
    };
  },

  computed: {
    // Current environment based on hostname
    environment() {
      const environment =
        window.location.hostname === "localhost" ||
        window.location.hostname === "127.0.0.1"
          ? "development"
          : "production";

      console.log("environment", environment);
      console.log(this.contracts[environment]);
      return environment;
    },

    // Get the current network configuration
    networkConfig() {
      return this.contracts[this.environment];
    },

    // Required network name based on environment
    requiredNetworkName() {
      return this.environment === "development"
        ? "Sepolia Testnet"
        : "Ethereum Mainnet";
    },

    // Current network name display
    networkName() {
      if (!this.isConnected) return "Not Connected";

      // Check for known networks
      switch (this.chainId) {
        case "0x1":
          return "Ethereum Mainnet";
        case "0xaa36a7":
          return "Sepolia Testnet";
        default:
          return `Unknown Network (${this.chainId})`;
      }
    },

    // Color for the network badge
    networkColor() {
      if (!this.isConnected) return "bg-secondary";
      return this.isCorrectNetwork ? "bg-success" : "bg-danger";
    },
  },

  methods: {
    // Format address to shorter version
    shortenAddress(address) {
      if (!address) return "";
      return (
        address.substring(0, 7) + "..." + address.substring(address.length - 5)
      );
    },

    // Format balances with proper decimal places
    formatBalance(balance) {
      if (!balance || balance === "0") return "0.00";

      // Format with up to 4 decimal places, but trim trailing zeros
      const formattedBalance = parseFloat(balance).toFixed(4);
      return parseFloat(formattedBalance).toString();
    },

    // Copy address to clipboard
    copyAddress() {
      if (!this.userAccount) return;

      navigator.clipboard
        .writeText(this.userAccount)
        .then(() => {
          // Could add a toast notification here
          console.log("Address copied to clipboard");
        })
        .catch((err) => {
          console.error("Failed to copy address", err);
        });
    },

    // Get blockchain explorer URL for transaction
    getExplorerUrl(txHash) {
      return `${this.networkConfig.explorerUrl}/tx/${txHash}`;
    },

    // Connect wallet
    async connectWallet() {
      if (!window.ethereum) {
        this.errorMessage =
          "No Ethereum wallet detected. Please install MetaMask or another compatible wallet.";
        return;
      }

      this.isConnecting = true;
      this.errorMessage = "";

      try {
        // Request account access
        const accounts = await window.ethereum.request({
          method: "eth_requestAccounts",
        });
        this.userAccount = accounts[0];

        // Initialize provider with safer approach
        try {
          this.provider = new ethers.providers.Web3Provider(
            window.ethereum,
            "any"
          );
          this.signer = this.provider.getSigner();
        } catch (providerError) {
          console.error("Provider initialization error:", providerError);
          throw new Error("Failed to initialize wallet provider");
        }

        // Get current chain ID directly from ethereum object
        try {
          this.chainId = await window.ethereum.request({
            method: "eth_chainId",
          });
        } catch (chainError) {
          console.error("Chain ID detection error:", chainError);
          throw new Error("Failed to detect network");
        }

        // Check if it's the correct network
        this.isCorrectNetwork = this.chainId === this.networkConfig.chainId;

        // Set up contract instances if on correct network
        if (this.isCorrectNetwork) {
          this.setupContracts();
        }

        // Set up event listeners
        this.setupEventListeners();

        this.isConnected = true;

        // Load balances if on correct network
        if (this.isCorrectNetwork) {
          this.loadBalances();
        }
      } catch (error) {
        console.error("Wallet connection error:", error);
        this.errorMessage =
          "Failed to connect wallet: " + (error.message || "Unknown error");
      } finally {
        this.isConnecting = false;
      }
    },

    // Set up contract instances
    setupContracts() {
      try {
        // Withdrawal contract
        this.withdrawalContract = new ethers.Contract(
          this.networkConfig.withdrawalContract,
          contractABI,
          this.signer
        );

        // XAP token contract - only need balanceOf for now
        this.xapTokenContract = new ethers.Contract(
          this.networkConfig.xapTokenContract,
          [
            // Basic ERC20 interface functions
            "function balanceOf(address owner) view returns (uint256)",
            "function decimals() view returns (uint8)",
            "function symbol() view returns (string)",
          ],
          this.signer
        );
      } catch (error) {
        console.error("Error setting up contracts:", error);
        this.errorMessage =
          "Failed to set up contracts: " + (error.message || "Unknown error");
      }
    },

    // Set up wallet event listeners
    setupEventListeners() {
      if (!window.ethereum) return;

      // Handle account changes
      window.ethereum.on("accountsChanged", (accounts) => {
        if (accounts.length === 0) {
          // User disconnected wallet
          this.resetConnection();
        } else {
          // User switched account
          this.userAccount = accounts[0];
          if (this.isCorrectNetwork) {
            this.loadBalances();
          }
        }
      });

      // Handle chain changes
      window.ethereum.on("chainChanged", (chainId) => {
        this.chainId = chainId;
        this.isCorrectNetwork = chainId === this.networkConfig.chainId;

        if (this.isCorrectNetwork) {
          // Re-setup contracts with new network
          this.setupContracts();
          this.loadBalances();
        } else {
          // Reset balances on incorrect network
          this.resetBalances();
        }
      });
    },

    // Reset connection state
    resetConnection() {
      this.isConnected = false;
      this.userAccount = "";
      this.resetBalances();
      this.provider = null;
      this.signer = null;
      this.withdrawalContract = null;
      this.xapTokenContract = null;
    },

    // Reset balance state
    resetBalances() {
      this.ethBalance = "0";
      this.xapBalance = "0";
      this.claimableXAP = "0";
      this.canClaim = false;
    },

    // Load user balances
    async loadBalances() {
      if (!this.isConnected || !this.isCorrectNetwork) return;

      this.isLoading = true;
      this.errorMessage = "";

      try {
        // Get ETH balance
        const ethBalanceWei = await this.provider.getBalance(this.userAccount);
        this.ethBalance = ethers.utils.formatEther(ethBalanceWei);

        // Get XAP token balance if contract is available
        if (this.xapTokenContract) {
          const xapBalanceWei = await this.xapTokenContract.balanceOf(
            this.userAccount
          );
          this.xapBalance = ethers.utils.formatUnits(xapBalanceWei, 8);
        }

        // Get claimable XAP balance - implement withdrawableBalance
        if (this.withdrawalContract) {
          const claimableBalanceWei = await this.withdrawableBalance();
          this.claimableXAP = ethers.utils.formatUnits(claimableBalanceWei, 8);
          this.canClaim = claimableBalanceWei.gt(0);
        }
      } catch (error) {
        console.error("Error loading balances:", error);
        this.errorMessage =
          "Failed to load balances: " + (error.message || "Unknown error");
      } finally {
        this.isLoading = false;
      }
    },

    // Implement withdrawableBalance function from the contract
    async withdrawableBalance() {
      if (!this.withdrawalContract || !this.userAccount) {
        return ethers.BigNumber.from(0);
      }

      try {
        // Call the withdrawableBalance function from the contract
        const balance = await this.withdrawalContract.withdrawableBalance(
          this.userAccount
        );
        return balance;
      } catch (error) {
        console.error("Error getting claimable balance:", error);
        throw error;
      }
    },

    // Implement withdraw function to claim tokens
    async claimTokens() {
      if (!this.isConnected || !this.isCorrectNetwork) {
        this.errorMessage =
          "Please connect your wallet and make sure you are on the correct network.";
        return;
      }

      if (!this.canClaim) {
        this.errorMessage = "You have no tokens available to claim.";
        return;
      }

      this.isClaiming = true;
      this.errorMessage = "";
      this.transactionHash = "";

      try {
        // Convert claimable amount to Wei using 8 decimals
        const amountToClaim = ethers.utils.parseUnits(
          this.claimableXAP.toString(),
          8
        );

        // Call the withdraw function from the contract
        const tx = await this.withdrawalContract.withdraw(amountToClaim);

        // Wait for transaction to be mined
        const receipt = await tx.wait();

        // Store transaction hash for UI
        this.transactionHash = receipt.transactionHash;

        // Reload balances after successful claim
        await this.loadBalances();
      } catch (error) {
        console.error("Error claiming tokens:", error);

        // Handle specific error cases
        if (error.code === 4001) {
          this.errorMessage = "Transaction was rejected by the user.";
        } else if (error.data && error.data.message) {
          this.errorMessage = "Claim failed: " + error.data.message;
        } else {
          this.errorMessage =
            "Claim failed: " + (error.message || "Unknown error");
        }
      } finally {
        this.isClaiming = false;
      }
    },

    // Switch to the required network
    async switchNetwork() {
      if (!window.ethereum) return;

      this.isSwitchingNetwork = true;
      this.errorMessage = "";

      try {
        // Try to switch to the required network
        await window.ethereum.request({
          method: "wallet_switchEthereumChain",
          params: [{ chainId: this.networkConfig.chainId }],
        });

        // Network switch should trigger chainChanged event which handles the rest
      } catch (error) {
        console.error("Error switching network:", error);

        // If the network is not added to MetaMask (error code 4902), we could prompt to add it
        if (error.code === 4902) {
          try {
            // Network parameters for add request
            const networkParams =
              this.environment === "development"
                ? {
                    chainId: this.networkConfig.chainId,
                    chainName: "Sepolia Testnet",
                    nativeCurrency: {
                      name: "Sepolia ETH",
                      symbol: "ETH",
                      decimals: 18,
                    },
                    rpcUrls: ["https://rpc.sepolia.org"],
                    blockExplorerUrls: [this.networkConfig.explorerUrl],
                  }
                : null; // Mainnet is already known to MetaMask

            if (networkParams) {
              await window.ethereum.request({
                method: "wallet_addEthereumChain",
                params: [networkParams],
              });
            } else {
              this.errorMessage =
                "Please add the required network to your wallet manually.";
            }
          } catch (addError) {
            console.error("Error adding network:", addError);
            this.errorMessage =
              "Failed to add network: " + (addError.message || "Unknown error");
          }
        } else {
          this.errorMessage =
            "Failed to switch network: " + (error.message || "Unknown error");
        }
      } finally {
        this.isSwitchingNetwork = false;
      }
    },

    // Method to load Bootstrap Icons
    loadBootstrapIcons() {
      if (!document.getElementById("bootstrap-icons-css")) {
        const link = document.createElement("link");
        link.id = "bootstrap-icons-css";
        link.rel = "stylesheet";
        link.href =
          "https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css";
        document.head.appendChild(link);
      }
    },
  },

  // Check if wallet is already connected on component mount
  mounted() {
    // Add this to ensure Bootstrap Icons are properly loaded
    this.loadBootstrapIcons();

    if (
      window.ethereum &&
      window.ethereum.isConnected() &&
      window.ethereum.selectedAddress
    ) {
      this.connectWallet();
    }
  },

  // Clean up event listeners on component unmount
  beforeUnmount() {
    if (window.ethereum) {
      window.ethereum.removeAllListeners("accountsChanged");
      window.ethereum.removeAllListeners("chainChanged");
    }
  },
};
</script>

<style scoped>
/* Main Layout */
.hero-section {
  position: relative;
  padding: 6rem 0;
  min-height: 100vh;
  background-color: #0f1823; /* Fallback color */
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  display: flex;
  align-items: center;
  overflow: hidden;
  color: #ffffff;
}

/* Styles that were specific to the withdrawal card are now in WithdrawalWidget.vue */
/* Any remaining global styles for ClaimView can stay here */

/* Bootstrap icon sizing */
.bi.fa-2x {
  font-size: 2em;
}

.bi.fa-3x {
  font-size: 3em;
}
</style>
