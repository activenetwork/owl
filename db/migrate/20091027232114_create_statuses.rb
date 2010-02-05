class CreateStatuses < ActiveRecord::Migration
  def self.up
    create_table :statuses do |t|
      t.string :name
      t.string :css   # CSS class name
    end
    
    add_index :statuses, :id, :unique => true
    
  end

  def self.down
    drop_table :statuses
  end
end
