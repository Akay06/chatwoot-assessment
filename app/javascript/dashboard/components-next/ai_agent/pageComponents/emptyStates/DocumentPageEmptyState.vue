<script setup>
import EmptyStateLayout from 'dashboard/components-next/EmptyStateLayout.vue';
import Button from 'dashboard/components-next/button/Button.vue';
import DocumentCard from 'dashboard/components-next/ai_agent/topic/DocumentCard.vue';
import FeatureSpotlight from 'dashboard/components-next/feature-spotlight/FeatureSpotlight.vue';
import { documentsList } from 'dashboard/components-next/ai_agent/pageComponents/emptyStates/aiAgentEmptyStateContent.js';

const emit = defineEmits(['click']);

const onClick = () => {
  emit('click');
};
</script>

<template>
  <FeatureSpotlight
    :title="$t('AI_AGENT.DOCUMENTS.EMPTY_STATE.FEATURE_SPOTLIGHT.TITLE')"
    :note="$t('AI_AGENT.DOCUMENTS.EMPTY_STATE.FEATURE_SPOTLIGHT.NOTE')"
    fallback-thumbnail="/assets/images/dashboard/ai_agent/document-light.svg"
    fallback-thumbnail-dark="/assets/images/dashboard/ai_agent/document-dark.svg"
    learn-more-url="https://chwt.app/ai_agent-document"
    class="mb-8"
  />
  <EmptyStateLayout
    :title="$t('AI_AGENT.DOCUMENTS.EMPTY_STATE.TITLE')"
    :subtitle="$t('AI_AGENT.DOCUMENTS.EMPTY_STATE.SUBTITLE')"
    :action-perms="['administrator']"
  >
    <template #empty-state-item>
      <div class="grid grid-cols-1 gap-4 p-px overflow-hidden">
        <DocumentCard
          v-for="(document, index) in documentsList.slice(0, 5)"
          :id="document.id"
          :key="`document-${index}`"
          :name="document.name"
          :topic="document.topic"
          :external-link="document.external_link"
          :created-at="document.created_at"
        />
      </div>
    </template>
    <template #actions>
      <Button
        :label="$t('AI_AGENT.DOCUMENTS.ADD_NEW')"
        icon="i-lucide-plus"
        @click="onClick"
      />
    </template>
  </EmptyStateLayout>
</template>
