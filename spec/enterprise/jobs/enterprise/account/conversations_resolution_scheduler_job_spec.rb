require 'rails_helper'

RSpec.describe Account::ConversationsResolutionSchedulerJob, type: :job do
  let(:account) { create(:account) }
  let(:topic) { create(:ai_agent_topic, account: account) }

  describe '#perform - ai_agent resolutions' do
    context 'when handling different inbox types' do
      let!(:regular_inbox) { create(:inbox, account: account) }
      let!(:email_inbox) { create(:inbox, :with_email, account: account) }

      before do
        create(:ai_agent_inbox, ai_agent_topic: topic, inbox: regular_inbox)
        create(:ai_agent_inbox, ai_agent_topic: topic, inbox: email_inbox)
      end

      it 'enqueues resolution jobs only for non-email inboxes with ai_agent enabled' do
        expect do
          described_class.perform_now
        end.to have_enqueued_job(AiAgent::InboxPendingConversationsResolutionJob)
          .with(regular_inbox)
          .exactly(:once)
      end

      it 'does not enqueue resolution jobs for email inboxes even with ai_agent enabled' do
        expect do
          described_class.perform_now
        end.not_to have_enqueued_job(AiAgent::InboxPendingConversationsResolutionJob)
          .with(email_inbox)
      end
    end

    context 'when inbox has no ai_agent enabled' do
      let!(:inbox_without_ai_agent) { create(:inbox, account: create(:account)) }

      it 'does not enqueue resolution jobs' do
        expect do
          described_class.perform_now
        end.not_to have_enqueued_job(AiAgent::InboxPendingConversationsResolutionJob)
          .with(inbox_without_ai_agent)
      end
    end
  end
end
