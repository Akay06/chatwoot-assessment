require 'rails_helper'

describe AiAgentListener do
  let(:listener) { described_class.instance }
  let(:account) { create(:account) }
  let(:inbox) { create(:inbox, account: account) }
  let(:user) { create(:user, account: account) }
  let(:topic) { create(:ai_agent_topic, account: account, config: { feature_memory: true, feature_faq: true }) }

  describe '#conversation_resolved' do
    let(:agent) { create(:user, account: account) }
    let(:conversation) { create(:conversation, account: account, inbox: inbox, assignee: agent) }

    let(:event_name) { :conversation_resolved }
    let(:event) { Events::Base.new(event_name, Time.zone.now, conversation: conversation) }

    before do
      create(:ai_agent_inbox, ai_agent_topic: topic, inbox: inbox)
    end

    context 'when feature_memory is enabled' do
      before do
        topic.config['feature_memory'] = true
        topic.config['feature_faq'] = false
        topic.save!
      end

      it 'generates and updates notes' do
        expect(AiAgent::Llm::ContactNotesService)
          .to receive(:new)
          .with(topic, conversation)
          .and_return(instance_double(AiAgent::Llm::ContactNotesService, generate_and_update_notes: nil))
        expect(AiAgent::Llm::ConversationFaqService).not_to receive(:new)

        listener.conversation_resolved(event)
      end
    end

    context 'when feature_faq is enabled' do
      before do
        topic.config['feature_faq'] = true
        topic.config['feature_memory'] = false
        topic.save!
      end

      it 'generates and deduplicates FAQs' do
        expect(AiAgent::Llm::ConversationFaqService)
          .to receive(:new)
          .with(topic, conversation)
          .and_return(instance_double(AiAgent::Llm::ConversationFaqService, generate_and_deduplicate: false))
        expect(AiAgent::Llm::ContactNotesService).not_to receive(:new)

        listener.conversation_resolved(event)
      end
    end
  end
end
