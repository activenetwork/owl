class CreateAlerts < ActiveRecord::Migration
  def self.up
    create_table :alerts do |t|

      t.integer :watch_id
      t.integer :alert_handler_id   
      t.string :to                                  # list of usernames for whatever system
      t.last_sent_at :datetime                      # date/time that the last time someone was notified of this alert
      t.boolean :is_outstanding, :default => false  # set when an alert goes out but hasn't been rectified yet (so don't set another one)
      
      t.timestamps
    end
    
    add_index :alerts, :id, :unique => true
    add_index :alerts, :watch_id
    add_index :alerts, :alert_handler_id
    
  end

  def self.down
    drop_table :alerts
  end
end
