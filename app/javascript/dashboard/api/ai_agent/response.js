/* global axios */
import ApiClient from '../ApiClient';

class AiAgentResponses extends ApiClient {
  constructor() {
    super('ai_agent/topic_responses', { accountScoped: true });
  }

  get({ page = 1, searchKey, topicId, documentId, status } = {}) {
    return axios.get(this.url, {
      params: {
        page,
        searchKey,
        topic_id: topicId,
        document_id: documentId,
        status,
      },
    });
  }
}

export default new AiAgentResponses();
