require "childprocess"
require "proxanne/pacfile"

module Proxanne
  class SauceConnect
  
    attr_accessor :location, :startup_timeout
    attr_reader :ready

    def initialize proxied_port=8081, startup_timeout=60
      @pacfile = Pacfile.new proxied_port
      @pacfile_path = @pacfile.path

      @semaphor = Mutex.new

      @startup_timeout = startup_timeout
    end

    def pacfile_path
      "file://#{@pacfile_path}"
    end

    def start
      process = ChildProcess.build location, '--pac', pacfile_path
      @stdin_r, @stdin_w = IO.pipe
      @stder_r, @stder_w = IO.pipe

      process.io.stderr = @stder_w
      process.io.stdout = @stdin_w
      process.duplex

      #Maybe bug out early if the process launch fails?
      @process_thread = Thread.new do
        at_exit do
          puts "Shutting down Sauce Connect..."
        process.stop

        end
        begin
          process.start
        rescue => e
          puts "Errrrr"
          puts e.to_s
        end
        if process.alive?
          puts "Sauce Connect is starting up..."

          while true
            # Nothing happens if there's an error; What do we do about that?
            line = @stdin_r.gets

            if line.match /Sauce Connect is up, you may start your tests./
              puts "Sauce Connect is ready"
              @semaphor.synchronize { @ready = true }
            else
              #puts line
            end
          end
        else
          puts "Sauce Connect did not start correctly."
        end


      end
    end

    def wait_until_ready timeout=45
      timeout_after = Time.now + timeout

      while !ready && (Time.now < timeout_after)
        sleep 5
      end

      if ready
        return true
      else
        raise "Timeout waiting for Sauce Connect to be ready"
      end
    end

    def wait_for_exit
      @process_thread.join
    end

    def kill_thread
      Thread.kill @process_thread if @process_thread
    end
  end
end