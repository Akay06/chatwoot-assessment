<script setup>
import EmptyStateLayout from 'dashboard/components-next/EmptyStateLayout.vue';
import Button from 'dashboard/components-next/button/Button.vue';
import TopicCard from 'dashboard/components-next/ai_agent/topic/TopicCard.vue';
import FeatureSpotlight from 'dashboard/components-next/feature-spotlight/FeatureSpotlight.vue';
import { topicsList } from 'dashboard/components-next/ai_agent/pageComponents/emptyStates/aiAgentEmptyStateContent.js';

const emit = defineEmits(['click']);

const onClick = () => {
  emit('click');
};
</script>

<template>
  <FeatureSpotlight
    :title="$t('AI_AGENT.TOPICS.EMPTY_STATE.FEATURE_SPOTLIGHT.TITLE')"
    :note="$t('AI_AGENT.TOPICS.EMPTY_STATE.FEATURE_SPOTLIGHT.NOTE')"
    fallback-thumbnail="/assets/images/dashboard/ai_agent/topic-light.svg"
    fallback-thumbnail-dark="/assets/images/dashboard/ai_agent/topic-dark.svg"
    learn-more-url="https://chwt.app/ai_agent-topic"
    class="mb-8"
  />
  <EmptyStateLayout
    :title="$t('AI_AGENT.TOPICS.EMPTY_STATE.TITLE')"
    :subtitle="$t('AI_AGENT.TOPICS.EMPTY_STATE.SUBTITLE')"
    :action-perms="['administrator']"
  >
    <template #empty-state-item>
      <div class="grid grid-cols-1 gap-4 p-px overflow-hidden">
        <TopicCard
          v-for="(topic, index) in topicsList.slice(0, 5)"
          :id="topic.id"
          :key="`topic-${index}`"
          :name="topic.name"
          :description="topic.description"
          :updated-at="topic.created_at"
        />
      </div>
    </template>
    <template #actions>
      <Button
        :label="$t('AI_AGENT.TOPICS.ADD_NEW')"
        icon="i-lucide-plus"
        @click="onClick"
      />
    </template>
  </EmptyStateLayout>
</template>
