module Mouse
  module Alerts
    class InstantMessage < Struct.new(:usernames, :message)
      
      USERNAME = 'username'
      PASSWORD = 'password'
      
      # sends an authorization request to users (call this from the alert controller when someone is added to receive an alert)
      def perform
        usernames.split(',').collect(&:chomp).each do |username|
          Jabber::Simple.new(USERNAME, PASSWORD).deliver(username, message)
        end
      end
      
    end
  end
end
