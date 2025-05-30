class AiAgentListener < BaseListener
  include ::Events::Types

  def conversation_resolved(event)
    conversation = extract_conversation_and_account(event)[0]
    topic = conversation.inbox.ai_agent_topic

    return unless conversation.inbox.ai_agent_active?

    AiAgent::Llm::ContactNotesService.new(topic, conversation).generate_and_update_notes if topic.config['feature_memory'].present?
    AiAgent::Llm::ConversationFaqService.new(topic, conversation).generate_and_deduplicate if topic.config['feature_faq'].present?
  end
end
