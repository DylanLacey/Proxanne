module Proxanne
  class Console
    attr_accessor :base_filename, :base_extension

    def initialize bmp
      @base_filename = "capture"
      @base_extension = "har"
      @capture_number = 1
      @bmp = bmp

      @output = STDOUT
      @input = STDIN

      @output.puts "Proxanne is ready and capturing."

      parse_command
    end

    def parse_command
      @output.puts "Save where? (enter 'quit' to quit) - (default: #{next_filename})"
      cmd_or_name = @input.gets
      command = case cmd_or_name
        when /^$/
          next_filename
        when /quit/
          :quit
        else
          cmd_or_name
      end

      exit if command == :quit
      save_to_file command
      parse_command
    end

    def save_to_file filename
      content = @bmp.retrieve_and_replace_har

      full_filename = File.join Dir.pwd, filename
      @output.puts "...Saving to #{full_filename}"
      file = File.new filename, "w"
      file.write content.raw_body
      file.close
      @output.puts "Saved"
      @capture_number += 1
    rescue => e
      @output.puts e
    end

    def next_filename
      "#{base_filename}_#{@capture_number}.#{base_extension}"
    end
  end
end