<script setup>
import { onMounted, computed } from 'vue';
import { useAccount } from 'dashboard/composables/useAccount';
import { useAiAgent } from 'dashboard/composables/useAiAgent';
import { useRouter } from 'vue-router';

import Banner from 'dashboard/components-next/banner/Banner.vue';

const router = useRouter();
const { accountId } = useAccount();

const { documentLimits, fetchLimits } = useAiAgent();

const openBilling = () => {
  router.push({
    name: 'billing_settings_index',
    params: { accountId: accountId.value },
  });
};

const showBanner = computed(() => {
  if (!documentLimits.value) return false;

  const { currentAvailable } = documentLimits.value;
  return currentAvailable === 0;
});

onMounted(fetchLimits);
</script>

<template>
  <Banner
    v-show="showBanner"
    color="amber"
    :action-label="$t('AI_AGENT.PAYWALL.UPGRADE_NOW')"
    @action="openBilling"
  >
    {{ $t('AI_AGENT.BANNER.DOCUMENTS') }}
  </Banner>
</template>
