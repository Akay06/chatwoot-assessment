/* global axios */
import ApiClient from '../ApiClient';

class AiAgentDocument extends ApiClient {
  constructor() {
    super('ai_agent/documents', { accountScoped: true });
  }

  get({ page = 1, searchKey, topicId } = {}) {
    return axios.get(this.url, {
      params: {
        page,
        searchKey,
        topic_id: topicId,
      },
    });
  }
}

export default new AiAgentDocument();
