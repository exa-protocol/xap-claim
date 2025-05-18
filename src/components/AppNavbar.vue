<template>
  <nav class="navbar navbar-minimal">
    <div class="container">
      <a class="navbar-brand" href="https://www.exaprotocol.com">
        <img :src="exaLogo" alt="Exa Protocol" class="navbar-logo" />
      </a>
      <div class="navbar-links d-none d-md-flex">
        <a href="https://www.exaprotocol.com" class="nav-link" target="_blank"
          >Main Site</a
        >
        <a
          href="https://www.exaprotocol.com/token"
          class="nav-link"
          target="_blank"
          >Token</a
        >
        <a
          href="https://www.exaprotocol.com/exadrive"
          class="nav-link"
          target="_blank"
          >ExaDrive</a
        >
      </div>
    </div>
  </nav>
</template>

<script>
export default {
  name: "AppNavbar",
  props: {
    exaLogo: {
      type: String,
      required: true,
    },
  },
};
</script>

<style scoped>
/* Minimal Navbar */
.navbar-minimal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1030;
  background-color: rgba(15, 24, 35, 0.8);
  backdrop-filter: blur(8px);
  padding: 0.75rem 0;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
  transition: all 0.3s ease;
}

.navbar-logo {
  height: 30px;
  width: auto;
}

.navbar-links {
  display: flex;
  align-items: center;
}

.nav-link {
  color: rgba(255, 255, 255, 0.7);
  text-decoration: none;
  padding: 0 0.75rem;
  font-size: 0.9rem;
  transition: color 0.2s ease;
}

.nav-link:hover {
  color: #ffffff;
}
</style>
