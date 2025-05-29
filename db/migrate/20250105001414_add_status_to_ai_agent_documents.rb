class AddStatusToAiAgentDocuments < ActiveRecord::Migration[7.0]
  def change
    add_column :ai_agent_documents, :status, :integer, null: false, default: 0
    add_index :ai_agent_documents, :status
  end
end
