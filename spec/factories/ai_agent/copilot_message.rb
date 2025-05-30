FactoryBot.define do
  factory :ai_agent_copilot_message, class: 'CopilotMessage' do
    account
    copilot_thread { association :ai_agent_copilot_thread }
    message { { content: 'This is a test message' } }
    message_type { 0 }
  end
end
