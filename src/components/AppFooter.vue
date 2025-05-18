<template>
  <footer class="footer-minimal">
    <div class="container">
      <div class="row align-items-center">
        <div class="col-md-6 text-center text-md-start">
          <img :src="exaLogo" alt="Exa Protocol" class="footer-logo mb-3" />
          <p class="copyright mb-0">
            &copy; {{ new Date().getFullYear() }} ExaProtocol.com. All rights
            reserved.
          </p>
        </div>
        <div class="col-md-6 text-center text-md-end">
          <div class="footer-links">
            <a
              href="https://t.me/exaofficial"
              target="_blank"
              aria-label="Telegram"
            >
              <i class="bi bi-telegram"></i>
            </a>
            <a
              href="https://twitter.com/ExaProtocol"
              target="_blank"
              aria-label="Twitter"
            >
              <i class="bi bi-twitter"></i>
            </a>
            <a
              href="https://www.youtube.com/channel/UC1p9HLM8np7KDstZdxvMpJw"
              target="_blank"
              aria-label="YouTube"
            >
              <i class="bi bi-youtube"></i>
            </a>
          </div>
        </div>
      </div>
    </div>
  </footer>
</template>

<script>
export default {
  name: "AppFooter",
  props: {
    exaLogo: {
      type: String,
      required: true,
    },
  },
};
</script>

<style scoped>
/* Minimal Footer */
.footer-minimal {
  background-color: rgba(15, 24, 35, 0.9);
  padding: 1.5rem 0;
  color: rgba(255, 255, 255, 0.7);
  font-size: 0.9rem;
  border-top: 1px solid rgba(255, 255, 255, 0.05);
}

.footer-logo {
  height: 24px;
  width: auto;
  opacity: 0.8;
}

.copyright {
  font-size: 0.8rem;
  color: rgba(255, 255, 255, 0.5);
}

.footer-links {
  display: flex;
  justify-content: flex-end;
  gap: 1.25rem;
}

.footer-links a {
  color: rgba(255, 255, 255, 0.7);
  font-size: 1.2rem;
  transition: all 0.2s ease;
}

.footer-links a:hover {
  color: #ffffff;
  transform: translateY(-2px);
}
</style>
