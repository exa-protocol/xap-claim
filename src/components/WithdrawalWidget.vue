<template>
  <div class="withdrawal-card">
    <div class="withdrawal-card-inner">
      <!-- Card Header -->
      <div class="header-section text-center">
        <div class="d-flex align-items-center justify-content-center mb-3">
          <img :src="xapCoin" class="header-logo me-3" alt="XAP Token" />
          <h1 class="mb-0">Withdraw your $XAP tokens</h1>
        </div>
        <p class="text-muted mb-4">
          Welcome to the official $XAP withdrawal page. Connect your wallet to
          withdraw your available tokens.
        </p>

        <!-- Network Badge -->
        <div class="network-badge mb-4">
          <span :class="['badge rounded-pill', networkColor]">
            <i
              class="bi bi-circle-fill me-1"
              :class="isConnected ? 'text-success' : 'text-warning'"
            ></i>
            {{ networkName }}
          </span>
        </div>
      </div>

      <!-- Wallet Connection Section -->
      <div class="wallet-connection" v-if="!isConnected">
        <div class="text-center">
          <div class="wallet-icon mb-4">
            <i class="bi bi-wallet2 fa-3x"></i>
          </div>
          <h3 class="mb-3">Connect Your Wallet</h3>
          <p class="text-muted mb-4">
            Connect your wallet to check your $XAP token balance and withdraw
            available tokens.
          </p>
          <button
            class="btn btn-primary btn-lg py-3 px-5 rounded-pill shadow-sm connect-btn"
            @click="$emit('connect-wallet')"
            :disabled="isConnecting"
          >
            <span
              v-if="isConnecting"
              class="spinner-border spinner-border-sm me-2"
              role="status"
              aria-hidden="true"
            ></span>
            {{ isConnecting ? "Connecting..." : "Connect Wallet" }}
          </button>
        </div>
      </div>

      <!-- Wallet Connected Section -->
      <div class="wallet-connected" v-if="isConnected">
        <!-- Account Info -->
        <div class="account-info mb-4">
          <div class="d-flex justify-content-between align-items-center">
            <div
              class="address-badge py-2 px-3 rounded-pill d-inline-flex align-items-center"
            >
              <i class="bi bi-person-circle me-2"></i>
              <span>{{ shortenAddress(userAccount) }}</span>
              <button
                class="btn btn-sm ms-2 text-light"
                @click="$emit('copy-address')"
                title="Copy Address"
              >
                <i class="bi bi-clipboard"></i>
              </button>
            </div>

            <button
              v-if="!isCorrectNetwork"
              class="btn btn-warning rounded-pill btn-sm"
              @click="$emit('switch-network')"
              :disabled="isSwitchingNetwork"
            >
              <span
                v-if="isSwitchingNetwork"
                class="spinner-border spinner-border-sm me-2"
                role="status"
                aria-hidden="true"
              ></span>
              {{
                isSwitchingNetwork
                  ? "Switching..."
                  : "Switch to " + requiredNetworkName
              }}
            </button>
          </div>
        </div>

        <!-- Balances Section -->
        <div class="balances-section">
          <div class="row g-4">
            <!-- ETH Balance -->
            <div class="col-md-4">
              <div class="balance-card h-100">
                <div class="card-body">
                  <div class="d-flex align-items-center mb-3">
                    <div class="balance-icon me-2">
                      <img :src="ethCoin" alt="ETH" width="24" height="24" />
                    </div>
                    <h4 class="mb-0">ETH Balance</h4>
                  </div>
                  <div class="balance-amount">
                    <div v-if="isLoading">
                      <div class="placeholder-glow">
                        <span class="placeholder col-8"></span>
                      </div>
                    </div>
                    <h3 v-else>{{ formatBalance(ethBalance) }}</h3>
                  </div>
                </div>
              </div>
            </div>

            <!-- XAP Balance -->
            <div class="col-md-4">
              <div class="balance-card h-100">
                <div class="card-body">
                  <div class="d-flex align-items-center mb-3">
                    <div class="balance-icon me-2">
                      <img
                        :src="xapCoin"
                        alt="XAP"
                        width="24"
                        height="24"
                        style="border-radius: 50%"
                      />
                    </div>
                    <h4 class="mb-0">XAP Balance</h4>
                  </div>
                  <div class="balance-amount">
                    <div v-if="isLoading">
                      <div class="placeholder-glow">
                        <span class="placeholder col-8"></span>
                      </div>
                    </div>
                    <h3 v-else>{{ formatBalance(xapBalance) }}</h3>
                  </div>
                </div>
              </div>
            </div>

            <!-- Withdrawable XAP -->
            <div class="col-md-4">
              <div class="balance-card withdrawable h-100">
                <div class="card-body">
                  <div class="d-flex align-items-center mb-3">
                    <div class="balance-icon me-2">
                      <img
                        :src="xapCoin"
                        alt="XAP"
                        width="24"
                        height="24"
                        style="border-radius: 50%"
                      />
                    </div>
                    <h4 class="mb-0">Withdrawable XAP</h4>
                  </div>
                  <div class="balance-amount">
                    <div v-if="isLoading">
                      <div class="placeholder-glow">
                        <span class="placeholder col-8"></span>
                      </div>
                    </div>
                    <h3 v-else>{{ formatBalance(withdrawableXAP) }}</h3>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Withdrawal Action -->
        <div class="withdrawal-action mt-5">
          <div class="row align-items-center">
            <div class="col-md-7">
              <div class="withdraw-info">
                <h4 class="mb-2">Ready to withdraw your tokens?</h4>
                <p class="text-muted mb-0">
                  Click the button to withdraw
                  {{ formatBalance(withdrawableXAP) }} XAP tokens to your
                  wallet.
                  <span
                    v-if="!canWithdraw && withdrawableXAP === '0'"
                    class="text-danger"
                  >
                    You don't have any tokens available to withdraw.
                  </span>
                </p>
              </div>
            </div>
            <div class="col-md-5 text-md-end text-center mt-3 mt-md-0">
              <button
                class="btn btn-primary btn-lg py-3 px-5 rounded-pill shadow withdraw-btn"
                @click="$emit('withdraw-tokens')"
                :disabled="!canWithdraw || isWithdrawing"
              >
                <span
                  v-if="isWithdrawing"
                  class="spinner-border spinner-border-sm me-2"
                  role="status"
                  aria-hidden="true"
                ></span>
                {{ isWithdrawing ? "Processing..." : "Withdraw Tokens" }}
              </button>
            </div>
          </div>
        </div>

        <!-- Transaction Status -->
        <div v-if="transactionHash" class="transaction-status mt-4">
          <div class="alert alert-success">
            <div class="d-flex align-items-center">
              <i class="bi bi-check-circle-fill fa-2x me-3"></i>
              <div>
                <h5 class="mb-1">Transaction successful!</h5>
                <p class="mb-2">
                  Your tokens have been successfully withdrawn to your wallet.
                </p>
                <a
                  :href="getExplorerUrl(transactionHash)"
                  target="_blank"
                  class="btn btn-sm btn-light"
                >
                  View on Explorer
                  <i class="bi bi-box-arrow-up-right ms-1"></i>
                </a>
              </div>
            </div>
          </div>
        </div>

        <!-- Error Message -->
        <div v-if="errorMessage" class="error-message mt-4">
          <div class="alert alert-danger">
            <div class="d-flex align-items-center">
              <i class="bi bi-exclamation-circle-fill fa-2x me-3"></i>
              <div>
                <h5 class="mb-1">Transaction Failed</h5>
                <p class="mb-0">{{ errorMessage }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "WithdrawalWidget",
  props: {
    xapCoin: String,
    ethCoin: String,
    networkColor: String,
    networkName: String,
    isConnected: Boolean,
    isConnecting: Boolean,
    userAccount: String,
    isCorrectNetwork: Boolean,
    requiredNetworkName: String,
    isSwitchingNetwork: Boolean,
    isLoading: Boolean,
    ethBalance: String,
    xapBalance: String,
    withdrawableXAP: String,
    canWithdraw: Boolean,
    isWithdrawing: Boolean,
    transactionHash: String,
    errorMessage: String,
    // Functions passed as props
    shortenAddress: Function,
    formatBalance: Function,
    getExplorerUrl: Function,
  },
  emits: [
    "connect-wallet",
    "copy-address",
    "switch-network",
    "withdraw-tokens",
  ],
};
</script>

