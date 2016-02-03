require 'json'

module Packageiq
  # load settings from config file
  class Loader
    CONFIG_DIR = '/etc/packageiq'

    attr_accessor :config_dir, :config_file
    attr_reader :settings

    # can accept options hash from CLI class
    def initialize(options = {})
      @config_dir   = options[:config_dir] || CONFIG_DIR
      @config_file  = options[:config_file] || nil
      @settings     = {}
    end

    # load config file settings
    # return hash of all settings
    def load
      if config_file
        full_path = full_path(config_dir, config_file)
        load_file(full_path)
      else
        load_dir(config_dir)
      end
      settings
    end

    private

    # joins to parts to form full path
    # returns full path to file or directory
    def full_path(part1, part2)
      File.join(part1, part2)
    end

    # recursively load config files from directory
    def load_dir(directory)
      Dir.entries(directory).each do |entry|
        next if entry == '..' || entry == '.'
        full_path = full_path(directory, entry)
        if File.file?(full_path)
          load_file(full_path)
        elsif File.directory?(full_path)
          load_dir(full_path)
        end
      end
    end

    # load file contents into settings hash
    # only loads .json files. does not load dotfiles
    def load_file(file_path)
      return unless File.fnmatch('**.json', file_path)
      handle = File.open(file_path)
      contents = handle.read
      config_hash = parse_contents(contents)
      settings.merge!(config_hash)
    end

    def parse_contents(contents)
      JSON.parse(contents, symbolize_names: true)
    end
  end
end
