require 'openai'

class AiAgent::Llm::TopicChatService < Llm::BaseOpenAiService
  include AiAgent::ChatHelper

  def initialize(topic: nil)
    super()

    @topic = topic
    @messages = [system_message]
    @response = ''
    register_tools
  end

  def generate_response(input, previous_messages = [], role = 'user')
    @messages += previous_messages
    @messages << { role: role, content: input } if input.present?
    request_chat_completion
  end

  private

  def register_tools
    @tool_registry = AiAgent::ToolRegistryService.new(@topic, user: nil)
    @tool_registry.register_tool(AiAgent::Tools::SearchDocumentationService)
  end

  def system_message
    {
      role: 'system',
      content: AiAgent::Llm::SystemPromptsService.topic_response_generator(@topic.name, @topic.config['product_name'], @topic.config)
    }
  end

  def persist_message(message, message_type = 'topic')
    # No need to implement
  end
end
