class Alert < ActiveRecord::Base
  
  belongs_to :alert_handler
  belongs_to :watch
  
  validates_presence_of :watch, :alert_handler, :to
  
end
