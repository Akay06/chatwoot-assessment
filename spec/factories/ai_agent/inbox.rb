FactoryBot.define do
  factory :ai_agent_inbox, class: 'AiAgentInbox' do
    association :ai_agent_topic, factory: :ai_agent_topic
    association :inbox
  end
end
