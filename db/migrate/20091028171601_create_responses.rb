class CreateResponses < ActiveRecord::Migration
  def self.up
    create_table :responses do |t|
      t.integer :time
      t.integer :status
      t.string :reason
      t.integer :watch_id
      
      t.timestamps
    end
    
    add_index :responses, :id, :unique => true
    add_index :responses, :watch_id
    add_index :responses, :time
    add_index :responses, :created_at
    
  end

  def self.down
    drop_table :responses
  end
end
