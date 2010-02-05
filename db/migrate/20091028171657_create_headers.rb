class CreateHeaders < ActiveRecord::Migration
  def self.up
    create_table :headers do |t|
      t.string :key
      t.string :value
      t.integer :response_id

      t.timestamps
    end
    
    add_index :headers, :id, :unique => true
    add_index :headers, :response_id, :unique => true
    
  end

  def self.down
    drop_table :headers
  end
end
