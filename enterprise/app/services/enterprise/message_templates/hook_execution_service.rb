module Enterprise::MessageTemplates::HookExecutionService
  def trigger_templates
    super
    return unless should_process_ai_agent_response?
    return perform_handoff unless inbox.ai_agent_active?

    AiAgent::Conversation::ResponseBuilderJob.perform_later(
      conversation,
      conversation.inbox.ai_agent_topic
    )
  end

  def should_process_ai_agent_response?
    conversation.pending? && message.incoming? && inbox.ai_agent_topic.present?
  end

  def perform_handoff
    return unless conversation.pending?

    Rails.logger.info("AiAgent limit exceeded, performing handoff mid-conversation for conversation: #{conversation.id}")
    conversation.messages.create!(
      message_type: :outgoing,
      account_id: conversation.account.id,
      inbox_id: conversation.inbox.id,
      content: 'Transferring to another agent for further assistance.'
    )
    conversation.bot_handoff!
  end
end
