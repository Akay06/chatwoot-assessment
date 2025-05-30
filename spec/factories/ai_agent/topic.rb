FactoryBot.define do
  factory :ai_agent_topic, class: 'AiAgent::Topic' do
    sequence(:name) { |n| "Topic #{n}" }
    description { 'Test description' }
    association :account
  end
end
