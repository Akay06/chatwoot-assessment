class CreateAiAgentInbox < ActiveRecord::Migration[7.0]
  def change
    create_table :ai_agent_inboxes do |t|
      t.references :ai_agent_topic, null: false
      t.references :inbox, null: false
      t.timestamps
    end

    add_index :ai_agent_inboxes, [:ai_agent_topic_id, :inbox_id], unique: true
  end
end
