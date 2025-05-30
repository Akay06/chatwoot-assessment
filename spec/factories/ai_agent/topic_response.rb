FactoryBot.define do
  factory :ai_agent_topic_response, class: 'AiAgent::TopicResponse' do
    association :topic, factory: :ai_agent_topic
    association :account
    sequence(:question) { |n| "Test question #{n}?" }
    sequence(:answer) { |n| "Test answer #{n}" }
    embedding { Array.new(1536) { rand(-1.0..1.0) } }

    trait :with_document do
      association :document, factory: :ai_agent_document
    end
  end
end
