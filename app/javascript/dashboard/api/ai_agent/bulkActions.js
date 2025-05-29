import ApiClient from '../ApiClient';

class AiAgentBulkActionsAPI extends ApiClient {
  constructor() {
    super('ai_agent/bulk_actions', { accountScoped: true });
  }
}

export default new AiAgentBulkActionsAPI();
