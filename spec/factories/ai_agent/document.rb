FactoryBot.define do
  factory :ai_agent_document, class: 'AiAgent::Document' do
    name { Faker::File.file_name }
    external_link { Faker::Internet.unique.url }
    content { Faker::Lorem.paragraphs.join("\n\n") }
    association :topic, factory: :ai_agent_topic
    association :account
  end
end
