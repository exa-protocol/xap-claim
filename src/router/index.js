import { createRouter, createWebHistory } from 'vue-router'
import ClaimView from '../views/ClaimView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'claim',
      component: ClaimView,
    },

  ],
})

export default router
