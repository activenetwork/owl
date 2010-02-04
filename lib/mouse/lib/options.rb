require 'optparse'
require 'logger'

module Mouse
  class Options
    
    attr_reader :env, :log_level, :log_output, :interval, :write_headers, :oldest, :site
    
    def initialize(argv)
      @env = 'development'
      @log_level = Logger::DEBUG
      @log_output = STDOUT
      @interval = 60
      @oldest = 86400
      @write_headers = false
      @site = nil
      parse(argv)
    end
    
    private
    def parse(argv)
      OptionParser.new do |opts|
        
        opts.on("-e [env]", "--environment [env]", ['development', 'test', 'production'], "Rails environment development|test|production (default is #{env})") do |env|
          @env = env unless env.nil?
          case env
          when 'production'
            @log_level = Logger::INFO
            @log_output = File.dirname(__FILE__) + '/../../../log/mouse.log'
          end
        end
        
        opts.on("-i [seconds]", "--interval [seconds]", "The interval to crawl at, in seconds (default is #{@interval} seconds)") do |seconds|
          @interval = seconds.to_i unless seconds.nil?
        end
        
        opts.on("-l", nil, "Logs in verbose mode (default when running in development environment)") do
          @log_level = Logger::DEBUG
        end
        
        opts.on("-o [seconds]", "--oldest [seconds]", "Responses older than this are purged from the database (default is #{oldest} seconds)") do |seconds|
          @oldest = seconds.to_i unless seconds.nil?
        end
        
        opts.on("-s [site_id]", "--site [site_id]", "The ID of a single site/group to record responses for (default is all sites)") do |id|
          @site = id
        end
        
        opts.on("-w", "--write-headers", "Write response headers to database") do
          @write_headers = true
        end

        opts.on("-v", "--version", "Mouse version") do
          puts "Mouse " + Mouse::VERSION
          exit 0
        end

        opts.on("-h", "--help", "This help text") do
          puts opts
          exit 0
        end
        
        begin
          opts.parse(argv)
        rescue OptionParser::ParseError => e
          STDERR.puts e.message, "\n", opts
          exit(-1)
        end
      end
    end
  end
end
