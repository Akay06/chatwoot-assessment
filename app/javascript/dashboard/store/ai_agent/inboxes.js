import AiAgentInboxes from 'dashboard/api/ai_agent/inboxes';
import { createStore } from './storeFactory';
import { throwErrorMessage } from 'dashboard/store/utils/api';

export default createStore({
  name: 'AiAgentInbox',
  API: AiAgentInboxes,
  actions: mutations => ({
    delete: async function remove({ commit }, { inboxId, topicId }) {
      commit(mutations.SET_UI_FLAG, { deletingItem: true });
      try {
        await AiAgentInboxes.delete({ inboxId, topicId });
        commit(mutations.DELETE, inboxId);
        commit(mutations.SET_UI_FLAG, { deletingItem: false });
        return inboxId;
      } catch (error) {
        commit(mutations.SET_UI_FLAG, { deletingItem: false });
        return throwErrorMessage(error);
      }
    },
  }),
});
