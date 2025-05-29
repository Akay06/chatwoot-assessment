module Enterprise::Concerns::Inbox
  extend ActiveSupport::Concern

  included do
    has_one :ai_agent_inbox, dependent: :destroy, class_name: 'AiAgentInbox'
    has_one :ai_agent_topic,
            through: :ai_agent_inbox,
            class_name: 'AiAgent::Topic'
  end
end
