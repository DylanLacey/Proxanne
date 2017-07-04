require "childprocess"
require "unirest"
require "thread"

module Proxanne
  class BMP

    attr_reader :process_thread, :ready, :proxied_port
    attr_accessor :location, :port, :host

    def initialize
      @semaphor = Mutex.new
      @host = "localhost"
    end

    def start
      process = ChildProcess.build location, '-port', port.to_s
      @stdin_r, @stdin_w = IO.pipe
      @stder_r, @stder_w = IO.pipe

      process.io.stderr = @stder_w
      process.io.stdout = @stdin_w
      process.duplex

      process.leader = true

      @process_thread = Thread.new do
        at_exit do
          puts "Shutting down BMP..."
          process.stop #if process.alive?
        end

        process.start

        if process.alive?
          puts "BMP is starting up on port #{port}..."
          
          while true
            line = @stdin_r.gets
            if line.match /Started SelectChannelConnector/
              puts "BMP is ready"
              @semaphor.synchronize { @ready = true }
            else
              puts line if $DEBUG
            end
          end
        else
          puts "BMP died"
        end
      end
    end

    def wait_until_ready timeout=25
      timeout_after = Time.now + 15

      while !ready && (Time.now < timeout_after)
        sleep 5
      end

      if ready
        return true
      else
        raise "Timeout waiting for BMP to be ready"
      end
    end

    def create_proxy
      Unirest.timeout 20
      response = Unirest.post "http://#{host}:#{port}/proxy"
      @proxied_port =  response.body["port"] #should probably do something if response is not success
    end

    def create_initial_har
      retrieve_and_replace_har
    end

    def retrieve_har
      Unirest.timeout 20
      response = Unirest.get "http://#{host}:#{port}/proxy/#{proxied_port}/har"
    end


    def retrieve_and_replace_har
      Unirest.timeout 20
      response = Unirest.put "http://#{host}:#{port}/proxy/#{proxied_port}/har"
    end

    def wait_for_exit
      @process_thread.join
    end

    def kill_thread
      Thread.kill @process_thread if @process_thread
    end
  end
end