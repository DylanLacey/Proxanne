require "erb"
require "tempfile"

module Proxanne
  class Pacfile

    def path
      @file.path
    end

    def initialize proxied_port
      @proxied_port = proxied_port

      renderer = ERB.new(template)
      @file = Tempfile.new('proxy.pac')

      @file.write renderer.result binding
      @file.close

      at_exit do
        @file.unlink
      end
    end

    def template
      directory = File.expand_path((File.dirname(__FILE__)))
      path = File.join directory, 'proxy.pac.erb'
      File.read path
    end
  end
end