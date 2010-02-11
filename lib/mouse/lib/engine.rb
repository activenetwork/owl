module Mouse
  class Engine
    
    # clear all db locks if we exit
    trap(:INT) do 
      clear_locks!
      Mouse.logger.info "!! SIGINT caught, exiting at #{Time.now.to_s}\n"
      exit
    end
    
    # clear all db locks if we exit
    trap(:TERM) do
      clear_locks!
      Mouse.logger.info "!! SIGTERM caught, exiting at #{Time.now.to_s}\n"
      exit
    end
      
    # clear all locks if the worker is exiting
    def self.clear_locks!
      Mouse.logger.debug("\n  Clearning all locks...\n")
      Watch.update_all("is_locked = 'f'")
    end
    

    def initialize
      Mouse.logger.info("Engine started at #{Time.now.to_s}...")
    end
    

    def go
      if Mouse.options.site.nil?
        watches = Watch.active 
      else
        begin
          watches = Site.find(Mouse.options.site).watches
        rescue ActiveRecord::RecordNotFound
          Mouse.logger.error("Site #{Mouse.options.site} not found, exiting")
          exit
        end
      end
      
      watches.each do |watch|
        Mouse.logger.debug("  - Checking watch #{watch.id}: #{watch.url}...")
        watch.reload(:lock => true)
        unless watch.is_locked?
          begin
            watch.lock
            http = nil
            time = Benchmark.realtime do
              http = HTTPClient.get(watch.url)
            end
            time = (time * 1000).round
            if http.status != watch.expected_response.code       # status code wasn't what was expected
              down(watch, :time => time, :http => http, :status_reason => "Response code #{http.status} did not match expected (#{watch.expected_response.code})")
            elsif watch.content_match && !http.body.content.match(watch.content_match)  # content on the page wasn't found
              down(watch, :time => time, :http => http, :status_reason => "Required content ('#{watch.content_match}') was not found on the page")
            else                                            # everything looks good, mark as up
              up(watch, :http => http, :time => time)
            end
          rescue SocketError => e                           # URL is invalid
            down(watch, :status_reason => 'URL is invalid')
          rescue HTTPClient::ReceiveTimeoutError => e       # Apparently the uncatchable error
            down(watch, :status_reason => 'ReceiveTimeoutError')
          rescue HTTPClient::ConnectTimeoutError => e       # Site isn't responding
            down(watch, :status_reason => 'Timed out waiting for response')
          rescue Errno::ECONNRESET => e
            down(watch, :status_reason => 'Connection reset by peer')
          rescue Errno::ECONNREFUSED => e
            down(watch, :status_reason => 'Connection refused')
          ensure
            watch.unlock
          end
        else
          Mouse.logger.debug("    Locked, skipping");
        end
      end
      
      cleanup   # removes responses older than a day
      
    end
    
    
    private
    
      # called when a site is considered up
      def up(watch, options={})
        defaults = { :time => 0, :http => nil, :status_reason => 'Site responding normally' }
        options = defaults.merge!(options)
        update_watch(watch, options[:time], Status::UP, options[:status_reason])
        response = add_response(watch, options[:time], options[:http].status, options[:http].reason)
        
        unless watch.alerts.empty?
          watch.alerts.each do |alert|
            alert.update_attribute(:is_outstanding, false)
          end
        end
        
        if Mouse.options.write_headers
          Mouse.logger.debug("    Saving headers...")
          options[:http].header.get.each do |header|
            response.headers.create(:key => header.first, :value => header.last)
          end
        end
      end
      
    
      # called when a site is considered down
      def down(watch, options={})
        defaults = { :time => 0, :http => nil, :status_reason => 'Site is down' }
        options = defaults.merge!(options)
        update_watch(watch, options[:time], Status::DOWN, options[:status_reason])
        response = add_response(watch, options[:time], options[:http] ? options[:http].status : 0, options[:http] ? options[:http].reason : 'error')
        
        # any alerts?
        unless watch.alerts.empty?
          watch.alerts.each do |alert|
            unless alert.is_outstanding?
              # only send out an alert if there isn't already one outstanding
              Mouse.logger.debug("    Queueing alert for #{alert.alert_handler.name} to #{alert.to}")
              alert.update_attribute(:is_outstanding, true)
              Delayed::Job.enqueue(eval("Alerts::#{alert.alert_handler.class_name}").new(alert.to, "Group: #{watch.site.name}, Watch: #{watch.name}: #{options[:status_reason]}"))
            else
              Mouse.logger.debug("    Outstanding alert, skipping queue to #{alert.alert_handler.name}")
            end
          end
        end
        
        Mouse.logger.error("  ** #{options[:status_reason]}")
      end
      
      
      # updates the watch record
      def update_watch(watch, time, status, status_reason)
        watch.status_id = status
        watch.last_status_change_at = Time.now.to_s(:db) if watch.changed?  # only updates the last status change
        watch.last_response_time = time
        watch.status_reason = status_reason
        begin
          return watch.save
        rescue SQLite3::BusyException => e
          Mouse.logger.error("    SQLite reported database lock, retrying...")
          retry
        end
      end
      
      
      # adds a response record
      def add_response(watch, time, status, reason)
        Mouse.logger.debug("    status: #{status}, response time: #{time}ms")
        return watch.responses.create(:time => time, :status => status, :reason => reason)
      end
      
      
      # figures out how much the current ping deviates from the norm
      def deviation
        
      end
      
      
      # removes any responses older than a given time
      def cleanup
        Mouse.logger.debug("Purging records older than #{Mouse.options.oldest} seconds.")
        Response.destroy_all ['created_at < ?', (Time.now - Mouse.options.oldest).to_s(:db)]
      end
      
      
  end
end