class CreateAlerts < ActiveRecord::Migration
  def self.up
    create_table :alerts do |t|

      t.integer       :watch_id
      t.integer       :alert_handler_id   
      t.string        :to                 # list of usernames for whatever system
      t.last_sent_at  :datetime           # date/time that the last time someone was notified of this alert
      
      t.timestamps
    end
  end

  def self.down
    drop_table :alerts
  end
end
