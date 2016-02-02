require 'json'

module Packageiq
  # load settings from config file
  class Loader
    CONFIG_DIR = '/etc/packageiq'

    attr_accessor :config_dir, :config_file
    def initialize(options = {})
      @config_dir   = options[:config_dir] || CONFIG_DIR
      @config_file  = options[:config_file] || nil
    end

    def load
      settings = {}
      if config_file
        settings.merge!(load_file)
      else
        settings.merge!(load_dir)
      end
      settings
    end

    def load_dir
      content = {}
      Dir.entries(config_dir).each do |entry|
        next unless entry =~ /.*\.json$/
        if File.file?("#{config_dir}/#{entry}")
          @config_file = entry
          content.merge!(load_file)
        end
      end
      content
    end

    # return json object
    def load_file
      file = File.open("#{config_dir}/#{config_file}")
      contents = file.read
      parse_contents(contents)
    end

    def parse_contents(contents)
      JSON.parse(contents, symbolize_names: true)
    end
  end
end
