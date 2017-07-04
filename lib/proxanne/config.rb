require "yaml"

module Proxanne
 	class Config

    class << self
      def default_config_directory
        File.join Dir.home, ".proxanne"
      end

      def default_config_file_path
        File.join default_config_directory, "proxanne.conf"
      end

      def create_config_directory
        unless File.directory? default_config_directory
          Dir.mkdir default_config_directory, 0700
        end
      end

      def create_config_file
        create_config_directory
        template_path = File.join __dir__, 'template.yaml'
        FileUtils.cp template_path, default_config_file_path

        return default_config_file_path
      end

      def config_file_exists?
        File.exist? default_config_file_path
      end
    end

    attr_reader :config_location
    attr_accessor :bmp_location, :sc_location, :bmp_port

    def initialize config_file_location=Config::default_config_file_path
      @config_location = config_file_location
      read_config_file

      @bmp_location = @config_file["browsermob_proxy"]["binary_location"]
      @bmp_port = (@config_file["browsermob_proxy"]["startup_port"] || 8081).to_i
      @sc_location = @config_file["sauce_connect"]["binary_location"]
    end

    def read_config_file
      @config_file = YAML.load File.read @config_location
    end
 	end
end