<style scoped>
/* Styles specific to WithdrawalWidget, extracted from ClaimView.vue */
.withdrawal-card {
  background: rgba(21, 21, 21, 0.7);
  backdrop-filter: blur(10px);
  border-radius: 24px;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
  overflow: hidden;
  border: 1px solid rgba(255, 255, 255, 0.1);
  position: relative;
  z-index: 10;
  transform: translateZ(0);
}

.withdrawal-card-inner {
  padding: 3rem;
  position: relative;
  z-index: 2;
  color: #ffffff;
}

/* Header Section */
.header-section {
  margin-bottom: 3rem;
}

.header-section h1 {
  font-size: 2.5rem;
  font-weight: 700;
  background: linear-gradient(90deg, #ffffff, #a1c4fd);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
  margin-bottom: 1rem;
}

.text-muted {
  color: rgba(255, 255, 255, 0.7) !important;
}

.header-logo {
  width: 48px;
  height: 48px;
  animation: pulse 3s infinite ease-in-out;
  border-radius: 50%;
}

@keyframes pulse {
  0% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.1);
  }
  100% {
    transform: scale(1);
  }
}

/* Network Badge */
.network-badge .badge {
  font-size: 0.85rem;
  padding: 8px 16px;
  border: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

/* Wallet Connection Section */
.wallet-connection {
  background: rgba(0, 0, 0, 0.2);
  border-radius: 16px;
  padding: 3rem 2rem;
  margin-bottom: 1rem;
}

.wallet-icon {
  color: #4c6fff;
  animation: float 3s infinite ease-in-out;
}

@keyframes float {
  0% {
    transform: translateY(0px);
  }
  50% {
    transform: translateY(-10px);
  }
  100% {
    transform: translateY(0px);
  }
}

.connect-btn {
  background: linear-gradient(90deg, #4c6fff, #6e8cff);
  border: none;
  box-shadow: 0 10px 15px -3px rgba(76, 111, 255, 0.3);
  transition: all 0.3s ease;
}

.connect-btn:hover:not(:disabled) {
  transform: translateY(-3px);
  box-shadow: 0 15px 20px -3px rgba(76, 111, 255, 0.4);
}

.connect-btn:active:not(:disabled) {
  transform: translateY(-1px);
}

/* Account Info */
.address-badge {
  background: rgba(255, 255, 255, 0.1);
  font-family: monospace;
  font-size: 0.95rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  color: #ffffff;
}

/* Balance Cards */
.balances-section {
  margin-bottom: 2rem;
}

.balance-card {
  background: rgba(26, 32, 44, 0.8);
  border-radius: 16px;
  transition: all 0.3s ease;
  border: 1px solid rgba(255, 255, 255, 0.05);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
  overflow: hidden;
  color: #ffffff;
}

.balance-card .card-body {
  padding: 1.5rem;
}

.balance-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 15px 25px -5px rgba(0, 0, 0, 0.2);
  border-color: rgba(255, 255, 255, 0.1);
}

.balance-card h4 {
  color: #ffffff;
  font-weight: 500;
}

.balance-card.withdrawable {
  position: relative;
  --border-angle: 0turn;
  background: linear-gradient(
    135deg,
    rgba(26, 32, 44, 0.8) 0%,
    rgba(23, 49, 94, 0.8) 100%
  );
  border: double 2px transparent;
  border-radius: 16px;
  background-image: linear-gradient(
      rgba(26, 32, 44, 0.8),
      rgba(23, 49, 94, 0.8)
    ),
    linear-gradient(90deg, #4c6fff, #c471ed, #f64f59);
  background-origin: border-box;
  background-clip: padding-box, border-box;
}

.balance-icon {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(76, 111, 255, 0.2);
  border-radius: 8px;
  color: #4c6fff;
}

.balance-amount h3 {
  font-size: 1.75rem;
  font-weight: 700;
  margin: 0;
  background: linear-gradient(90deg, #ffffff, #a1c4fd);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
}

/* Withdrawal Action Section */
.withdrawal-action {
  background: rgba(26, 32, 44, 0.5);
  border-radius: 16px;
  padding: 2rem;
  border: 1px solid rgba(255, 255, 255, 0.05);
  color: #ffffff;
}

.withdrawal-action h4 {
  color: #ffffff;
  font-weight: 600;
}

.withdraw-info p {
  color: rgba(255, 255, 255, 0.7);
}

.withdraw-btn {
  position: relative;
  overflow: hidden;
  background: linear-gradient(90deg, #4c6fff, #6e8cff);
  border: none;
  transition: all 0.3s ease;
  box-shadow: 0 10px 15px -3px rgba(76, 111, 255, 0.3);
  color: #ffffff;
}

.withdraw-btn:hover:not(:disabled) {
  transform: translateY(-3px);
  box-shadow: 0 15px 20px -3px rgba(76, 111, 255, 0.4);
}

.withdraw-btn:disabled {
  background: linear-gradient(90deg, #718096, #a0aec0);
  cursor: not-allowed;
  opacity: 0.7;
}

/* Transaction Status and Error */
.transaction-status .alert,
.error-message .alert {
  border: none;
  border-radius: 16px;
}

.transaction-status .alert-success {
  background: rgba(72, 187, 120, 0.2);
  color: #48bb78;
  border-left: 4px solid #48bb78;
}

.transaction-status h5,
.transaction-status p {
  color: #48bb78;
}

.error-message .alert-danger {
  background: rgba(245, 101, 101, 0.2);
  color: #f56565;
  border-left: 4px solid #f56565;
}

.error-message h5,
.error-message p {
  color: #f56565;
}

@property --border-angle {
  syntax: "<angle>";
  inherits: true;
  initial-value: 0turn;
}

/* Responsive Adjustments (can be fine-tuned if necessary) */
@media (max-width: 992px) {
  .withdrawal-card-inner {
    padding: 2rem;
  }

  .header-section h1 {
    font-size: 2rem;
  }
}

@media (max-width: 768px) {
  .withdrawal-card-inner {
    padding: 1.5rem;
  }

  .withdrawal-action {
    padding: 1.5rem;
  }

  .balance-amount h3 {
    font-size: 1.5rem;
  }

  .wallet-connection {
    padding: 2rem 1.5rem;
  }

  .header-section h1 {
    font-size: 1.75rem;
  }
}

@media (max-width: 576px) {
  .address-badge {
    font-size: 0.8rem;
  }

  .withdraw-btn {
    width: 100%;
  }
}

/* Bootstrap icon sizing (if needed, already in ClaimView) */
.bi.fa-2x {
  font-size: 2em;
}

.bi.fa-3x {
  font-size: 3em;
}
</style>
