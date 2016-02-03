require 'packageiq/command'
require 'socket'

module Packageiq
  module Provider
    # rhel based system package provider
    class RHEL
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

      attr_reader :command_handler, :hostname, :collection_time

      def initialize
        @command_handler  = Packageiq::Command.new
        @hostname         = Socket.gethostname
        @collection_time  = Time.new
      end

      # returns array of installed packages
      def installed
        installed = run('rpm -qa')
        installed.split("\n")
      end

      # returns array of available yum update hashes
      def updates
        updates = run('yum list updates')
        parse_list(updates)
      end

      # returns hash of rpm info
      def info(package)
        info = run("rpm -qi #{package}")
        parse_info(info)
      end

      # build full package inventory
      # returns array of package_entry hashes
      def build_inventory
        inventory = []
        updates_array = updates
        installed.each do |package|
          package_info  = info(package)
          package_entry = updateable(package_info, updates_array)
          package_entry.merge!(host: hostname, collection_time: collection_time)
          inventory << packge_entry
        end
        inventory
      end

      # adds available update info to package_info hash
      def updateable(package_info, updates)
        update_info = { update_available: 'no', update_version: '-',
                        update_repo: '-' }
        updates.each do |update|
          next unless update[:name] == package_info[:name]
          update_info[:update_available]  = 'yes'
          update_info[:update_version]    = update[:version]
          update_info[:update_repo]       = update[:repo]
          break
        end
        package_info.merge(update_info)
      end

      private

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
