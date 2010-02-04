class CreateAlertHandlers < ActiveRecord::Migration
  def self.up
    create_table :alert_handlers do |t|
      t.string :name
      t.string :class_name
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :alert_handlers
  end
end
