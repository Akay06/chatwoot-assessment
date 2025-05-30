<script setup>
import DocumentCard from './DocumentCard.vue';
import { documentsList } from 'dashboard/components-next/ai_agent/pageComponents/emptyStates/aiAgentEmptyStateContent.js';
</script>

<template>
  <Story
    title="AiAgent/Topic/DocumentCard"
    :layout="{ type: 'grid', width: '700px' }"
  >
    <Variant title="Document Card">
      <div
        v-for="(doc, index) in documentsList"
        :key="index"
        class="px-20 py-4 bg-white dark:bg-slate-900"
      >
        <DocumentCard
          :id="doc.id"
          :name="doc.name"
          :external-link="doc.external_link"
          :topic="doc.topic"
          :created-at="doc.created_at"
        />
      </div>
    </Variant>
  </Story>
</template>
