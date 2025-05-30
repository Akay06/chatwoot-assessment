class RemoveIndexFromAiAgentTopics < ActiveRecord::Migration[7.0]
  def change
    remove_index :ai_agent_topics, [:account_id, :name], if_exists: true
  end
end
