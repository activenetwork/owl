class Alert < ActiveRecord::Base
  
  belongs_to :alert_handler
  belongs_to :watch
  
  validates_presence_of :watch, :alert_handler, :to
  
  def type
    self.alert_handler ? self.alert_handler.name.downcase.gsub(/ /,'_').to_sym : nil
  end
  
end
