require 'administrate/field/base'

class AccountLimitsField < Administrate::Field::Base
  def to_s
    data.present? ? data.to_json : { agents: nil, inboxes: nil, ai_agent_responses: nil, ai_agent_documents: nil }.to_json
  end
end
