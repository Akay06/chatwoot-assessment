module Enterprise::Account::ConversationsResolutionSchedulerJob
  def perform
    super

    resolve_ai_agent_conversations
  end

  private

  def resolve_ai_agent_conversations
    AiAgentInbox.all.find_each(batch_size: 100) do |ai_agent_inbox|
      inbox = ai_agent_inbox.inbox

      next if inbox.email?

      AiAgent::InboxPendingConversationsResolutionJob.perform_later(
        inbox
      )
    end
  end
end
