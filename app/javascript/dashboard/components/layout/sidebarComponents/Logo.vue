<script>
import { frontendURL } from 'dashboard/helper/URLHelper';

export default {
  props: {
    source: {
      type: String,
      default: '',
    },
    name: {
      type: String,
      default: '',
    },
    accountId: {
      type: Number,
      default: 0,
    },
  },
  computed: {
    dashboardPath() {
      return frontendURL(`accounts/${this.accountId}/dashboard`);
    },
  },
};
</script>

<template>
  <div class="w-8 h-8">
    <router-link :to="dashboardPath" replace class="inline-block w-full h-full">
      <img :src="source" :alt="name" class="w-full h-full object-contain" />
    </router-link>
  </div>
</template>
