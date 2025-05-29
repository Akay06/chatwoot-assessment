FactoryBot.define do
  factory :ai_agent_copilot_thread, class: 'CopilotThread' do
    account
    user
    title { Faker::Lorem.sentence }
    topic { create(:ai_agent_topic, account: account) }
  end
end
