require "proxanne/version"
require "proxanne/bmp"
require "proxanne/sauce_connect"
require "proxanne/console"
require "proxanne/config"

module Proxanne

  class << self
    def config_file_exists?
      Config.config_file_exists?
    end

    def create_config_file
      Config.create_config_file
    end

    def start
      @config = Config.new

      bmp = create_bmp
      sc = create_sc bmp.proxied_port

      bmp.create_initial_har
      Console.new bmp
    rescue StandardError => e
      puts "Error: #{e.to_s}"
      puts e.backtrace
    ensure
      bmp.kill_thread if bmp
      sc.kill_thread if sc
    end

    def create_bmp
      bmp = BMP.new
      bmp.location = @config.bmp_location
      bmp.port = @config.bmp_port

      bmp.start
      bmp.wait_until_ready
      bmp.create_proxy

      return bmp
    end

    def create_sc proxied_port
      sc = SauceConnect.new proxied_port 
      sc.location = @config.sc_location
      sc.flags = @config.flags
      sc.start
      sc.wait_until_ready

      return sc
    end
  end
end