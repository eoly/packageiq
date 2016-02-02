require 'optparse'

module Packageiq
  # Parse CLI arguments
  class CLI
    def self.read(arguments = ARGV)
      options = {}
      optparse = OptionParser.new do |opts|
        opts.on('-h', '--help', 'Display this message') do
          puts opts
          exit
        end

        opts.on('-V', '--version', 'Display Version') do
          puts Packageiq::VERSION
          exit
        end

        opts.on('-c', '--config FILE', 'PackageIQ config FILE') do |file|
          options[:config_file] = file
        end

        opts.on('-d', '--config_dir DIR',
                'DIR for PackageIQ config files') do |dir|
          options[:config_dir] = dir
        end
      end
      optparse.parse!(arguments)
      options
    end
  end
end
