<script setup>
import { computed, onMounted, ref, nextTick } from 'vue';
import { useMapGetter, useStore } from 'dashboard/composables/store';
import { FEATURE_FLAGS } from 'dashboard/featureFlags';

import TopicCard from 'dashboard/components-next/ai_agent/topic/TopicCard.vue';
import DeleteDialog from 'dashboard/components-next/ai_agent/pageComponents/DeleteDialog.vue';
import PageLayout from 'dashboard/components-next/ai_agent/PageLayout.vue';
import AiAgentPaywall from 'dashboard/components-next/ai_agent/pageComponents/Paywall.vue';
import CreateTopicDialog from 'dashboard/components-next/ai_agent/pageComponents/topic/CreateTopicDialog.vue';
import TopicPageEmptyState from 'dashboard/components-next/ai_agent/pageComponents/emptyStates/TopicPageEmptyState.vue';
import FeatureSpotlightPopover from 'dashboard/components-next/feature-spotlight/FeatureSpotlightPopover.vue';
import LimitBanner from 'dashboard/components-next/ai_agent/pageComponents/response/LimitBanner.vue';
import { useRouter } from 'vue-router';

const router = useRouter();

const store = useStore();
const dialogType = ref('');
const uiFlags = useMapGetter('aiAgentTopics/getUIFlags');
const topics = useMapGetter('aiAgentTopics/getRecords');
const isFetching = computed(() => uiFlags.value.fetchingList);

const selectedTopic = ref(null);
const deleteTopicDialog = ref(null);

const handleDelete = () => {
  deleteTopicDialog.value.dialogRef.open();
};

const createTopicDialog = ref(null);

const handleCreate = () => {
  dialogType.value = 'create';
  nextTick(() => createTopicDialog.value.dialogRef.open());
};

const handleEdit = () => {
  router.push({
    name: 'ai_agent_topics_edit',
    params: { topicId: selectedTopic.value.id },
  });
};

const handleViewConnectedInboxes = () => {
  router.push({
    name: 'ai_agent_topics_inboxes_index',
    params: { topicId: selectedTopic.value.id },
  });
};

const handleAction = ({ action, id }) => {
  selectedTopic.value = topics.value.find(
    topic => id === topic.id
  );
  nextTick(() => {
    if (action === 'delete') {
      handleDelete();
    }
    if (action === 'edit') {
      handleEdit();
    }
    if (action === 'viewConnectedInboxes') {
      handleViewConnectedInboxes();
    }
  });
};

const handleCreateClose = () => {
  dialogType.value = '';
  selectedTopic.value = null;
};

onMounted(() => store.dispatch('aiAgentTopics/get'));
</script>

<template>
  <PageLayout
    :header-title="$t('AI_AGENT.TOPICS.HEADER')"
    :button-label="$t('AI_AGENT.TOPICS.ADD_NEW')"
    :button-policy="['administrator']"
    :show-pagination-footer="false"
    :is-fetching="isFetching"
    :is-empty="!topics.length"
    :feature-flag="FEATURE_FLAGS.AI_AGENT"
    @click="handleCreate"
  >
    <template #knowMore>
      <FeatureSpotlightPopover
        :button-label="$t('AI_AGENT.HEADER_KNOW_MORE')"
        :title="$t('AI_AGENT.TOPICS.EMPTY_STATE.FEATURE_SPOTLIGHT.TITLE')"
        :note="$t('AI_AGENT.TOPICS.EMPTY_STATE.FEATURE_SPOTLIGHT.NOTE')"
        fallback-thumbnail="/assets/images/dashboard/ai_agent/topic-popover-light.svg"
        fallback-thumbnail-dark="/assets/images/dashboard/ai_agent/topic-popover-dark.svg"
        learn-more-url="https://chwt.app/ai_agent-topic"
      />
    </template>
    <template #emptyState>
      <TopicPageEmptyState @click="handleCreate" />
    </template>

    <template #paywall>
      <AiAgentPaywall />
    </template>

    <template #body>
      <LimitBanner class="mb-5" />

      <div class="flex flex-col gap-4">
        <TopicCard
          v-for="topic in topics"
          :id="topic.id"
          :key="topic.id"
          :name="topic.name"
          :description="topic.description"
          :updated-at="topic.updated_at || topic.created_at"
          :created-at="topic.created_at"
          @action="handleAction"
        />
      </div>
    </template>

    <DeleteDialog
      v-if="selectedTopic"
      ref="deleteTopicDialog"
      :entity="selectedTopic"
      type="Topics"
    />

    <CreateTopicDialog
      v-if="dialogType"
      ref="createTopicDialog"
      :type="dialogType"
      :selected-topic="selectedTopic"
      @close="handleCreateClose"
    />
  </PageLayout>
</template>
