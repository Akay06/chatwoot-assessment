json.payload do
  json.array! @responses do |response|
    json.partial! 'api/v1/models/ai_agent/topic_response', formats: [:json], resource: response
  end
end

json.meta do
  json.total_count @responses_count
  json.page @current_page
end
