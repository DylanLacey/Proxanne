require "proxanne/version"
require "proxanne/bmp"
require "proxanne/sauce_connect"
require "proxanne/console"

module Proxanne

  class << self
    def bmp_location
      "/Users/dylanlacey/Downloads/browsermob-proxy-2.1.4/bin/browsermob-proxy"
    end

    def bmp_port
      8081
    end

    def sc_location
      "/Users/dylanlacey/Downloads/sc-4.4.7-osx/bin/sc"
    end

    def start_bmp
      bmp = BMP.new
      bmp.location = bmp_location
      bmp.port = bmp_port

      bmp.start
      bmp.wait_until_ready
      bmp.create_proxy

      sc = SauceConnect.new bmp.proxied_port
      sc.location = sc_location

      sc.start
      sc.wait_until_ready

      bmp.create_initial_har

      console = Console.new bmp

      bmp.wait_for_exit
    rescue StandardError => e
      puts "Error: #{e.to_s}"
    ensure
      bmp.kill_thread if bmp
      sc.kill_thread if sc
    end
  end
end