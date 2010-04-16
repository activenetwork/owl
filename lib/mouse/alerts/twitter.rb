module Mouse
  module Alerts
    class Twitter
      
      include HTTParty
      base_uri 'twitter.com'
      basic_auth 'username','password'
      
      def initialize(usernames, message)
        @usernames = usernames.split(',').collect(&:chomp)
        @message = message
      end
      
      def perform
        @usernames.each do |username|
          self.class.post('/statuses/update.json', :query => {:status => "@#{username} #{@message}"})
        end
      end
      
    end
  end
end
