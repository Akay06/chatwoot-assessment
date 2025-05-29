import AiAgentDocumentAPI from 'dashboard/api/ai_agent/document';
import { createStore } from './storeFactory';

export default createStore({
  name: 'AiAgentDocument',
  API: AiAgentDocumentAPI,
});
