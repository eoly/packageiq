require 'packageiq/command'

module Packageiq
  module Provider
    # rhel based system package provider
    class Rhel
      # mapping for yum info field name to symbol
      RPM_INFO_KEY = {
        'Name'            => :name,
        'Epoch'           => :epoch,
        'Version'         => :version,
        'Release'         => :release,
        'Architecture'    => :arch,
        'Install Date'    => :install_date,
        'Group'           => :group,
        'Size'            => :size,
        'License'         => :license,
        'Signature'       => :signature,
        'Source RPM'      => :source_rpm,
        'Build Date'      => :build_date,
        'Build Host'      => :build_host,
        'Packager'        => :packager,
        'Vendor'          => :vendor,
        'URL'             => :url,
        'Summary'         => :summary
      }

      attr_accessor :command_handler

      def initialize
        @command_handler = Packageiq::Command.new
      end

      # list all installed rpms
      def installed
        run('rpm -qa')
      end

      # list of available updates
      def updates
        run('yum list updates')
      end

      def info(package)
        run("rpm -qi #{package}")
      end

      # use command handler to run command
      def run(command)
        command_handler.command = command
        command_handler.run
        command_handler.stdout
      end

      # normalize output so each package listing is on one line
      def unwrap(output)
        output.gsub(/\n/, '#').gsub(/#\s/, ' ').gsub(/#/, "\n")
      end

      # parse list output to hash, return array of hashes
      def parse_list(list)
        list          = unwrap(list)
        lines         = list.split("\n")
        package_list  = []
        lines.each do |line|
          next if line =~ Regexp.new(/^(Installed|Updated) Packages$/)
          parts   = line.split
          package = parts[0]
          name    = package.split('.')[0]
          arch    = package.split('.')[1]
          version = parts[1]
          repo    = parts[2]
          package_list << { name: name, arch: arch, version: version, repo: repo }
        end
        package_list
      end

      # parse rpm info into hash
      def parse_info(info)
        lines      = info.split("\n")
        info_hash  = {}
        lines.each do |line|
          RPM_INFO_KEY.each do |field, symbol|
            parse_regex = Regexp.new("^(#{field})+\s+:{1}\s+(.*)$")
            parts = parse_regex.match(line)
            info_hash[symbol] = parts[2] if parts
          end
        end
        info_hash
      end
    end
  end
end
