class CreateResponseCodes < ActiveRecord::Migration
  def self.up
    create_table :response_codes do |t|
      t.integer :code
      t.string :name

      t.timestamps
    end
    
    add_index :response_codes, :id, :unique => true
    
  end

  def self.down
    drop_table :response_codes
  end
end
