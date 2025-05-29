import AiAgentBulkActionsAPI from 'dashboard/api/ai_agent/bulkActions';
import { createStore } from './storeFactory';
import { throwErrorMessage } from 'dashboard/store/utils/api';

export default createStore({
  name: 'AiAgentBulkAction',
  API: AiAgentBulkActionsAPI,
  actions: mutations => ({
    processBulkAction: async function processBulkAction(
      { commit },
      { type, actionType, ids }
    ) {
      commit(mutations.SET_UI_FLAG, { isUpdating: true });
      try {
        const response = await AiAgentBulkActionsAPI.create({
          type: type,
          ids,
          fields: { status: actionType },
        });
        commit(mutations.SET_UI_FLAG, { isUpdating: false });
        return response.data;
      } catch (error) {
        commit(mutations.SET_UI_FLAG, { isUpdating: false });
        return throwErrorMessage(error);
      }
    },

    handleBulkDelete: async function handleBulkDelete({ dispatch }, ids) {
      const response = await dispatch('processBulkAction', {
        type: 'TopicResponse',
        actionType: 'delete',
        ids,
      });

      // Update the response store after successful API call
      await dispatch('aiAgentResponses/removeBulkResponses', ids, {
        root: true,
      });
      return response;
    },

    handleBulkApprove: async function handleBulkApprove({ dispatch }, ids) {
      const response = await dispatch('processBulkAction', {
        type: 'TopicResponse',
        actionType: 'approve',
        ids,
      });

      // Update response store after successful API call
      await dispatch('aiAgentResponses/updateBulkResponses', response, {
        root: true,
      });
      return response;
    },
  }),
});
